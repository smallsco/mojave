--[===================================================================[--
   Copyright © 2016 Pedro Gimeno Fortea. All rights reserved.

   Permission is hereby granted to everyone to copy and use this file,
   for any purpose, in whole or in part, free of charge, provided this
   single condition is met: The above copyright notice, together with
   this permission grant and the disclaimer below, should be included
   in all copies of this software or of a substantial portion of it.

   THIS SOFTWARE COMES WITHOUT ANY WARRANTY, EXPRESS OR IMPLIED.
--]===================================================================]--

-- GIF(sm) image decoder for the love2d framework, using LuaJIT + FFI.
-- Includes LZW decompression.


local ffi = require 'ffi'
local bit = require 'bit'

-- We have a "double buffer" coroutine-based consumer-producer system
-- requiring the consumer to not request large chunks at a time
-- otherwise the buffer would overflow (this is detected but it will
-- cause an assertion error).

local bytearray = ffi.typeof('uint8_t[?]')
local intarray = ffi.typeof('int[?]')
local int32ptr = ffi.typeof('int32_t *')

-- Interlaced mode table. Format:
-- {initial value for pass 1, increment for pass 1,
--  initial value for pass 2, increment for pass 2, ...}
local intertable = {0, 8, 4, 8, 2, 4, 1, 2, false}

-- Utility function for error propagation
local function coresume(co, ...)
  local ok, err = coroutine.resume(co, ...)
  if not ok then
    error(err)
  end
end

-- Consumer
local function gifread(self, length)
  while self.ptr + length >= self.buflen do
    coroutine.yield() -- wait for more input
  end
  local tmp = self.ptr
  self.ptr = self.ptr + length
  if tmp >= 24576 then -- this leaves 8192 as max read length (768 would probably suffice)
    ffi.copy(self.buffer, self.buffer + tmp, self.buflen - tmp)
    self.buflen = self.buflen - tmp
    self.ptr = self.ptr - tmp
    tmp = 0
  end
  return tmp, length
end

