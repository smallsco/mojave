--curl.h from libcurl 7.46.0 with 7.67.0 additions.
local ffi = require'ffi'

if ffi.abi'win' then
	ffi.cdef[[
		typedef uint64_t UINT_PTR;
		typedef UINT_PTR SOCKET;
		typedef SOCKET curl_socket_t;
	]]
else
	ffi.cdef'typedef int curl_socket_t;'
end

ffi.cdef[[
// curl.h --------------------------------------------------------------------

typedef struct CURL CURL;
typedef void curl_fd_set;
typedef long long curl_off_t;
typedef long long time_t;

typedef enum {
	CURLOPT_WRITEDATA                     = 10000 + 1,
	CURLOPT_URL                           = 10000 + 2,
	CURLOPT_PORT                          =     0 + 3,
	CURLOPT_PROXY                         = 10000 + 4,
	CURLOPT_USERPWD                       = 10000 + 5,
	CURLOPT_PROXYUSERPWD                  = 10000 + 6,
	CURLOPT_RANGE                         = 10000 + 7,
	CURLOPT_READDATA                      = 10000 + 9,
	CURLOPT_ERRORBUFFER                   = 10000 + 10,
	CURLOPT_WRITEFUNCTION                 = 20000 + 11,
	CURLOPT_READFUNCTION                  = 20000 + 12,
	CURLOPT_TIMEOUT                       =     0 + 13,
	// CURLOPT_INFILESIZE                 =     0 + 14,
	CURLOPT_POSTFIELDS                    = 10000 + 15,
	CURLOPT_REFERER                       = 10000 + 16,
	CURLOPT_FTPPORT                       = 10000 + 17,
	CURLOPT_USERAGENT                     = 10000 + 18,
	CURLOPT_LOW_SPEED_LIMIT               =     0 + 19,
	CURLOPT_LOW_SPEED_TIME                =     0 + 20,
	// CURLOPT_RESUME_FROM                =     0 + 21,
	CURLOPT_COOKIE                        = 10000 + 22,
	CURLOPT_HTTPHEADER                    = 10000 + 23,
	CURLOPT_HTTPPOST                      = 10000 + 24,
	CURLOPT_SSLCERT                       = 10000 + 25,
	CURLOPT_KEYPASSWD                     = 10000 + 26,
	CURLOPT_CRLF                          =     0 + 27,
	CURLOPT_QUOTE                         = 10000 + 28,
	CURLOPT_HEADERDATA                    = 10000 + 29,
	CURLOPT_COOKIEFILE                    = 10000 + 31,
	CURLOPT_SSLVERSION                    =     0 + 32,
	CURLOPT_TIMECONDITION                 =     0 + 33,
	// CURLOPT_TIMEVALUE                  =     0 + 34,
	CURLOPT_CUSTOMREQUEST                 = 10000 + 36,
	CURLOPT_STDERR                        = 10000 + 37,
	CURLOPT_POSTQUOTE                     = 10000 + 39,
	// CURLOPT_OBSOLETE40                 = 10000 + 40,
	CURLOPT_VERBOSE                       =     0 + 41,
	CURLOPT_HEADER                        =     0 + 42,
	CURLOPT_NOPROGRESS                    =     0 + 43,
	CURLOPT_NOBODY                        =     0 + 44,
	CURLOPT_FAILONERROR                   =     0 + 45,
	CURLOPT_UPLOAD                        =     0 + 46,
	CURLOPT_POST                          =     0 + 47,
	CURLOPT_DIRLISTONLY                   =     0 + 48,
	CURLOPT_APPEND                        =     0 + 50,
	CURLOPT_NETRC                         =     0 + 51,
	CURLOPT_FOLLOWLOCATION                =     0 + 52,
	CURLOPT_TRANSFERTEXT                  =     0 + 53,
	CURLOPT_PUT                           =     0 + 54,
	CURLOPT_PROGRESSFUNCTION              = 20000 + 56,
	CURLOPT_PROGRESSDATA                  = 10000 + 57,
	CURLOPT_XFERINFODATA                  = CURLOPT_PROGRESSDATA,
	CURLOPT_AUTOREFERER                   =     0 + 58,
	CURLOPT_PROXYPORT                     =     0 + 59,
	// CURLOPT_POSTFIELDSIZE              =     0 + 60,
	CURLOPT_HTTPPROXYTUNNEL               =     0 + 61,
	CURLOPT_INTERFACE                     = 10000 + 62,
	CURLOPT_KRBLEVEL                      = 10000 + 63,
	CURLOPT_SSL_VERIFYPEER                =     0 + 64,
	CURLOPT_CAINFO                        = 10000 + 65,
	CURLOPT_MAXREDIRS                     =     0 + 68,
	CURLOPT_FILETIME                      =     0 + 69,
	CURLOPT_TELNETOPTIONS                 = 10000 + 70,
	CURLOPT_MAXCONNECTS                   =     0 + 71,
	// CURLOPT_OBSOLETE72                 =     0 + 72,
	CURLOPT_FRESH_CONNECT                 =     0 + 74,
	CURLOPT_FORBID_REUSE                  =     0 + 75,
	CURLOPT_RANDOM_FILE                   = 10000 + 76,
	CURLOPT_EGDSOCKET                     = 10000 + 77,
	CURLOPT_CONNECTTIMEOUT                =     0 + 78,
	CURLOPT_HEADERFUNCTION                = 20000 + 79,
	CURLOPT_HTTPGET                       =     0 + 80,
	CURLOPT_SSL_VERIFYHOST                =     0 + 81,
	CURLOPT_COOKIEJAR                     = 10000 + 82,
	CURLOPT_SSL_CIPHER_LIST               = 10000 + 83,
	CURLOPT_HTTP_VERSION                  =     0 + 84,
	CURLOPT_FTP_USE_EPSV                  =     0 + 85,
	CURLOPT_SSLCERTTYPE                   = 10000 + 86,
	CURLOPT_SSLKEY                        = 10000 + 87,
	CURLOPT_SSLKEYTYPE                    = 10000 + 88,
	CURLOPT_SSLENGINE                     = 10000 + 89,
	CURLOPT_SSLENGINE_DEFAULT             =     0 + 90,
	CURLOPT_DNS_USE_GLOBAL_CACHE          =     0 + 91,
	CURLOPT_DNS_CACHE_TIMEOUT             =     0 + 92,
	CURLOPT_PREQUOTE                      = 10000 + 93,
	CURLOPT_DEBUGFUNCTION                 = 20000 + 94,
	CURLOPT_DEBUGDATA                     = 10000 + 95,
	CURLOPT_COOKIESESSION                 =     0 + 96,
	CURLOPT_CAPATH                        = 10000 + 97,
	CURLOPT_BUFFERSIZE                    =     0 + 98,
	CURLOPT_NOSIGNAL                      =     0 + 99,
	CURLOPT_SHARE                         = 10000 + 100,
	CURLOPT_PROXYTYPE                     =     0 + 101,
	CURLOPT_ACCEPT_ENCODING               = 10000 + 102,
	CURLOPT_PRIVATE                       = 10000 + 103,
	CURLOPT_HTTP200ALIASES                = 10000 + 104,
	CURLOPT_UNRESTRICTED_AUTH             =     0 + 105,
	CURLOPT_FTP_USE_EPRT                  =     0 + 106,
	CURLOPT_HTTPAUTH                      =     0 + 107,
	CURLOPT_SSL_CTX_FUNCTION              = 20000 + 108,
	CURLOPT_SSL_CTX_DATA                  = 10000 + 109,
	CURLOPT_FTP_CREATE_MISSING_DIRS       =     0 + 110,
	CURLOPT_PROXYAUTH                     =     0 + 111,
	CURLOPT_FTP_RESPONSE_TIMEOUT          =     0 + 112,
	CURLOPT_SERVER_RESPONSE_TIMEOUT       = CURLOPT_FTP_RESPONSE_TIMEOUT,
	CURLOPT_IPRESOLVE                     =     0 + 113,
	// CURLOPT_MAXFILESIZE                =     0 + 114,
	CURLOPT_INFILESIZE                    = 30000 + 115,
	CURLOPT_RESUME_FROM                   = 30000 + 116,
	CURLOPT_MAXFILESIZE                   = 30000 + 117,
	CURLOPT_NETRC_FILE                    = 10000 + 118,
	CURLOPT_USE_SSL                       =     0 + 119,
	CURLOPT_POSTFIELDSIZE                 = 30000 + 120,
	CURLOPT_TCP_NODELAY                   =     0 + 121,
	CURLOPT_FTPSSLAUTH                    =     0 + 129,
	CURLOPT_IOCTLFUNCTION                 = 20000 + 130,
	CURLOPT_IOCTLDATA                     = 10000 + 131,
	CURLOPT_FTP_ACCOUNT                   = 10000 + 134,
	CURLOPT_COOKIELIST                    = 10000 + 135,
	CURLOPT_IGNORE_CONTENT_LENGTH         =     0 + 136,
	CURLOPT_FTP_SKIP_PASV_IP              =     0 + 137,
	CURLOPT_FTP_FILEMETHOD                =     0 + 138,
	CURLOPT_LOCALPORT                     =     0 + 139,
	CURLOPT_LOCALPORTRANGE                =     0 + 140,
	CURLOPT_CONNECT_ONLY                  =     0 + 141,
	CURLOPT_CONV_FROM_NETWORK_FUNCTION    = 20000 + 142,
	CURLOPT_CONV_TO_NETWORK_FUNCTION      = 20000 + 143,
	CURLOPT_CONV_FROM_UTF8_FUNCTION       = 20000 + 144,
	CURLOPT_MAX_SEND_SPEED                = 30000 + 145,
	CURLOPT_MAX_RECV_SPEED                = 30000 + 146,
	CURLOPT_FTP_ALTERNATIVE_TO_USER       = 10000 + 147,
	CURLOPT_SOCKOPTFUNCTION               = 20000 + 148,
	CURLOPT_SOCKOPTDATA                   = 10000 + 149,
	CURLOPT_SSL_SESSIONID_CACHE           =     0 + 150,
	CURLOPT_SSH_AUTH_TYPES                =     0 + 151,
	CURLOPT_SSH_PUBLIC_KEYFILE            = 10000 + 152,
	CURLOPT_SSH_PRIVATE_KEYFILE           = 10000 + 153,
	CURLOPT_FTP_SSL_CCC                   =     0 + 154,
	CURLOPT_TIMEOUT_MS                    =     0 + 155,
	CURLOPT_CONNECTTIMEOUT_MS             =     0 + 156,
	CURLOPT_HTTP_TRANSFER_DECODING        =     0 + 157,
	CURLOPT_HTTP_CONTENT_DECODING         =     0 + 158,
	CURLOPT_NEW_FILE_PERMS                =     0 + 159,
	CURLOPT_NEW_DIRECTORY_PERMS           =     0 + 160,
	CURLOPT_POSTREDIR                     =     0 + 161,
	CURLOPT_SSH_HOST_PUBLIC_KEY_MD5       = 10000 + 162,
	CURLOPT_OPENSOCKETFUNCTION            = 20000 + 163,
	CURLOPT_OPENSOCKETDATA                = 10000 + 164,
	CURLOPT_COPYPOSTFIELDS                = 10000 + 165,
	CURLOPT_PROXY_TRANSFER_MODE           =     0 + 166,
	CURLOPT_SEEKFUNCTION                  = 20000 + 167,
	CURLOPT_SEEKDATA                      = 10000 + 168,
	CURLOPT_CRLFILE                       = 10000 + 169,
	CURLOPT_ISSUERCERT                    = 10000 + 170,
	CURLOPT_ADDRESS_SCOPE                 =     0 + 171,
	CURLOPT_CERTINFO                      =     0 + 172,
	CURLOPT_USERNAME                      = 10000 + 173,
	CURLOPT_PASSWORD                      = 10000 + 174,
	CURLOPT_PROXYUSERNAME                 = 10000 + 175,
	CURLOPT_PROXYPASSWORD                 = 10000 + 176,
	CURLOPT_NOPROXY                       = 10000 + 177,
	CURLOPT_TFTP_BLKSIZE                  =     0 + 178,
	CURLOPT_SOCKS5_GSSAPI_SERVICE         = 10000 + 179,
	CURLOPT_SOCKS5_GSSAPI_NEC             =     0 + 180,
	CURLOPT_PROTOCOLS                     =     0 + 181,
	CURLOPT_REDIR_PROTOCOLS               =     0 + 182,
	CURLOPT_SSH_KNOWNHOSTS                = 10000 + 183,
	CURLOPT_SSH_KEYFUNCTION               = 20000 + 184,
	CURLOPT_SSH_KEYDATA                   = 10000 + 185,
	CURLOPT_MAIL_FROM                     = 10000 + 186,
	CURLOPT_MAIL_RCPT                     = 10000 + 187,
	CURLOPT_FTP_USE_PRET                  =     0 + 188,
	CURLOPT_RTSP_REQUEST                  =     0 + 189,
	CURLOPT_RTSP_SESSION_ID               = 10000 + 190,
	CURLOPT_RTSP_STREAM_URI               = 10000 + 191,
	CURLOPT_RTSP_TRANSPORT                = 10000 + 192,
	CURLOPT_RTSP_CLIENT_CSEQ              =     0 + 193,
	CURLOPT_RTSP_SERVER_CSEQ              =     0 + 194,
	CURLOPT_INTERLEAVEDATA                = 10000 + 195,
	CURLOPT_INTERLEAVEFUNCTION            = 20000 + 196,
	CURLOPT_WILDCARDMATCH                 =     0 + 197,
	CURLOPT_CHUNK_BGN_FUNCTION            = 20000 + 198,
	CURLOPT_CHUNK_END_FUNCTION            = 20000 + 199,
	CURLOPT_FNMATCH_FUNCTION              = 20000 + 200,
	CURLOPT_CHUNK_DATA                    = 10000 + 201,
	CURLOPT_FNMATCH_DATA                  = 10000 + 202,
	CURLOPT_RESOLVE                       = 10000 + 203,
	CURLOPT_TLSAUTH_USERNAME              = 10000 + 204,
	CURLOPT_TLSAUTH_PASSWORD              = 10000 + 205,
	CURLOPT_TLSAUTH_TYPE                  = 10000 + 206,
	CURLOPT_TRANSFER_ENCODING             =     0 + 207,
	CURLOPT_CLOSESOCKETFUNCTION           = 20000 + 208,
	CURLOPT_CLOSESOCKETDATA               = 10000 + 209,
	CURLOPT_GSSAPI_DELEGATION             =     0 + 210,
	CURLOPT_DNS_SERVERS                   = 10000 + 211,
	CURLOPT_ACCEPTTIMEOUT_MS              =     0 + 212,
	CURLOPT_TCP_KEEPALIVE                 =     0 + 213,
	CURLOPT_TCP_KEEPIDLE                  =     0 + 214,
	CURLOPT_TCP_KEEPINTVL                 =     0 + 215,
	CURLOPT_SSL_OPTIONS                   =     0 + 216,
	CURLOPT_MAIL_AUTH                     = 10000 + 217,
	CURLOPT_SASL_IR                       =     0 + 218,
	CURLOPT_XFERINFOFUNCTION              = 20000 + 219,
	CURLOPT_XOAUTH2_BEARER                = 10000 + 220,
	CURLOPT_DNS_INTERFACE                 = 10000 + 221,
	CURLOPT_DNS_LOCAL_IP4                 = 10000 + 222,
	CURLOPT_DNS_LOCAL_IP6                 = 10000 + 223,
	CURLOPT_LOGIN_OPTIONS                 = 10000 + 224,
	CURLOPT_SSL_ENABLE_NPN                =     0 + 225,
	CURLOPT_SSL_ENABLE_ALPN               =     0 + 226,
	CURLOPT_EXPECT_100_TIMEOUT_MS         =     0 + 227,
	CURLOPT_PROXYHEADER                   = 10000 + 228,
	CURLOPT_HEADEROPT                     =     0 + 229,
	CURLOPT_PINNEDPUBLICKEY               = 10000 + 230,
	CURLOPT_UNIX_SOCKET_PATH              = 10000 + 231,
	CURLOPT_SSL_VERIFYSTATUS              =     0 + 232,
	CURLOPT_SSL_FALSESTART                =     0 + 233,
	CURLOPT_PATH_AS_IS                    =     0 + 234,
	CURLOPT_PROXY_SERVICE_NAME            = 10000 + 235,
	CURLOPT_SERVICE_NAME                  = 10000 + 236,
	CURLOPT_PIPEWAIT                      =     0 + 237,
	CURLOPT_DEFAULT_PROTOCOL              = 10000 + 238,
	CURLOPT_STREAM_WEIGHT                 =     0 + 239,
	CURLOPT_STREAM_DEPENDS                = 10000 + 240,
	CURLOPT_STREAM_DEPENDS_E              = 10000 + 241,
	CURLOPT_TFTP_NO_OPTIONS               =     0 + 242,
	CURLOPT_CONNECT_TO                    = 10000 + 243,
	CURLOPT_TCP_FASTOPEN                  =     0 + 244,
	CURLOPT_KEEP_SENDING_ON_ERROR         =     0 + 245,
	CURLOPT_PROXY_CAINFO                  = 10000 + 246,
	CURLOPT_PROXY_CAPATH                  = 10000 + 247,
	CURLOPT_PROXY_SSL_VERIFYPEER          =     0 + 248,
	CURLOPT_PROXY_SSL_VERIFYHOST          =     0 + 249,
	CURLOPT_PROXY_SSLVERSION              =     0 + 250,
	CURLOPT_PROXY_TLSAUTH_USERNAME        = 10000 + 251,
	CURLOPT_PROXY_TLSAUTH_PASSWORD        = 10000 + 252,
	CURLOPT_PROXY_TLSAUTH_TYPE            = 10000 + 253,
	CURLOPT_PROXY_SSLCERT                 = 10000 + 254,
	CURLOPT_PROXY_SSLCERTTYPE             = 10000 + 255,
	CURLOPT_PROXY_SSLKEY                  = 10000 + 256,
	CURLOPT_PROXY_SSLKEYTYPE              = 10000 + 257,
	CURLOPT_PROXY_KEYPASSWD               = 10000 + 258,
	CURLOPT_PROXY_SSL_CIPHER_LIST         = 10000 + 259,
	CURLOPT_PROXY_CRLFILE                 = 10000 + 260,
	CURLOPT_PROXY_SSL_OPTIONS             =     0 + 261,
	CURLOPT_PRE_PROXY                     = 10000 + 262,
	CURLOPT_PROXY_PINNEDPUBLICKEY         = 10000 + 263,
	CURLOPT_ABSTRACT_UNIX_SOCKET          = 10000 + 264,
	CURLOPT_SUPPRESS_CONNECT_HEADERS      =     0 + 265,
	CURLOPT_REQUEST_TARGET                = 10000 + 266,
	CURLOPT_SOCKS5_AUTH                   =     0 + 267,
	CURLOPT_SSH_COMPRESSION               =     0 + 268,
	CURLOPT_MIMEPOST                      = 10000 + 269,
	CURLOPT_TIMEVALUE                     = 30000 + 270,
	CURLOPT_HAPPY_EYEBALLS_TIMEOUT_MS     =     0 + 271,
	CURLOPT_RESOLVER_START_FUNCTION       = 20000 + 272,
	CURLOPT_RESOLVER_START_DATA           = 10000 + 273,
	CURLOPT_HAPROXYPROTOCOL               =     0 + 274,
	CURLOPT_DNS_SHUFFLE_ADDRESSES         =     0 + 275,
	CURLOPT_TLS13_CIPHERS                 = 10000 + 276,
	CURLOPT_PROXY_TLS13_CIPHERS           = 10000 + 277,
	CURLOPT_DISALLOW_USERNAME_IN_URL      =     0 + 278,
	CURLOPT_DOH_URL                       = 10000 + 279,
	CURLOPT_UPLOAD_BUFFERSIZE             =     0 + 280,
	CURLOPT_UPKEEP_INTERVAL_MS            =     0 + 281,
	CURLOPT_CURLU                         = 10000 + 282,
	CURLOPT_TRAILERFUNCTION               = 20000 + 283,
	CURLOPT_TRAILERDATA                   = 10000 + 284,
	CURLOPT_HTTP09_ALLOWED                =     0 + 285,
	CURLOPT_ALTSVC_CTRL                   =     0 + 286,
	CURLOPT_ALTSVC                        = 10000 + 287,
	CURLOPT_MAXAGE_CONN                   =     0 + 288,
	CURLOPT_SASL_AUTHZID                  = 10000 + 289,
	CURLOPT_FILE                          = CURLOPT_WRITEDATA,
	CURLOPT_INFILE                        = CURLOPT_READDATA,
	CURLOPT_WRITEHEADER                   = CURLOPT_HEADERDATA,
	// CURLOPT_WRITEINFO                  = CURLOPT_OBSOLETE40,
	// CURLOPT_CLOSEPOLICY                = CURLOPT_OBSOLETE72,
	CURLOPT_ENCODING                      = CURLOPT_ACCEPT_ENCODING,
} CURLoption;
enum {
	CURLOPT_POST301      = CURLOPT_POSTREDIR,
	CURLOPT_SSLKEYPASSWD = CURLOPT_KEYPASSWD,
	CURLOPT_FTPAPPEND    = CURLOPT_APPEND,
	CURLOPT_FTPLISTONLY  = CURLOPT_DIRLISTONLY,
	CURLOPT_FTP_SSL      = CURLOPT_USE_SSL,
	CURLOPT_SSLCERTPASSWD = CURLOPT_KEYPASSWD,
	CURLOPT_KRB4LEVEL    = CURLOPT_KRBLEVEL,
	CURL_IPRESOLVE_WHATEVER = 0,
	CURL_IPRESOLVE_V4    = 1,
	CURL_IPRESOLVE_V6    = 2,
	CURLOPT_RTSPHEADER   = CURLOPT_HTTPHEADER,
};
enum {
	CURL_HTTPPOST_FILENAME    = (1<<0),
	CURL_HTTPPOST_READFILE    = (1<<1),
	CURL_HTTPPOST_PTRNAME     = (1<<2),
	CURL_HTTPPOST_PTRCONTENTS = (1<<3),
	CURL_HTTPPOST_BUFFER      = (1<<4),
	CURL_HTTPPOST_PTRBUFFER   = (1<<5),
	CURL_HTTPPOST_CALLBACK    = (1<<6),
	CURL_HTTPPOST_LARGE       = (1<<7),
};
struct curl_httppost {
	struct curl_httppost *next;
	char *name;
	long namelength;
	char *contents;
	long contentslength;
	char *buffer;
	long bufferlength;
	char *contenttype;
	struct curl_slist *contentheader;
	struct curl_httppost *more;
	long flags;
	char *showfilename;
	void *userp;
	curl_off_t contentlen;
};
typedef int (*curl_progress_callback)(void *clientp,
												  double dltotal,
												  double dlnow,
												  double ultotal,
												  double ulnow);
typedef int (*curl_xferinfo_callback)(void *clientp,
												  curl_off_t dltotal,
												  curl_off_t dlnow,
												  curl_off_t ultotal,
												  curl_off_t ulnow);
enum {
	CURL_MAX_WRITE_SIZE  = 16384,
	CURL_MAX_HTTP_HEADER = (100*1024),
	CURL_WRITEFUNC_PAUSE = 0x10000001,
};
typedef size_t (*curl_write_callback)(char *buffer,
												  size_t size,
												  size_t nitems,
												  void *outstream);
typedef enum {
	CURLFILETYPE_FILE = 0,
	CURLFILETYPE_DIRECTORY,
	CURLFILETYPE_SYMLINK,
	CURLFILETYPE_DEVICE_BLOCK,
	CURLFILETYPE_DEVICE_CHAR,
	CURLFILETYPE_NAMEDPIPE,
	CURLFILETYPE_SOCKET,
	CURLFILETYPE_DOOR,
	CURLFILETYPE_UNKNOWN
} curlfiletype;
enum {
	CURLFINFOFLAG_KNOWN_FILENAME = (1<<0),
	CURLFINFOFLAG_KNOWN_FILETYPE = (1<<1),
	CURLFINFOFLAG_KNOWN_TIME = (1<<2),
	CURLFINFOFLAG_KNOWN_PERM = (1<<3),
	CURLFINFOFLAG_KNOWN_UID = (1<<4),
	CURLFINFOFLAG_KNOWN_GID = (1<<5),
	CURLFINFOFLAG_KNOWN_SIZE = (1<<6),
	CURLFINFOFLAG_KNOWN_HLINKCOUNT = (1<<7),
};
struct curl_fileinfo {
  char *filename;
  curlfiletype filetype;
  time_t time;
  unsigned int perm;
  int uid;
  int gid;
  curl_off_t size;
  long int hardlinks;
  struct {
	 char *time;
	 char *perm;
	 char *user;
	 char *group;
	 char *target;
  } strings;
  unsigned int flags;
  char  *b_data;
  size_t b_size;
  size_t b_used;
};
enum {
	CURL_CHUNK_BGN_FUNC_OK = 0,
	CURL_CHUNK_BGN_FUNC_FAIL = 1,
	CURL_CHUNK_BGN_FUNC_SKIP = 2,
};
typedef long (*curl_chunk_bgn_callback)(const void *transfer_info,
													 void *ptr,
													 int remains);
enum {
	CURL_CHUNK_END_FUNC_OK = 0,
	CURL_CHUNK_END_FUNC_FAIL = 1,
};
typedef long (*curl_chunk_end_callback)(void *ptr);
enum {
	CURL_FNMATCHFUNC_MATCH = 0,
	CURL_FNMATCHFUNC_NOMATCH = 1,
	CURL_FNMATCHFUNC_FAIL = 2,
};
typedef int (*curl_fnmatch_callback)(void *ptr,
												 const char *pattern,
												 const char *string);
enum {
	CURL_SEEKFUNC_OK     = 0,
	CURL_SEEKFUNC_FAIL   = 1,
	CURL_SEEKFUNC_CANTSEEK = 2,
};
typedef int (*curl_seek_callback)(void *instream,
											 curl_off_t offset,
											 int origin);
enum {
	CURL_READFUNC_ABORT  = 0x10000000,
	CURL_READFUNC_PAUSE  = 0x10000001,
};
typedef size_t (*curl_read_callback)(char *buffer,
												  size_t size,
												  size_t nitems,
												  void *instream);
typedef enum {
  CURLSOCKTYPE_IPCXN,
  CURLSOCKTYPE_ACCEPT,
  CURLSOCKTYPE_LAST
} curlsocktype;
enum {
	CURL_SOCKOPT_OK      = 0,
	CURL_SOCKOPT_ERROR   = 1,
	CURL_SOCKOPT_ALREADY_CONNECTED = 2,
};
typedef int (*curl_sockopt_callback)(void *clientp,
												 curl_socket_t curlfd,
												 curlsocktype purpose);
struct curl_sockaddr {
  int family;
  int socktype;
  int protocol;
  unsigned int addrlen;
};
typedef curl_socket_t
(*curl_opensocket_callback)(void *clientp,
									 curlsocktype purpose,
									 struct curl_sockaddr *address);
typedef int
(*curl_closesocket_callback)(void *clientp, curl_socket_t item);
typedef enum {
	CURLIOE_OK,
	CURLIOE_UNKNOWNCMD,
	CURLIOE_FAILRESTART,
	CURLIOE_LAST
} curlioerr;
enum {
	CURLIOCMD_NOP,
	CURLIOCMD_RESTARTREAD,
	CURLIOCMD_LAST
};
typedef curlioerr (*curl_ioctl_callback)(CURL *handle,
													  int cmd,
													  void *clientp);
typedef void *(*curl_malloc_callback)(size_t size);
typedef void (*curl_free_callback)(void *ptr);
typedef void *(*curl_realloc_callback)(void *ptr, size_t size);
typedef char *(*curl_strdup_callback)(const char *str);
typedef void *(*curl_calloc_callback)(size_t nmemb, size_t size);
typedef enum {
	CURLINFO_TEXT = 0,
	CURLINFO_HEADER_IN,
	CURLINFO_HEADER_OUT,
	CURLINFO_DATA_IN,
	CURLINFO_DATA_OUT,
	CURLINFO_SSL_DATA_IN,
	CURLINFO_SSL_DATA_OUT,
	CURLINFO_END
} curl_infotype;
typedef int (*curl_debug_callback)
		 (CURL *handle,
		  curl_infotype type,
		  char *data,
		  size_t size,
		  void *userptr);
typedef enum {
	CURLE_OK = 0,
	CURLE_UNSUPPORTED_PROTOCOL,
	CURLE_FAILED_INIT,
	CURLE_URL_MALFORMAT,
	CURLE_NOT_BUILT_IN,
	CURLE_COULDNT_RESOLVE_PROXY,
	CURLE_COULDNT_RESOLVE_HOST,
	CURLE_COULDNT_CONNECT,
	CURLE_WEIRD_SERVER_REPLY,
	CURLE_REMOTE_ACCESS_DENIED,
	CURLE_FTP_ACCEPT_FAILED,
	CURLE_FTP_WEIRD_PASS_REPLY,
	CURLE_FTP_ACCEPT_TIMEOUT,
	CURLE_FTP_WEIRD_PASV_REPLY,
	CURLE_FTP_WEIRD_227_FORMAT,
	CURLE_FTP_CANT_GET_HOST,
	CURLE_HTTP2,
	CURLE_FTP_COULDNT_SET_TYPE,
	CURLE_PARTIAL_FILE,
	CURLE_FTP_COULDNT_RETR_FILE,
	CURLE_OBSOLETE20,
	CURLE_QUOTE_ERROR,
	CURLE_HTTP_RETURNED_ERROR,
	CURLE_WRITE_ERROR,
	CURLE_OBSOLETE24,
	CURLE_UPLOAD_FAILED,
	CURLE_READ_ERROR,
	CURLE_OUT_OF_MEMORY,
	CURLE_OPERATION_TIMEDOUT,
	CURLE_OBSOLETE29,
	CURLE_FTP_PORT_FAILED,
	CURLE_FTP_COULDNT_USE_REST,
	CURLE_OBSOLETE32,
	CURLE_RANGE_ERROR,
	CURLE_HTTP_POST_ERROR,
	CURLE_SSL_CONNECT_ERROR,
	CURLE_BAD_DOWNLOAD_RESUME,
	CURLE_FILE_COULDNT_READ_FILE,
	CURLE_LDAP_CANNOT_BIND,
	CURLE_LDAP_SEARCH_FAILED,
	CURLE_OBSOLETE40,
	CURLE_FUNCTION_NOT_FOUND,
	CURLE_ABORTED_BY_CALLBACK,
	CURLE_BAD_FUNCTION_ARGUMENT,
	CURLE_OBSOLETE44,
	CURLE_INTERFACE_FAILED,
	CURLE_OBSOLETE46,
	CURLE_TOO_MANY_REDIRECTS,
	CURLE_UNKNOWN_OPTION,
	CURLE_TELNET_OPTION_SYNTAX,
	CURLE_OBSOLETE50,
	CURLE_OBSOLETE51,
	CURLE_GOT_NOTHING,
	CURLE_SSL_ENGINE_NOTFOUND,
	CURLE_SSL_ENGINE_SETFAILED,
	CURLE_SEND_ERROR,
	CURLE_RECV_ERROR,
	CURLE_OBSOLETE57,
	CURLE_SSL_CERTPROBLEM,
	CURLE_SSL_CIPHER,
	CURLE_SSL_CACERT,
	CURLE_BAD_CONTENT_ENCODING,
	CURLE_LDAP_INVALID_URL,
	CURLE_FILESIZE_EXCEEDED,
	CURLE_USE_SSL_FAILED,
	CURLE_SEND_FAIL_REWIND,
	CURLE_SSL_ENGINE_INITFAILED,
	CURLE_LOGIN_DENIED,
	CURLE_TFTP_NOTFOUND,
	CURLE_TFTP_PERM,
	CURLE_REMOTE_DISK_FULL,
	CURLE_TFTP_ILLEGAL,
	CURLE_TFTP_UNKNOWNID,
	CURLE_REMOTE_FILE_EXISTS,
	CURLE_TFTP_NOSUCHUSER,
	CURLE_CONV_FAILED,
	CURLE_CONV_REQD,
	CURLE_SSL_CACERT_BADFILE,
	CURLE_REMOTE_FILE_NOT_FOUND,
	CURLE_SSH,
	CURLE_SSL_SHUTDOWN_FAILED,
	CURLE_AGAIN,
	CURLE_SSL_CRL_BADFILE,
	CURLE_SSL_ISSUER_ERROR,
	CURLE_FTP_PRET_FAILED,
	CURLE_RTSP_CSEQ_ERROR,
	CURLE_RTSP_SESSION_ERROR,
	CURLE_FTP_BAD_FILE_LIST,
	CURLE_CHUNK_FAILED,
	CURLE_NO_CONNECTION_AVAILABLE,
	CURLE_SSL_PINNEDPUBKEYNOTMATCH,
	CURLE_SSL_INVALIDCERTSTATUS,
	CURLE_HTTP2_STREAM,
	CURLE_RECURSIVE_API_CALL,
	CURLE_AUTH_ERROR,
	CURL_LAST,
	CURLE_OBSOLETE16 = CURLE_HTTP2,
	CURLE_OBSOLETE10 = CURLE_FTP_ACCEPT_FAILED,
	CURLE_OBSOLETE12 = CURLE_FTP_ACCEPT_TIMEOUT,
	CURLE_UNKNOWN_TELNET_OPTION = CURLE_UNKNOWN_OPTION,
	CURLE_OBSOLETE       = CURLE_OBSOLETE50,
	CURLE_BAD_PASSWORD_ENTERED = CURLE_OBSOLETE46,
	CURLE_BAD_CALLING_ORDER = CURLE_OBSOLETE44,
	CURLE_FTP_USER_PASSWORD_INCORRECT = CURLE_OBSOLETE10,
	CURLE_FTP_CANT_RECONNECT = CURLE_OBSOLETE16,
	CURLE_FTP_COULDNT_GET_SIZE = CURLE_OBSOLETE32,
	CURLE_FTP_COULDNT_SET_ASCII = CURLE_OBSOLETE29,
	CURLE_FTP_WEIRD_USER_REPLY = CURLE_OBSOLETE12,
	CURLE_FTP_WRITE_ERROR = CURLE_OBSOLETE20,
	CURLE_LIBRARY_NOT_FOUND = CURLE_OBSOLETE40,
	CURLE_MALFORMAT_USER = CURLE_OBSOLETE24,
	CURLE_SHARE_IN_USE   = CURLE_OBSOLETE57,
	CURLE_URL_MALFORMAT_USER = CURLE_NOT_BUILT_IN,
	CURLE_FTP_ACCESS_DENIED = CURLE_REMOTE_ACCESS_DENIED,
	CURLE_FTP_COULDNT_SET_BINARY = CURLE_FTP_COULDNT_SET_TYPE,
	CURLE_FTP_QUOTE_ERROR = CURLE_QUOTE_ERROR,
	CURLE_TFTP_DISKFULL  = CURLE_REMOTE_DISK_FULL,
	CURLE_TFTP_EXISTS    = CURLE_REMOTE_FILE_EXISTS,
	CURLE_HTTP_RANGE_ERROR = CURLE_RANGE_ERROR,
	CURLE_FTP_SSL_FAILED = CURLE_USE_SSL_FAILED,
	CURLE_OPERATION_TIMEOUTED = CURLE_OPERATION_TIMEDOUT,
	CURLE_HTTP_NOT_FOUND = CURLE_HTTP_RETURNED_ERROR,
	CURLE_HTTP_PORT_FAILED = CURLE_INTERFACE_FAILED,
	CURLE_FTP_COULDNT_STOR_FILE = CURLE_UPLOAD_FAILED,
	CURLE_FTP_PARTIAL_FILE = CURLE_PARTIAL_FILE,
	CURLE_FTP_BAD_DOWNLOAD_RESUME = CURLE_BAD_DOWNLOAD_RESUME,
	CURLE_ALREADY_COMPLETE = 99999,
} CURLcode;
typedef CURLcode (*curl_conv_callback)(char *buffer, size_t length);
typedef CURLcode (*curl_ssl_ctx_callback)(CURL *curl,
														void *ssl_ctx,
														void *userptr);
enum {
	CURLPROXY_HTTP = 0,
	CURLPROXY_HTTP_1_0 = 1,
	CURLPROXY_HTTPS = 2,
	CURLPROXY_SOCKS4 = 4,
	CURLPROXY_SOCKS5 = 5,
	CURLPROXY_SOCKS4A = 6,
	CURLPROXY_SOCKS5_HOSTNAME = 7
};
enum {
	CURLAUTH_NONE        = ((unsigned long)0),
	CURLAUTH_BASIC       = (((unsigned long)1)<<0),
	CURLAUTH_DIGEST      = (((unsigned long)1)<<1),
	CURLAUTH_NEGOTIATE   = (((unsigned long)1)<<2),
	CURLAUTH_GSSNEGOTIATE = CURLAUTH_NEGOTIATE,
	CURLAUTH_NTLM        = (((unsigned long)1)<<3),
	CURLAUTH_DIGEST_IE   = (((unsigned long)1)<<4),
	CURLAUTH_NTLM_WB     = (((unsigned long)1)<<5),
	CURLAUTH_BEARER      = (((unsigned long)1)<<6),
	CURLAUTH_ONLY        = (((unsigned long)1)<<31),
	CURLAUTH_ANY         = (~CURLAUTH_DIGEST_IE),
	CURLAUTH_ANYSAFE     = (~(CURLAUTH_BASIC|CURLAUTH_DIGEST_IE)),
};
enum {
	CURLSSH_AUTH_ANY       = ~0,
	CURLSSH_AUTH_NONE      = 0,
	CURLSSH_AUTH_PUBLICKEY = (1<<0),
	CURLSSH_AUTH_PASSWORD  = (1<<1),
	CURLSSH_AUTH_HOST      = (1<<2),
	CURLSSH_AUTH_KEYBOARD  = (1<<3),
	CURLSSH_AUTH_AGENT     = (1<<4),
	CURLSSH_AUTH_GSSAPI    = (1<<5),
	CURLSSH_AUTH_DEFAULT   = CURLSSH_AUTH_ANY,
};
enum {
	CURLGSSAPI_DELEGATION_NONE = 0,
	CURLGSSAPI_DELEGATION_POLICY_FLAG = (1<<0),
	CURLGSSAPI_DELEGATION_FLAG = (1<<1),
	CURL_ERROR_SIZE      = 256,
};
enum curl_khtype {
	CURLKHTYPE_UNKNOWN,
	CURLKHTYPE_RSA1,
	CURLKHTYPE_RSA,
	CURLKHTYPE_DSS,
	CURLKHTYPE_ECDSA,
	CURLKHTYPE_ED25519
};
struct curl_khkey {
  const char *key;
  size_t len;
  enum curl_khtype keytype;
};
enum curl_khstat {
	CURLKHSTAT_FINE_ADD_TO_FILE,
	CURLKHSTAT_FINE,
	CURLKHSTAT_REJECT,
	CURLKHSTAT_DEFER,
	CURLKHSTAT_LAST
};
enum curl_khmatch {
	CURLKHMATCH_OK,
	CURLKHMATCH_MISMATCH,
	CURLKHMATCH_MISSING,
	CURLKHMATCH_LAST
};
typedef int
  (*curl_sshkeycallback) (CURL *easy,
								  const struct curl_khkey *knownkey,
								  const struct curl_khkey *foundkey,
								  enum curl_khmatch,
								  void *clientp);
enum {
	CURLUSESSL_NONE,
	CURLUSESSL_TRY,
	CURLUSESSL_CONTROL,
	CURLUSESSL_ALL,
	CURLUSESSL_LAST
};
enum {
	CURLSSLOPT_ALLOW_BEAST = (1<<0),
	CURLSSLOPT_NO_REVOKE = (1<<1),
	CURLFTPSSL_NONE      = CURLUSESSL_NONE,
	CURLFTPSSL_TRY       = CURLUSESSL_TRY,
	CURLFTPSSL_CONTROL   = CURLUSESSL_CONTROL,
	CURLFTPSSL_ALL       = CURLUSESSL_ALL,
	CURLFTPSSL_LAST      = CURLUSESSL_LAST,
};
enum {
	CURLFTPSSL_CCC_NONE,
	CURLFTPSSL_CCC_PASSIVE,
	CURLFTPSSL_CCC_ACTIVE,
	CURLFTPSSL_CCC_LAST
};
enum {
	CURLFTPAUTH_DEFAULT,
	CURLFTPAUTH_SSL,
	CURLFTPAUTH_TLS,
	CURLFTPAUTH_LAST
};
enum {
	CURLFTP_CREATE_DIR_NONE,
	CURLFTP_CREATE_DIR,
	CURLFTP_CREATE_DIR_RETRY,
	CURLFTP_CREATE_DIR_LAST
};
enum {
	CURLFTPMETHOD_DEFAULT,
	CURLFTPMETHOD_MULTICWD,
	CURLFTPMETHOD_NOCWD,
	CURLFTPMETHOD_SINGLECWD,
	CURLFTPMETHOD_LAST
};
enum {
	CURLHEADER_UNIFIED   = 0,
	CURLHEADER_SEPARATE  = (1<<0),
};
enum {
	CURLALTSVC_IMMEDIATELY  = (1<<0),
	CURLALTSVC_READONLYFILE = (1<<2),
	CURLALTSVC_H1           = (1<<3),
	CURLALTSVC_H2           = (1<<4),
	CURLALTSVC_H3           = (1<<5)
};
enum {
	CURLPROTO_HTTP       = (1<<0),
	CURLPROTO_HTTPS      = (1<<1),
	CURLPROTO_FTP        = (1<<2),
	CURLPROTO_FTPS       = (1<<3),
	CURLPROTO_SCP        = (1<<4),
	CURLPROTO_SFTP       = (1<<5),
	CURLPROTO_TELNET     = (1<<6),
	CURLPROTO_LDAP       = (1<<7),
	CURLPROTO_LDAPS      = (1<<8),
	CURLPROTO_DICT       = (1<<9),
	CURLPROTO_FILE       = (1<<10),
	CURLPROTO_TFTP       = (1<<11),
	CURLPROTO_IMAP       = (1<<12),
	CURLPROTO_IMAPS      = (1<<13),
	CURLPROTO_POP3       = (1<<14),
	CURLPROTO_POP3S      = (1<<15),
	CURLPROTO_SMTP       = (1<<16),
	CURLPROTO_SMTPS      = (1<<17),
	CURLPROTO_RTSP       = (1<<18),
	CURLPROTO_RTMP       = (1<<19),
	CURLPROTO_RTMPT      = (1<<20),
	CURLPROTO_RTMPE      = (1<<21),
	CURLPROTO_RTMPTE     = (1<<22),
	CURLPROTO_RTMPS      = (1<<23),
	CURLPROTO_RTMPTS     = (1<<24),
	CURLPROTO_GOPHER     = (1<<25),
	CURLPROTO_SMB        = (1<<26),
	CURLPROTO_SMBS       = (1<<27),
	CURLPROTO_ALL        = (~0),
};
enum {
	CURL_HTTP_VERSION_NONE,
	CURL_HTTP_VERSION_1_0,
	CURL_HTTP_VERSION_1_1,
	CURL_HTTP_VERSION_2_0,
	CURL_HTTP_VERSION_2TLS,
	CURL_HTTP_VERSION_2_PRIOR_KNOWLEDGE,
	CURL_HTTP_VERSION_3 = 30,
	CURL_HTTP_VERSION_LAST
};
enum {
	CURL_RTSPREQ_NONE,
	CURL_RTSPREQ_OPTIONS,
	CURL_RTSPREQ_DESCRIBE,
	CURL_RTSPREQ_ANNOUNCE,
	CURL_RTSPREQ_SETUP,
	CURL_RTSPREQ_PLAY,
	CURL_RTSPREQ_PAUSE,
	CURL_RTSPREQ_TEARDOWN,
	CURL_RTSPREQ_GET_PARAMETER,
	CURL_RTSPREQ_SET_PARAMETER,
	CURL_RTSPREQ_RECORD,
	CURL_RTSPREQ_RECEIVE,
	CURL_RTSPREQ_LAST
};
enum CURL_NETRC_OPTION {
	CURL_NETRC_IGNORED,
	CURL_NETRC_OPTIONAL,
	CURL_NETRC_REQUIRED,
	CURL_NETRC_LAST
};
enum {
	CURL_SSLVERSION_DEFAULT,
	CURL_SSLVERSION_TLSv1,
	CURL_SSLVERSION_SSLv2,
	CURL_SSLVERSION_SSLv3,
	CURL_SSLVERSION_TLSv1_0,
	CURL_SSLVERSION_TLSv1_1,
	CURL_SSLVERSION_TLSv1_2,
	CURL_SSLVERSION_TLSv1_3,
	CURL_SSLVERSION_LAST
};
enum {
	CURL_SSLVERSION_MAX_NONE =     0,
	CURL_SSLVERSION_MAX_DEFAULT =  (CURL_SSLVERSION_TLSv1   << 16),
	CURL_SSLVERSION_MAX_TLSv1_0 =  (CURL_SSLVERSION_TLSv1_0 << 16),
	CURL_SSLVERSION_MAX_TLSv1_1 =  (CURL_SSLVERSION_TLSv1_1 << 16),
	CURL_SSLVERSION_MAX_TLSv1_2 =  (CURL_SSLVERSION_TLSv1_2 << 16),
	CURL_SSLVERSION_MAX_TLSv1_3 =  (CURL_SSLVERSION_TLSv1_3 << 16),
	CURL_SSLVERSION_MAX_LAST =     (CURL_SSLVERSION_LAST    << 16)
};
enum CURL_TLSAUTH {
	CURL_TLSAUTH_NONE,
	CURL_TLSAUTH_SRP,
	CURL_TLSAUTH_LAST
};
enum {
	CURL_REDIR_GET_ALL   = 0,
	CURL_REDIR_POST_301  = 1,
	CURL_REDIR_POST_302  = 2,
	CURL_REDIR_POST_303  = 4,
	CURL_REDIR_POST_ALL  = (CURL_REDIR_POST_301|CURL_REDIR_POST_302|CURL_REDIR_POST_303),
};
enum {
	CURL_TIMECOND_NONE,
	CURL_TIMECOND_IFMODSINCE,
	CURL_TIMECOND_IFUNMODSINCE,
	CURL_TIMECOND_LASTMOD,
	CURL_TIMECOND_LAST
};
int (curl_strequal)(const char *s1, const char *s2);
int (curl_strnequal)(const char *s1, const char *s2, size_t n);
char *curl_version(void);
char *curl_easy_escape(CURL *handle, const char *string, int length);
char *curl_escape(const char *string, int length);
char *curl_easy_unescape(CURL *handle, const char *string, int length, int *outlength);
char *curl_unescape(const char *string, int length);
void curl_free(void *p);
CURLcode curl_global_init(long flags);
CURLcode curl_global_init_mem(long flags,
	curl_malloc_callback m,
	curl_free_callback f,
	curl_realloc_callback r,
	curl_strdup_callback s,
	curl_calloc_callback c);
void curl_global_cleanup(void);
struct curl_slist {
	char *data;
	struct curl_slist *next;
};
struct curl_slist *curl_slist_append(struct curl_slist *, const char *);
void curl_slist_free_all(struct curl_slist *);
time_t curl_getdate(const char *p, const time_t *unused);
struct curl_certinfo {
	int num_of_certs;
	struct curl_slist **certinfo;
};
typedef enum {
	CURLSSLBACKEND_NONE = 0,
	CURLSSLBACKEND_OPENSSL = 1,
	CURLSSLBACKEND_GNUTLS = 2,
	CURLSSLBACKEND_NSS = 3,
	CURLSSLBACKEND_OBSOLETE4 = 4,
	CURLSSLBACKEND_GSKIT = 5,
	CURLSSLBACKEND_POLARSSL = 6,
	CURLSSLBACKEND_CYASSL = 7,
	CURLSSLBACKEND_SCHANNEL = 8,
	CURLSSLBACKEND_DARWINSSL = 9,
	CURLSSLBACKEND_AXTLS = 10,
	CURLSSLBACKEND_MBEDTLS = 11,
	CURLSSLBACKEND_MESALINK = 12
} curl_sslbackend;
struct curl_tlssessioninfo {
  curl_sslbackend backend;
  void *internals;
};
enum {
	CURLINFO_STRING      = 0x100000,
	CURLINFO_LONG        = 0x200000,
	CURLINFO_DOUBLE      = 0x300000,
	CURLINFO_SLIST       = 0x400000,
	CURLINFO_PTR         = 0x400000,
	CURLINFO_SOCKET      = 0x500000,
	CURLINFO_OFF_T       = 0x600000,
	CURLINFO_MASK        = 0x0fffff,
	CURLINFO_TYPEMASK    = 0xf00000,
};
typedef enum {
	CURLINFO_NONE,
	CURLINFO_EFFECTIVE_URL             = CURLINFO_STRING + 1,
	CURLINFO_RESPONSE_CODE             = CURLINFO_LONG   + 2,
	CURLINFO_TOTAL_TIME                = CURLINFO_DOUBLE + 3,
	CURLINFO_NAMELOOKUP_TIME           = CURLINFO_DOUBLE + 4,
	CURLINFO_CONNECT_TIME              = CURLINFO_DOUBLE + 5,
	CURLINFO_PRETRANSFER_TIME          = CURLINFO_DOUBLE + 6,
	CURLINFO_SIZE_UPLOAD               = CURLINFO_DOUBLE + 7,
	CURLINFO_SIZE_UPLOAD_T             = CURLINFO_OFF_T  + 7,
	CURLINFO_SIZE_DOWNLOAD             = CURLINFO_DOUBLE + 8,
	CURLINFO_SIZE_DOWNLOAD_T           = CURLINFO_OFF_T  + 8,
	CURLINFO_SPEED_DOWNLOAD            = CURLINFO_DOUBLE + 9,
	CURLINFO_SPEED_DOWNLOAD_T          = CURLINFO_OFF_T  + 9,
	CURLINFO_SPEED_UPLOAD              = CURLINFO_DOUBLE + 10,
	CURLINFO_SPEED_UPLOAD_T            = CURLINFO_OFF_T  + 10,
	CURLINFO_HEADER_SIZE               = CURLINFO_LONG   + 11,
	CURLINFO_REQUEST_SIZE              = CURLINFO_LONG   + 12,
	CURLINFO_SSL_VERIFYRESULT          = CURLINFO_LONG   + 13,
	CURLINFO_FILETIME                  = CURLINFO_LONG   + 14,
	CURLINFO_FILETIME_T                = CURLINFO_OFF_T  + 14,
	CURLINFO_CONTENT_LENGTH_DOWNLOAD   = CURLINFO_DOUBLE + 15,
	CURLINFO_CONTENT_LENGTH_DOWNLOAD_T = CURLINFO_OFF_T  + 15,
	CURLINFO_CONTENT_LENGTH_UPLOAD     = CURLINFO_DOUBLE + 16,
	CURLINFO_CONTENT_LENGTH_UPLOAD_T   = CURLINFO_OFF_T  + 16,
	CURLINFO_STARTTRANSFER_TIME        = CURLINFO_DOUBLE + 17,
	CURLINFO_CONTENT_TYPE              = CURLINFO_STRING + 18,
	CURLINFO_REDIRECT_TIME             = CURLINFO_DOUBLE + 19,
	CURLINFO_REDIRECT_COUNT            = CURLINFO_LONG   + 20,
	CURLINFO_PRIVATE                   = CURLINFO_STRING + 21,
	CURLINFO_HTTP_CONNECTCODE          = CURLINFO_LONG   + 22,
	CURLINFO_HTTPAUTH_AVAIL            = CURLINFO_LONG   + 23,
	CURLINFO_PROXYAUTH_AVAIL           = CURLINFO_LONG   + 24,
	CURLINFO_OS_ERRNO                  = CURLINFO_LONG   + 25,
	CURLINFO_NUM_CONNECTS              = CURLINFO_LONG   + 26,
	CURLINFO_SSL_ENGINES               = CURLINFO_PTR    + 27,
	CURLINFO_COOKIELIST                = CURLINFO_PTR    + 28,
	CURLINFO_LASTSOCKET                = CURLINFO_LONG   + 29,
	CURLINFO_FTP_ENTRY_PATH            = CURLINFO_STRING + 30,
	CURLINFO_REDIRECT_URL              = CURLINFO_STRING + 31,
	CURLINFO_PRIMARY_IP                = CURLINFO_STRING + 32,
	CURLINFO_APPCONNECT_TIME           = CURLINFO_DOUBLE + 33,
	CURLINFO_CERTINFO                  = CURLINFO_PTR    + 34,
	CURLINFO_CONDITION_UNMET           = CURLINFO_LONG   + 35,
	CURLINFO_RTSP_SESSION_ID           = CURLINFO_STRING + 36,
	CURLINFO_RTSP_CLIENT_CSEQ          = CURLINFO_LONG   + 37,
	CURLINFO_RTSP_SERVER_CSEQ          = CURLINFO_LONG   + 38,
	CURLINFO_RTSP_CSEQ_RECV            = CURLINFO_LONG   + 39,
	CURLINFO_PRIMARY_PORT              = CURLINFO_LONG   + 40,
	CURLINFO_LOCAL_IP                  = CURLINFO_STRING + 41,
	CURLINFO_LOCAL_PORT                = CURLINFO_LONG   + 42,
	CURLINFO_TLS_SESSION               = CURLINFO_PTR    + 43,
	CURLINFO_ACTIVESOCKET              = CURLINFO_SOCKET + 44,
	CURLINFO_TLS_SSL_PTR               = CURLINFO_PTR    + 45,
	CURLINFO_HTTP_VERSION              = CURLINFO_LONG   + 46,
	CURLINFO_PROXY_SSL_VERIFYRESULT    = CURLINFO_LONG   + 47,
	CURLINFO_PROTOCOL                  = CURLINFO_LONG   + 48,
	CURLINFO_SCHEME                    = CURLINFO_STRING + 49,
	CURLINFO_TOTAL_TIME_T              = CURLINFO_OFF_T  + 50,
	CURLINFO_NAMELOOKUP_TIME_T         = CURLINFO_OFF_T  + 51,
	CURLINFO_CONNECT_TIME_T            = CURLINFO_OFF_T  + 52,
	CURLINFO_PRETRANSFER_TIME_T        = CURLINFO_OFF_T  + 53,
	CURLINFO_STARTTRANSFER_TIME_T      = CURLINFO_OFF_T  + 54,
	CURLINFO_REDIRECT_TIME_T           = CURLINFO_OFF_T  + 55,
	CURLINFO_APPCONNECT_TIME_T         = CURLINFO_OFF_T  + 56,
	CURLINFO_RETRY_AFTER               = CURLINFO_OFF_T  + 57,
	CURLINFO_HTTP_CODE                 = CURLINFO_RESPONSE_CODE,
	CURLINFO_LASTONE = 57,
} CURLINFO;
enum {
	CURLCLOSEPOLICY_NONE,
	CURLCLOSEPOLICY_OLDEST,
	CURLCLOSEPOLICY_LEAST_RECENTLY_USED,
	CURLCLOSEPOLICY_LEAST_TRAFFIC,
	CURLCLOSEPOLICY_SLOWEST,
	CURLCLOSEPOLICY_CALLBACK,
	CURLCLOSEPOLICY_LAST
};
enum {
	CURL_GLOBAL_SSL      = (1<<0),
	CURL_GLOBAL_WIN32    = (1<<1),
	CURL_GLOBAL_ALL      = (CURL_GLOBAL_SSL|CURL_GLOBAL_WIN32),
	CURL_GLOBAL_NOTHING  = 0,
	CURL_GLOBAL_DEFAULT  = CURL_GLOBAL_ALL,
	CURL_GLOBAL_ACK_EINTR = (1<<2),
};
typedef enum {
	CURL_LOCK_DATA_NONE = 0,
	CURL_LOCK_DATA_SHARE,
	CURL_LOCK_DATA_COOKIE,
	CURL_LOCK_DATA_DNS,
	CURL_LOCK_DATA_SSL_SESSION,
	CURL_LOCK_DATA_CONNECT,
	CURL_LOCK_DATA_PSL,
	CURL_LOCK_DATA_LAST
} curl_lock_data;
typedef enum {
	CURL_LOCK_ACCESS_NONE = 0,
	CURL_LOCK_ACCESS_SHARED = 1,
	CURL_LOCK_ACCESS_SINGLE = 2,
	CURL_LOCK_ACCESS_LAST
} curl_lock_access;
typedef void (*curl_lock_function)(CURL *handle,
											  curl_lock_data data,
											  curl_lock_access locktype,
											  void *userptr);
typedef void (*curl_unlock_function)(CURL *handle,
												 curl_lock_data data,
												 void *userptr);
typedef struct CURLSH CURLSH;
typedef enum {
	CURLSHE_OK,
	CURLSHE_BAD_OPTION,
	CURLSHE_IN_USE,
	CURLSHE_INVALID,
	CURLSHE_NOMEM,
	CURLSHE_NOT_BUILT_IN,
	CURLSHE_LAST
} CURLSHcode;
typedef enum {
	CURLSHOPT_NONE,
	CURLSHOPT_SHARE,
	CURLSHOPT_UNSHARE,
	CURLSHOPT_LOCKFUNC,
	CURLSHOPT_UNLOCKFUNC,
	CURLSHOPT_USERDATA,
	CURLSHOPT_LAST
} CURLSHoption;
CURLSH *curl_share_init(void);
CURLSHcode curl_share_setopt(CURLSH *, CURLSHoption option, ...);
CURLSHcode curl_share_cleanup(CURLSH *);
typedef enum {
	CURLVERSION_FIRST,
	CURLVERSION_SECOND,
	CURLVERSION_THIRD,
	CURLVERSION_FOURTH,
	CURLVERSION_FIFTH,
	CURLVERSION_SIXTH,
	CURLVERSION_LAST,
	CURLVERSION_NOW = CURLVERSION_SIXTH,
} CURLversion;
typedef struct {
	CURLversion   age;
	const char*   version;
	unsigned int  version_num;
	const char*   host;
	int           features;
	const char*   ssl_version;
	long          ssl_version_num;
	const char*   libz_version;
	const char*   const *protocols;
	const char*   ares;
	int           ares_num;
	const char*   libidn;
	int           iconv_ver_num;
	const char*   libssh_version;
	unsigned int  brotli_ver_num;
	const char*   brotli_version;
	unsigned int  nghttp2_ver_num;
	const char*   nghttp2_version;
	const char*   quic_version;
} curl_version_info_data;
enum {
	CURL_VERSION_IPV6         = (1<<0),
	CURL_VERSION_KERBEROS4    = (1<<1),
	CURL_VERSION_SSL          = (1<<2),
	CURL_VERSION_LIBZ         = (1<<3),
	CURL_VERSION_NTLM         = (1<<4),
	CURL_VERSION_GSSNEGOTIATE = (1<<5),
	CURL_VERSION_DEBUG        = (1<<6),
	CURL_VERSION_ASYNCHDNS    = (1<<7),
	CURL_VERSION_SPNEGO       = (1<<8),
	CURL_VERSION_LARGEFILE    = (1<<9),
	CURL_VERSION_IDN          = (1<<10),
	CURL_VERSION_SSPI         = (1<<11),
	CURL_VERSION_CONV         = (1<<12),
	CURL_VERSION_CURLDEBUG    = (1<<13),
	CURL_VERSION_TLSAUTH_SRP  = (1<<14),
	CURL_VERSION_NTLM_WB      = (1<<15),
	CURL_VERSION_HTTP2        = (1<<16),
	CURL_VERSION_GSSAPI       = (1<<17),
	CURL_VERSION_KERBEROS5    = (1<<18),
	CURL_VERSION_UNIX_SOCKETS = (1<<19),
	CURL_VERSION_PSL          = (1<<20),
	CURL_VERSION_HTTPS_PROXY  = (1<<21),
	CURL_VERSION_MULTI_SSL    = (1<<22),
	CURL_VERSION_BROTLI       = (1<<23),
	CURL_VERSION_ALTSVC       = (1<<24),
	CURL_VERSION_HTTP3        = (1<<25),
	CURL_VERSION_ESNI         = (1<<26),
};
curl_version_info_data *curl_version_info(CURLversion);

// easy.h --------------------------------------------------------------------

const char *curl_easy_strerror(CURLcode);
const char *curl_share_strerror(CURLSHcode);
CURLcode curl_easy_pause(CURL *handle, int bitmask);
enum {
	CURLPAUSE_RECV       = (1<<0),
	CURLPAUSE_RECV_CONT  = (0),
	CURLPAUSE_SEND       = (1<<2),
	CURLPAUSE_SEND_CONT  = (0),
	CURLPAUSE_ALL        = (CURLPAUSE_RECV|CURLPAUSE_SEND),
	CURLPAUSE_CONT       = (CURLPAUSE_RECV_CONT|CURLPAUSE_SEND_CONT),
};

CURL *curl_easy_init(void);
CURLcode curl_easy_setopt(CURL *curl, CURLoption option, ...);
CURLcode curl_easy_perform(CURL *curl);
void curl_easy_cleanup(CURL *curl);
CURLcode curl_easy_getinfo(CURL *curl, CURLINFO info, ...);
CURL* curl_easy_duphandle(CURL *curl);
void curl_easy_reset(CURL *curl);
CURLcode curl_easy_recv(CURL *curl, void *buffer, size_t buflen,
												size_t *n);
CURLcode curl_easy_send(CURL *curl, const void *buffer,
												size_t buflen, size_t *n);

// multi.h -------------------------------------------------------------------

typedef struct CURLM CURLM;
typedef enum {
	CURLM_CALL_MULTI_PERFORM = -1,
	CURLM_OK,
	CURLM_BAD_HANDLE,
	CURLM_BAD_EASY_HANDLE,
	CURLM_OUT_OF_MEMORY,
	CURLM_INTERNAL_ERROR,
	CURLM_BAD_SOCKET,
	CURLM_UNKNOWN_OPTION,
	CURLM_ADDED_ALREADY,
	CURLM_LAST
} CURLMcode;
enum {
	CURLM_CALL_MULTI_SOCKET = CURLM_CALL_MULTI_PERFORM,
	CURLPIPE_NOTHING     = 0,
	CURLPIPE_HTTP1       = 1,
	CURLPIPE_MULTIPLEX   = 2,
};
typedef enum {
	CURLMSG_NONE,
	CURLMSG_DONE,
	CURLMSG_LAST
} CURLMSG;
struct CURLMsg {
  CURLMSG msg;
  CURL *easy_handle;
  union {
	 void *whatever;
	 CURLcode result;
  } data;
};
typedef struct CURLMsg CURLMsg;
enum {
	CURL_WAIT_POLLIN     = 0x0001,
	CURL_WAIT_POLLPRI    = 0x0002,
	CURL_WAIT_POLLOUT    = 0x0004,
};
struct curl_waitfd {
  curl_socket_t fd;
  short events;
  short revents;
};
CURLM *curl_multi_init(void);
CURLMcode curl_multi_add_handle(CURLM *multi_handle, CURL *curl_handle);
CURLMcode curl_multi_remove_handle(CURLM *multi_handle, CURL *curl_handle);
CURLMcode curl_multi_fdset(CURLM *multi_handle,
	curl_fd_set *read_fd_set,
	curl_fd_set *write_fd_set,
	curl_fd_set *exc_fd_set,
	int *max_fd);
CURLMcode curl_multi_wait(CURLM *multi_handle,
	struct curl_waitfd extra_fds[],
	unsigned int extra_nfds,
	int timeout_ms,
	int *ret);
CURLMcode curl_multi_perform(CURLM *multi_handle, int *running_handles);
CURLMcode curl_multi_cleanup(CURLM *multi_handle);
CURLMsg *curl_multi_info_read(CURLM *multi_handle, int *msgs_in_queue);
const char *curl_multi_strerror(CURLMcode);
enum {
	CURL_POLL_NONE       = 0,
	CURL_POLL_IN         = 1,
	CURL_POLL_OUT        = 2,
	CURL_POLL_INOUT      = 3,
	CURL_POLL_REMOVE     = 4,
	CURL_CSELECT_IN      = 0x01,
	CURL_CSELECT_OUT     = 0x02,
	CURL_CSELECT_ERR     = 0x04,
};
typedef int (*curl_socket_callback)(CURL *easy, curl_socket_t s, int what, void *userp, void *socketp);
typedef int (*curl_multi_timer_callback)(CURLM *multi, long timeout_ms, void *userp);
CURLMcode curl_multi_socket(CURLM *multi_handle, curl_socket_t s, int *running_handles);
CURLMcode curl_multi_socket_action(CURLM *multi_handle, curl_socket_t s, int ev_bitmask, int *running_handles);
CURLMcode curl_multi_socket_all(CURLM *multi_handle, int *running_handles);
CURLMcode curl_multi_timeout(CURLM *multi_handle, long *milliseconds);
typedef enum {
	CURLMOPT_SOCKETFUNCTION = 20000 + 1,
	CURLMOPT_SOCKETDATA = 10000 + 2,
	CURLMOPT_PIPELINING = 0 + 3,
	CURLMOPT_TIMERFUNCTION = 20000 + 4,
	CURLMOPT_TIMERDATA = 10000 + 5,
	CURLMOPT_MAXCONNECTS = 0 + 6,
	CURLMOPT_MAX_HOST_CONNECTIONS = 0 + 7,
	CURLMOPT_MAX_PIPELINE_LENGTH = 0 + 8,
	CURLMOPT_CONTENT_LENGTH_PENALTY_SIZE = 30000 + 9,
	CURLMOPT_CHUNK_LENGTH_PENALTY_SIZE = 30000 + 10,
	CURLMOPT_PIPELINING_SITE_BL = 10000 + 11,
	CURLMOPT_PIPELINING_SERVER_BL = 10000 + 12,
	CURLMOPT_MAX_TOTAL_CONNECTIONS = 0 + 13,
	CURLMOPT_PUSHFUNCTION = 20000 + 14,
	CURLMOPT_PUSHDATA = 10000 + 15,
	CURLMOPT_LASTENTRY
} CURLMoption;
CURLMcode curl_multi_setopt(CURLM *multi_handle, CURLMoption option, ...);
CURLMcode curl_multi_assign(CURLM *multi_handle, curl_socket_t sockfd, void *sockp);
enum {
	CURL_PUSH_OK         = 0,
	CURL_PUSH_DENY       = 1,
};
struct curl_pushheaders;
char *curl_pushheader_bynum(struct curl_pushheaders *h, size_t num);
char *curl_pushheader_byname(struct curl_pushheaders *h, const char *name);
typedef int (*curl_push_callback)(CURL *parent,
	CURL *easy,
	size_t num_headers,
	struct curl_pushheaders *headers,
	void *userp);

// urlapi.h ------------------------------------------------------------------

typedef enum {
	CURLUE_OK,
	CURLUE_BAD_HANDLE,
	CURLUE_BAD_PARTPOINTER,
	CURLUE_MALFORMED_INPUT,
	CURLUE_BAD_PORT_NUMBER,
	CURLUE_UNSUPPORTED_SCHEME,
	CURLUE_URLDECODE,
	CURLUE_OUT_OF_MEMORY,
	CURLUE_USER_NOT_ALLOWED,
	CURLUE_UNKNOWN_PART,
	CURLUE_NO_SCHEME,
	CURLUE_NO_USER,
	CURLUE_NO_PASSWORD,
	CURLUE_NO_OPTIONS,
	CURLUE_NO_HOST,
	CURLUE_NO_PORT,
	CURLUE_NO_QUERY,
	CURLUE_NO_FRAGMENT
} CURLUcode;
typedef enum {
	CURLUPART_URL,
	CURLUPART_SCHEME,
	CURLUPART_USER,
	CURLUPART_PASSWORD,
	CURLUPART_OPTIONS,
	CURLUPART_HOST,
	CURLUPART_PORT,
	CURLUPART_PATH,
	CURLUPART_QUERY,
	CURLUPART_FRAGMENT,
	CURLUPART_ZONEID /* added in 7.65.0 */
} CURLUPart;
enum {
	CURLU_DEFAULT_PORT       = (1<<0),
	CURLU_NO_DEFAULT_PORT    = (1<<1),
	CURLU_DEFAULT_SCHEME     = (1<<2),
	CURLU_NON_SUPPORT_SCHEME = (1<<3),
	CURLU_PATH_AS_IS         = (1<<4),
	CURLU_DISALLOW_USER      = (1<<5),
	CURLU_URLDECODE          = (1<<6),
	CURLU_URLENCODE          = (1<<7),
	CURLU_APPENDQUERY        = (1<<8),
	CURLU_GUESS_SCHEME       = (1<<9),
	CURLU_NO_AUTHORITY       = (1<<10),
};

typedef struct Curl_URL CURLU;

CURLU *curl_url(void);
void curl_url_cleanup(CURLU *handle);
CURLU *curl_url_dup(CURLU *in);
CURLUcode curl_url_get(CURLU *handle, CURLUPart what, char **part, unsigned int flags);
CURLUcode curl_url_set(CURLU *handle, CURLUPart what, const char *part, unsigned int flags);

// 7.67.0 additions ----------------------------------------------------------

typedef int (*curl_resolver_start_callback)(void *resolver_state, void *reserved, void *userdata);
typedef int (*curl_trailer_callback)(struct curl_slist **list, void *userdata);

typedef struct curl_mime_s      curl_mime;
typedef struct curl_mimepart_s  curl_mimepart;

curl_mime *curl_mime_init(CURL *easy);
void curl_mime_free(curl_mime *mime);
curl_mimepart *curl_mime_addpart(curl_mime *mime);
CURLcode curl_mime_name(curl_mimepart *part, const char *name);
CURLcode curl_mime_filename(curl_mimepart *part, const char *filename);
CURLcode curl_mime_type(curl_mimepart *part, const char *mimetype);
CURLcode curl_mime_encoder(curl_mimepart *part, const char *encoding);
CURLcode curl_mime_data(curl_mimepart *part, const char *data, size_t datasize);
CURLcode curl_mime_filedata(curl_mimepart *part, const char *filename);
CURLcode curl_mime_data_cb(
	curl_mimepart *part,
	curl_off_t datasize,
	curl_read_callback readfunc,
	curl_seek_callback seekfunc,
	curl_free_callback freefunc,
	void *arg);
CURLcode curl_mime_subparts(curl_mimepart *part, curl_mime *subparts);
CURLcode curl_mime_headers(curl_mimepart *part, struct curl_slist *headers, int take_ownership);

typedef struct {
	curl_sslbackend id;
	const char *name;
} curl_ssl_backend;

typedef enum {
	CURLSSLSET_OK = 0,
	CURLSSLSET_UNKNOWN_BACKEND,
	CURLSSLSET_TOO_LATE,
	CURLSSLSET_NO_BACKENDS /* libcurl was built without any SSL support */
} CURLsslset;

CURLsslset curl_global_sslset(curl_sslbackend id, const char *name, const curl_ssl_backend ***avail);
]]
