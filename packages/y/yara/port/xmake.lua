add_rules("mode.debug", "mode.release")
set_languages("c11")

add_requires("openssl3")

-- yara has no upstream CMakeLists.txt (autotools + MSVC .vcxproj only), so we
-- compile libyara directly. The bison/flex outputs are pre-generated in the
-- release tarballs, hence no lexer/parser generator is needed here.
target("yara")
    set_kind("$(kind)")
    add_includedirs(".", "libyara", "libyara/include")
    add_files("libyara/*.c")
    add_files("libyara/tlshc/*.c")
    add_files(
        "libyara/modules/console/console.c",
        "libyara/modules/dex/dex.c",
        "libyara/modules/dotnet/dotnet.c",
        "libyara/modules/elf/elf.c",
        "libyara/modules/hash/hash.c",
        "libyara/modules/math/math.c",
        "libyara/modules/macho/macho.c",
        "libyara/modules/pe/pe.c",
        "libyara/modules/pe/pe_utils.c",
        "libyara/modules/pe/authenticode-parser/*.c",
        "libyara/modules/string/string.c",
        "libyara/modules/tests/tests.c",
        "libyara/modules/time/time.c"
    )

    -- modules are only registered by libyara/modules/module_list when the
    -- matching macro is defined, so keep these in sync with the file list above
    add_defines("HAVE_LIBCRYPTO", "HASH_MODULE", "MACHO_MODULE", "DEX_MODULE", "DOTNET_MODULE")
    -- tls_h defines nothing by default; the official MSVC project uses these
    add_defines("BUCKETS_128", "CHECKSUM_1B")

    -- shared libraries export through the upstream YR_API mechanism instead of
    -- utils.symbols.export_all, which is a no-op outside of windows/dll
    if is_kind("shared") then
        add_defines("YR_BUILDING_DLL")
        add_defines("YR_IMPORTING_DLL", {public = true})
    end

    if is_plat("windows", "mingw", "msys", "cygwin") then
        add_files("libyara/proc/windows.c")
        add_defines("USE_WINDOWS_PROC")
        add_syslinks("crypt32", "ws2_32")
    elseif is_plat("macosx") then
        add_files("libyara/proc/mach.c")
        add_defines("USE_MACH_PROC")
        add_syslinks("pthread")
    elseif is_plat("linux", "linuxbsd") then
        add_files("libyara/proc/linux.c")
        add_defines("USE_LINUX_PROC", "HAVE_CLOCK_GETTIME")
        add_syslinks("pthread", "dl")
    else
        -- freebsd/openbsd/android/iphoneos/wasm/cross: no process scanning.
        -- note iphoneos deliberately lands here: the iOS SDK ships
        -- mach/mach_vm.h as a stub that fails to compile ("mach_vm.h unsupported")
        add_files("libyara/proc/none.c")
        add_defines("USE_NO_PROC")
        add_syslinks("pthread")
    end

    if not is_plat("windows", "mingw", "msys", "cygwin") then
        -- libyara/mem.c uses strdup()/strndup() and proc/linux.c uses
        -- major()/minor() from <sys/sysmacros.h>; a strict -std=c11 mode hides
        -- both unless _GNU_SOURCE is set. Mirrors upstream AM_CFLAGS.
        add_defines("_GNU_SOURCE", "HAVE_STDBOOL_H")
        add_syslinks("m")
        -- only release builds hide internals upstream, YR_API keeps the API public
        if is_mode("release") then
            add_cflags("-fvisibility=hidden")
        end
    end

    add_packages("openssl3")
    add_headerfiles("libyara/include/yara.h")
    add_headerfiles("libyara/include/yara/*.h", {prefixdir = "yara"})
