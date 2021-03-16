package("libusb")

    set_homepage("https://libusb.info")
    set_description("A cross-platform library to access USB devices.")

    set_urls("https://github.com/libusb/libusb/archive/$(version).tar.gz",
             "https://github.com/libusb/libusb.git")
    add_versions("v1.0.24", "b7724c272dfc5713dce88ff717efd60f021ca5b7c8e30f08ebb2c42d2eea08ae")
    add_versions("v1.0.23", "02620708c4eea7e736240a623b0b156650c39bfa93a14bcfa5f3e05270313eba")

    if is_plat("macosx", "linux") then
        add_deps("autoconf", "automake", "libtool", "pkg-config")
        if is_plat("linux") then
            add_deps("eudev")
        end
    end

    if is_plat("macosx") then
        add_frameworks("CoreFoundation", "IOKit")
    elseif is_plat("linux") then
        add_syslinks("pthread")
    end

    -- it will be provided in xmake v2.5.2
    if on_fetch then
        on_fetch("linux", "macosx", function(package, opt)
            if opt.system then
                return find_package("pkgconfig::libusb-1.0")
            end
        end)
    end

    add_includedirs("include", "include/libusb-1.0")

    on_install("windows", function (package)
        import("core.tool.toolchain")
        local arch = package:is_arch("x86") and "Win32" or "x64"
        local mode = package:debug() and "Debug" or "Release"
        local vs = toolchain.load("msvc"):config("vs") or "2019"
        local configs = {"libusb_" .. vs .. ".sln"}
        table.insert(configs, "/property:Configuration=" .. mode)
        table.insert(configs, "/property:Platform=" .. arch)
        local oldir = os.cd("msvc")
        import("package.tools.msbuild").build(package, configs)
        os.cd(oldir)
        os.vcp("libusb/*.h", package:installdir("include/libusb-1.0"))
        if package:config("shared") then
            os.vcp(path.join(arch, mode, "dll/libusb-1.0.dll"), package:installdir("lib"))
            os.vcp(path.join(arch, mode, "dll/libusb-1.0.lib"), package:installdir("lib"))
        else
            os.vcp(path.join(arch, mode, "lib/libusb-1.0.lib"), package:installdir("lib"))
        end
    end)

    on_install("macosx", "linux", function (package)
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        local cflags, ldflags
        if package:is_plat("linux") then
            cflags = "-I" .. package:dep("eudev"):installdir("include")
            ldflags = "-L" .. package:dep("eudev"):installdir("lib")
        end
        import("package.tools.autoconf").install(package, configs, {cflags = cflags, ldflags = ldflags})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("libusb_init", {includes = "libusb-1.0/libusb.h"}))
    end)