-- Producer - prepare the data for the consumer
local function gifupdate(self, s)
  if #s > 32768 then
    -- Creating a Lua string object is an expensive operation.
    -- Do it as seldom as possible. We split the input data
    -- into 32K chunks.
    for i = 1, #s, 32768 do
      gifupdate(self, s:sub(i, i + 32767))
    end
    return
  end

  if coroutine.status(self.decoder) == "dead" then
    -- feeding data after the decoding is finished, ignore
    return
  end
  assert(self.buflen <= 32768, "Buffer overflow")

  ffi.copy(self.buffer + self.buflen, s, #s)
  self.buflen = self.buflen + #s
  coresume(self.decoder)
  return self
end

local function gifdone(self)
  -- free C memory immediately
  self.buffer = false
  return self
end

local function giferr(self, msg)
  print(msg)
end

-- Gif decoding aux functions
local function gifpalette(palette, source, psize)
  -- Read a palette, inserting alpha
  for i = 0, psize - 1 do
    palette[i*4]     = source[i*3]
    palette[i*4 + 1] = source[i*3 + 1]
    palette[i*4 + 2] = source[i*3 + 2]
    palette[i*4 + 3] = 255
  end
end

-- Gif decoder proper
local function gifdecoder(self)
  -- Read file ID and header
  local buffer = self.buffer
  gifread(self, 13)
  if ffi.string(self.buffer, 6) ~= 'GIF87a'
    and ffi.string(self.buffer, 6) ~= 'GIF89a'
  then
    self:err('Invalid GIF file format')
    return
  end
  self.width = buffer[6] + 256*buffer[7]
  self.height = buffer[8] + 256*buffer[9]
  local gpalettesize = buffer[10] >= 128 and bit.lshift(1, bit.band(buffer[10], 7) + 1) or 0
  local background = buffer[11]
  self.aspect = ((buffer[12] == 0 and 49 or 0) + 15) / 64

  local gpalette = bytearray(256*4)
  local lpalette = bytearray(256*4)
  local lpalettesize
  -- Read palette and set background
  self.background = background -- default value
  if gpalettesize > 0 then
    gifread(self, gpalettesize * 3)
    gifpalette(gpalette, buffer + 13, gpalettesize)

    if background < gpalettesize then
      self.background = {gpalette[background*4], gpalette[background*4+1], gpalette[background*4+2]}
    end
  end

  local p
  local GCE_trans = false
  local GCE_dispose = 0
  local GCE_delay = 0

  -- Allocate the buffers in advance, to reuse them for every frame
  local dict = bytearray(4096)
  local dictptrs = intarray(4096)
  local reversebuf = bytearray(4096)

  repeat
    -- Get block type
    p = gifread(self, 1)
    local blocktype = 0x3B
    local blocklen
    -- for simplicity (?), we fuse the block type and the extension type into
    -- 'blocktype'
    if buffer[p] == 0x2C then
      -- Image block
      blocktype = 0x2C
    elseif buffer[p] == 0x21 then
      -- Extension block
      p = gifread(self, 1)
      blocktype = buffer[p]
      if blocktype == 0x2C then
        -- there's no extension 2C - terminate
        -- (avoids ambiguity with block type 2C)
        blocktype = 0x3B
      end
    elseif buffer[p] ~= 0x3B then
      self:err(string.format("Unknown block type: 0x%02X", buffer[p]))
      break
    end

    if blocktype == 0x3B then
      -- Trailer block or invalid block - terminate
      break

    elseif blocktype == 0xFF then
      -- Application extension - may be loop, otherwise skip
      p = gifread(self, 1)
      blocklen = buffer[p]
      p = gifread(self, blocklen + 1)
      if blocklen >= 11 and ffi.string(buffer + p, 11) == 'NETSCAPE2.0' then
        -- these *are* the androids we're looking for
        p = p + blocklen
        while buffer[p] ~= 0 do
          local sblen = buffer[p]
          p = gifread(self, sblen + 1) -- read also the next block length
          if buffer[p] == 1 and sblen >= 3 then
            -- looping subblock - that's for us
            self.loop = buffer[p + 1] + 256 * buffer[p + 2]
          end
          p = p + sblen -- advance to next block
        end
      else
        -- skip entire block
        p = p + blocklen
        while buffer[p] ~= 0 do
          p = gifread(self, buffer[p] + 1) + buffer[p]
        end
      end

    elseif blocktype == 0x01 or blocktype == 0xFE then
      -- Text or Comment Extension - not processed by us, skip
      p = gifread(self, 1) -- read length
      if blocktype < 0x01 then
        -- skip the block header (contains a length field)
        p = gifread(self, buffer[p] + 1) + buffer[p]

        -- the text extension "consumes" the GCE, so we clear it
        GCE_trans = false
        GCE_dispose = 0
        GCE_delay = 0
      end
      while buffer[p] ~= 0 do
        p = gifread(self, buffer[p] + 1) + buffer[p]
      end

    elseif blocktype == 0xF9 then
      -- Graphic Control Extension
      p = gifread(self, 1)
      blocklen = buffer[p]
      p = gifread(self, blocklen + 1)
      if blocklen >= 4 then
        GCE_delay = (buffer[p+1] + 256 * buffer[p+2]) / 100
        GCE_trans = bit.band(buffer[p], 1) ~= 0 and buffer[p + 3]
        GCE_dispose = bit.rshift(bit.band(buffer[p], 0x1C), 2)
      end
      p = p + blocklen
      while buffer[p] ~= 0 do
        p = gifread(self, buffer[p] + 1) + buffer[p]
      end
    elseif blocktype == 0x2C then
      -- Here be dragons
      p = gifread(self, 9)

      local x, y = buffer[p] + 256*buffer[p+1], buffer[p+2] + 256*buffer[p+3]
      local w, h = buffer[p+4] + 256*buffer[p+5], buffer[p+6] + 256*buffer[p+7]
      if w == 0 or h == 0 then
        self:err('Zero size image')
        break
      end
      local img = love.image.newImageData(w, h)
      local dataptr = ffi.cast(int32ptr, img:getPointer())
      self.imgs[#self.imgs + 1] = GCE_dispose
      self.imgs[#self.imgs + 1] = GCE_delay
      self.imgs[#self.imgs + 1] = img
      self.imgs[#self.imgs + 1] = x
      self.imgs[#self.imgs + 1] = y
      self.nimages = self.nimages + 1

      local flags = buffer[p+8]
      if flags >= 128 then
        -- Has local palette
        lpalettesize = bit.lshift(1, bit.band(flags, 7) + 1)
        p = gifread(self, lpalettesize*3)
        gifpalette(lpalette, buffer + p, lpalettesize)
      else
        -- No local palette - copy the global palette to the local one
        ffi.copy(lpalette, gpalette, gpalettesize*4)
        lpalettesize = gpalettesize
      end
      if GCE_trans and GCE_trans < lpalettesize then
        -- Clear alpha
        lpalette[GCE_trans*4 + 3] = 0
      end
      local interlace = bit.band(flags, 64) ~= 0 and 1

      -- LZW decoder.

      -- This could really use another coroutine for
      -- simplicity, as there's another producer/consumer,
      -- but we won't go there.

      p = gifread(self, 2)
      local LZWsize = buffer[p]
      p = p + 1
      if LZWsize == 0 or LZWsize > 11 then
        self:err("Invalid code size")
        break
      end
      local codebits = LZWsize + 1
      local clearcode = bit.lshift(1, LZWsize) -- End-of-stream is always clearcode+1
      local dictlen = clearcode + 2

      local bitstream, bitlen = 0, 0
      x, y = 0, 0
      local nextlenptr = p
      local oldcode
      local walkcode

      local nrows = 0 -- counts vertical rows, used because interlacing makes the last y invalid
      local row = 0

      repeat
        -- Are there enough bits in curcode? Do we need to read more data?
        if bitlen >= codebits and y then
          -- Extract next code
          local code = bit.band(bitstream, bit.lshift(1, codebits) - 1)
          bitstream = bit.rshift(bitstream, codebits)
          bitlen = bitlen - codebits

          if code == clearcode then
            codebits = LZWsize + 1
            dictlen = clearcode + 2
            oldcode = false
          elseif code == clearcode + 1 then
            if x ~= 0 or nrows ~= h then
              self:err("Soft EOD before all rows were output")
            end
            -- signal end of processing
            -- (further data won't be read, but we need to follow the blocks)
            y = false
          else
            -- The dictionary is stored as a list of back pointers.
            -- We need to reverse the order to output the entries.
            -- We use a reverse buffer for that.
            local reverseptr = 4095
            -- Is this code already in the table?
            if code < dictlen then
              -- Already in the table - get the string from the table
              walkcode = code
              while walkcode >= clearcode do
                reversebuf[reverseptr] = dict[walkcode]
                reverseptr = reverseptr - 1
                walkcode = dictptrs[walkcode]
              end
              reversebuf[reverseptr] = walkcode
              -- Add to the table
              if oldcode then
                if dictlen < 4096 then
                  dictptrs[dictlen] = oldcode
                  dict[dictlen] = walkcode
                  dictlen = dictlen + 1
                  if dictlen ~= 4096 and bit.band(dictlen, dictlen - 1) == 0 then
                    -- perfect power of two - increase code size
                    codebits = codebits + 1
                  end
                end
              end
              oldcode = code
            else
              -- Not in the table - deal with the special case
              -- The compressor has created a new code, which must be the next
              -- in sequence. We know what it must contain.
              -- It must contain oldcode + first character of oldcode.
              if code > dictlen or not oldcode or not walkcode then
                self:err("Broken LZW")
                break
              end

              -- Add to the table
              if oldcode then
                if dictlen < 4096 then
                  dictptrs[dictlen] = oldcode
                  dict[dictlen] = walkcode
                  dictlen = dictlen + 1
                  if dictlen ~= 4096 and bit.band(dictlen, dictlen - 1) == 0 then
                    -- perfect power of two - increase code size
                    codebits = codebits + 1
                  end
                end
              end
              oldcode = code
              walkcode = oldcode

              while walkcode >= clearcode do
                reversebuf[reverseptr] = dict[walkcode]
                reverseptr = reverseptr - 1
                walkcode = dictptrs[walkcode]
              end
              reversebuf[reverseptr] = walkcode
            end

            if y then
              for i = reverseptr, 4095 do
                local c = reversebuf[i]
                if c >= lpalettesize then c = 0 end
                c = ffi.cast(int32ptr, lpalette)[c]
                dataptr[x + row] = c
                if interlace then
                  -- The passes 1, 2, 3, 4 correspond to the
                  -- values 1, 3, 5, 7 of 'interlace'.
                  if self.progressive and interlace < 7 and y + 1 < h then
                    -- In any pass but the last, there are at least 2 lines.
                    dataptr[x + row + w] = c
                    if interlace < 5 and y + 2 < h then
                      -- In the first two passes, there are at least 4 lines.
                      dataptr[x + row + w*2] = c
                      if y + 3 < h then
                        dataptr[x + row + w*3] = c
                        if interlace < 3 and y + 4 < h then
                          -- In the first pass there are 8 lines.
                          dataptr[x + row + w*4] = c
                          if y + 5 < h then
                            dataptr[x + row + w*5] = c
                            if y + 6 < h then
                              dataptr[x + row + w*6] = c
                              if y + 7 < h then
                                dataptr[x + row + w*7] = c
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                  -- Advance pixel
                  x = x + 1
                  if x >= w then
                    -- Skip to next interlaced row
                    x = 0
                    nrows = nrows + 1
                    y = y + intertable[interlace + 1]
                    if y >= h then
                      interlace = interlace + 2
                      if interlace > 7 then
                        y = false
                      else
                        y = intertable[interlace]
                      end
                    end
                    if y then
                      row = y * w
                    end
                  end
                else
                  -- No interlace, just increment y
                  x = x + 1
                  if x >= w then
                    x = 0
                    y = y + 1
                    nrows = y
                    if y >= h then
                      y = false
                    else
                      row = y * w
                    end
                  end
                end
              end

            else
              -- This should not happen.
              self:err('Data past the end of the image')
            end
          end
        else
          -- Not enough bits, grab 8 more
          if p >= nextlenptr then
            -- End of this subblock - read next subblock
            assert(p == nextlenptr)
            local sblen = buffer[nextlenptr]

            if sblen == 0 then
              -- no more data
              if y then
                self:err("Hard EOD before the end of the image")
              end
              break
            end
            p = gifread(self, sblen + 1)
            nextlenptr = p + sblen
          end
          if y then
            bitstream = bitstream + bit.lshift(buffer[p], bitlen)
            bitlen = bitlen + 8
            p = p + 1
          else
            -- end of data - fast forward to end of block
            p = nextlenptr
          end
        end

      until false
      
      GCE_trans = false
      GCE_dispose = 0
      GCE_delay = 0
      self.ncomplete = self.nimages

    else
      break
    end
  until false

end

local function gifframe(self, n)
  n = (n-1) % self.nimages + 1
  return self.imgs[n*5-2], self.imgs[n*5-1], self.imgs[n*5], self.imgs[n*5-3], self.imgs[n*5-4]
end

local function gifnew()
  local self = {
    update = gifupdate;
    done = gifdone;
    frame = gifframe;
    err = giferr;
    background = false;
    width = false;
    height = false;
    imgs = {};
    nimages = 0;
    ncomplete = 0;
    buffer = bytearray(65536);
    buflen = 0;
    ptr = 0;
    progressive = false;
    loop = false;
    aspect = false;
    decoder = coroutine.create(gifdecoder);
  }
  -- pass self to the coroutine (will return immediately for lack of data)
  coresume(self.decoder, self)
  return self
end

return gifnew
