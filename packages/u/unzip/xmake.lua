package("unzip")

    set_kind("binary")
    set_homepage("http://infozip.sourceforge.net/UnZip.html")
    set_description("UnZip is an extraction utility for archives compressed in .zip format.")

    add_urls("https://github.com/LuaDist/unzip/archive/refs/tags/$(version).zip")
    add_versions("6.0", "44d392d0087f658e4955389c42cac41c02facfac134b9c64d3ac82fb20ea92a7")

    on_install("@windows", "@macosx", "@linux", function (package)
        io.replace("win32/win32.c", "#include \"../unzip.h\"", "#include \"../unzip.h\"\n#ifdef CR\n#undef CR\n#endif", {plain = true})
        io.replace("win32/nt.c", "#include \"../unzip.h\"", "#include \"../unzip.h\"\n#ifdef CR\n#undef CR\n#endif", {plain = true})
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            includes("check_cfuncs.lua")
            check_cfuncs("HAVE_LCHMOD", "lchmod", {includes = "sys/stat.h"})
            target("unzip")
                set_kind("binary")
                if not has_config("__HAVE_LCHMOD") then
                    add_defines("NO_LCHMOD")
                end
                add_files("crc32.c", "crypt.c", "envargs.c", "explode.c", "extract.c")
                add_files("fileio.c", "globals.c", "inflate.c", "list.c", "match.c", "process.c")
                add_files("ttyio.c", "ubz2err.c", "unreduce.c", "unshrink.c", "unzip.c", "zipinfo.c")
                if is_plat("windows") then
                    add_files("win32/*.c", "win32/winapp.rc")
                    add_syslinks("user32", "advapi32")
                else
                    add_files("unix/unix.c")
                    add_defines("UNIX")
                end
                add_includedirs(".")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        os.vrun("unzip --help")
    end)
