package("make")

    set_kind("binary")
    set_homepage("https://www.gnu.org/software/make/")
    set_description("GNU make tool.")

    add_urls("https://ftp.gnu.org/gnu/make/make-$(version).tar.gz",
             "https://mirrors.ustc.edu.cn/gnu/make/make-$(version).tar.gz",
             "http://mirror.easyname.at/gnu/make/make-$(version).tar.gz")
    add_versions("4.2.1", "e40b8f018c1da64edd1cc9a6fce5fa63b2e707e404e20cad91fbae337c98a5b7")

    on_install("@windows", function(package)
        import("core.tool.toolchain")
        local runenvs = toolchain.load("msvc"):runenvs()
        os.vrunv("build_w32.bat", {}, {envs = runenvs})
        os.cp("WinRel/gnumake.exe", path.join(package:installdir("bin"), "make.exe"))
    end)

    on_install("@macosx", "@linux", function (package)
        -- fix undefined reference to `__alloca'
        if is_subhost("linux") then
            io.replace("glob/glob.c", "!defined __alloca && !defined __GNU_LIBRARY__", "1")
        end
        import("package.tools.autoconf").install(package, {"--disable-dependency-tracking", "--disable-gtk", "--disable-silent-rules"})
    end)

    on_test(function (package)
        os.vrun("make --version")
    end)
