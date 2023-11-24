package("make")

    set_kind("binary")
    set_homepage("https://www.gnu.org/software/make/")
    set_description("GNU make tool.")

    add_urls("https://ftpmirror.gnu.org/gnu/make/make-$(version).tar.gz",
             "https://ftp.gnu.org/gnu/make/make-$(version).tar.gz",
             "https://mirrors.ustc.edu.cn/gnu/make/make-$(version).tar.gz",
             "http://mirror.easyname.at/gnu/make/make-$(version).tar.gz")
    add_versions("4.2.1", "e40b8f018c1da64edd1cc9a6fce5fa63b2e707e404e20cad91fbae337c98a5b7")
    add_versions("4.3", "e05fdde47c5f7ca45cb697e973894ff4f5d79e13b750ed57d7b66d8defc78e19")
    add_versions("4.4.1", "dd16fb1d67bfab79a72f5e8390735c49e3e8e70b4945a15ab1f81ddb78658fb3")

    if is_host("linux") then
        add_extsources("pacman::make", "apt::make")
    elseif is_host("macosx") then
        add_extsources("brew::make")
    end

    on_install("@windows", function(package)
        import("core.tool.toolchain")
        local runenvs = toolchain.load("msvc", {plat = "windows", arch = os.arch()}):runenvs()
        os.vrunv("build_w32.bat", {}, {envs = runenvs})
        os.cp("WinRel/gnumake.exe", path.join(package:installdir("bin"), "make.exe"))
    end)

    on_install("@macosx", "@linux", function (package)
        import("package.tools.autoconf").install(package, {"--disable-dependency-tracking", "--disable-gtk", "--disable-silent-rules"})
    end)

    on_test(function (package)
        os.vrun("make --version")
    end)
