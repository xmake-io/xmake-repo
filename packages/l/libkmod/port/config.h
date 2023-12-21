/* config.h.  Generated from config.h.in by configure.  */
/* config.h.in.  Generated from configure.ac by autoheader.  */

/* Debug messages. */
/* #undef ENABLE_DEBUG */

/* Experimental features. */
/* #undef ENABLE_EXPERIMENTAL */

/* System logging. */
#define ENABLE_LOGGING 1

/* Enable openssl for modinfo. */
/* #undef ENABLE_OPENSSL */

/* Enable Xz for modules. */
/* #undef ENABLE_XZ */

/* Enable zlib for modules. */
/* #undef ENABLE_ZLIB */

/* Define to 1 if you have the declaration of `be32toh', and to 0 if you
   don't. */
#define HAVE_DECL_BE32TOH 1

/* Define to 1 if you have the declaration of `strndupa', and to 0 if you
   don't. */
/* #define HAVE_DECL_STRNDUPA */

/* Define to 1 if you have the <dlfcn.h> header file. */
#define HAVE_DLFCN_H 1

/* Define to 1 if you have the `finit_module' function. */
/* #undef HAVE_FINIT_MODULE */

/* Define to 1 if you have the <inttypes.h> header file. */
#define HAVE_INTTYPES_H 1

/* Define to 1 if you have the <linux/module.h> header file. */
/* #undef HAVE_LINUX_MODULE_H */

/* Define to 1 if you have the <memory.h> header file. */
#define HAVE_MEMORY_H 1

/* Define if _Noreturn is available */
#define HAVE_NORETURN 1

/* Define to 1 if you have the `secure_getenv' function. */
#define HAVE_SECURE_GETENV 1

/* Define if _Static_assert() is available */
#define HAVE_STATIC_ASSERT 1

/* Define to 1 if you have the <stdint.h> header file. */
#define HAVE_STDINT_H 1

/* Define to 1 if you have the <stdlib.h> header file. */
#define HAVE_STDLIB_H 1

/* Define to 1 if you have the <strings.h> header file. */
#define HAVE_STRINGS_H 1

/* Define to 1 if you have the <string.h> header file. */
#define HAVE_STRING_H 1

/* Define to 1 if `st_mtim' is a member of `struct stat'. */
/*#define HAVE_STRUCT_STAT_ST_MTIM 1*/

/* Define to 1 if you have the <sys/stat.h> header file. */
#define HAVE_SYS_STAT_H 1

/* Define to 1 if you have the <sys/types.h> header file. */
#define HAVE_SYS_TYPES_H 1

/* Define to 1 if you have the <unistd.h> header file. */
#define HAVE_UNISTD_H 1

/* Define to 1 if compiler has __builtin_clz() builtin function */
#define HAVE___BUILTIN_CLZ 1

/* Define to 1 if compiler has __builtin_types_compatible_p() builtin function
   */
#define HAVE___BUILTIN_TYPES_COMPATIBLE_P 1

/* Define to 1 if compiler has __builtin_uaddll_overflow() builtin function */
#define HAVE___BUILTIN_UADDLL_OVERFLOW 0

/* Define to 1 if compiler has __builtin_uaddl_overflow() builtin function */
#define HAVE___BUILTIN_UADDL_OVERFLOW 0

/* Define to 1 if you have the `__secure_getenv' function. */
/* #undef HAVE___SECURE_GETENV */

/* Define to 1 if you have the `__xstat' function. */
#define HAVE___XSTAT 1

/* Features in this build */
#define KMOD_FEATURES "-XZ -ZLIB -OPENSSL -EXPERIMENTAL"

/* Define to the sub-directory where libtool stores uninstalled libraries. */
#define LT_OBJDIR ".libs/"

/* Name of package */
#define PACKAGE "kmod"

/* Define to the address where bug reports for this package should be sent. */
#define PACKAGE_BUGREPORT "linux-modules@vger.kernel.org"

/* Define to the full name of this package. */
#define PACKAGE_NAME "kmod"

/* Define to the full name and version of this package. */
#define PACKAGE_STRING "kmod 26"

/* Define to the one symbol short name of this package. */
#define PACKAGE_TARNAME "kmod"

/* Define to the home page for this package. */
#define PACKAGE_URL "http://git.kernel.org/?p=utils/kernel/kmod/kmod.git"

/* Define to the version of this package. */
#define PACKAGE_VERSION "26"

/* Define to 1 if you have the ANSI C header files. */
#define STDC_HEADERS 1

/* Enable extensions on AIX 3, Interix.  */
#ifndef _ALL_SOURCE
# define _ALL_SOURCE 1
#endif
/* Enable GNU extensions on systems that have them.  */
#ifndef _GNU_SOURCE
# define _GNU_SOURCE 1
#endif
/* Enable threading extensions on Solaris.  */
#ifndef _POSIX_PTHREAD_SEMANTICS
# define _POSIX_PTHREAD_SEMANTICS 1
#endif
/* Enable extensions on HP NonStop.  */
#ifndef _TANDEM_SOURCE
# define _TANDEM_SOURCE 1
#endif
/* Enable general extensions on Solaris.  */
#ifndef __EXTENSIONS__
# define __EXTENSIONS__ 1
#endif


/* Version number of package */
#define VERSION "26"

/* Enable large inode numbers on Mac OS X 10.5.  */
#ifndef _DARWIN_USE_64_BIT_INODE
# define _DARWIN_USE_64_BIT_INODE 1
#endif

/* Number of bits in a file offset, on hosts where this is settable. */
/* #undef _FILE_OFFSET_BITS */

/* Define for large files, on AIX-style hosts. */
/* #undef _LARGE_FILES */

/* Define to 1 if on MINIX. */
/* #undef _MINIX */

/* Define to 2 if the system does not provide POSIX.1 features except with
   this defined. */
/* #undef _POSIX_1_SOURCE */

/* Define to 1 if you need to in order for `stat' and other things to work. */
/* #undef _POSIX_SOURCE */

#if defined(__APPLE__)

#define get_current_dir_name()	getwd(malloc(128))
#define strndupa(_s,_l)        strdup(_s)
char* basename(const char*);
#define init_module	darwin_init_module
#define delete_module	darwin_delete_module
#define program_invocation_short_name "depmod"
#include <endian-darwin.h>
#else
#include <endian.h>

#endif

#if defined(__ANDROID__)
#include <stdlib.h>
#include <unistd.h>
static inline char *get_current_dir_name(void)
{
    return getcwd(malloc(PATH_MAX), PATH_MAX);
}
#endif
