package("zip")
    set_kind("binary")
    set_homepage("http://www.info-zip.org/Zip.html")
    set_description("Info-ZIP zip utility")

    add_urls("https://github.com/LuaDist/zip.git")
    add_versions("3.0", "f6cfe48f6bc5bf2d505a0e0eb265ce4cb238db89")

    add_deps("cmake")

    on_install("@windows", "@macosx", "@linux", function (package)
        io.replace("zip.h", "#define __zip_h 1", [[#define __zip_h 1
            #if defined(WIN32) || defined(WINDLL)
            #  define WIN32_LEAN_AND_MEAN
            #  include <windows.h>
            #endif
        ]], {plain = true})
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            includes("@builtin/check")
            check_cfuncs("HAVE_LCHMOD", "lchmod", {includes = "sys/stat.h"})
            target("zip")
                set_kind("binary")
                if not has_config("__HAVE_LCHMOD") then
                    add_defines("NO_LCHMOD")
                end
                add_files("crc32.c", "crypt.c", "deflate.c",
                          "fileio.c", "globals.c", "trees.c", "ttyio.c", "util.c",
                          "zip.c", "zipfile.c", "zipup.c")
                if is_plat("windows") then
                    add_files("win32/*.c")
                    add_syslinks("user32", "advapi32")
                    add_defines("WIN32", "NO_ASM")
                else
                    add_files("unix/unix.c")
                    add_defines("UNIX", "NO_OFF_T")
                end
                add_includedirs(".")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        os.vrun("zip --help")
    end)

