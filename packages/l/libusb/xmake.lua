package("libusb")

    set_homepage("https://libusb.info")
    set_description("A cross-platform library to access USB devices.")

    if is_plat("mingw") then
        add_urls("https://github.com/libusb/libusb/releases/download/$(version).7z", {version = function (version)
            return version .. "/libusb-" .. (version:gsub("v", ""))
        end})
        add_versions("v1.0.24", "620CEC4DBE4868202949294157DA5ADB75C9FBB4F04266146FC833EEF85F90FB")
    else
        add_urls("https://github.com/libusb/libusb/releases/download/$(version).tar.bz2", {version = function (version)
            return version .. "/libusb-" .. (version:gsub("v", ""))
        end})
        add_urls("https://github.com/libusb/libusb.git")
        add_versions("v1.0.24", "7efd2685f7b327326dcfb85cee426d9b871fd70e22caa15bb68d595ce2a2b12a")
    end

    if is_plat("macosx", "linux") then
        add_deps("autoconf", "automake", "libtool", "pkg-config")
        if is_plat("linux") then
            add_deps("eudev")
        end
    end

    if is_plat("macosx") then
        add_frameworks("CoreFoundation", "IOKit")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    on_fetch("linux", "macosx", function(package, opt)
        if opt.system then
            return find_package("pkgconfig::libusb-1.0")
        end
    end)

    add_includedirs("include", "include/libusb-1.0")

    on_install("windows", function (package)
        import("core.tool.toolchain")
        local vsversion = toolchain.load("msvc"):config("vs") or "2019"
        local solutionFiles = {
            "libusb_" .. vsversion .. ".sln",
            "libusb_2019.sln",
            "libusb_2017.sln",
            "libusb_2015.sln",
        }

        local solutionFile
        local oldir = os.cd("msvc")
        for _, file in ipairs(solutionFiles) do
            if os.isfile(file) then
                solutionFile = file
                break
            end
        end
        assert(solutionFile, "solution file not found")

        local arch = package:is_arch("x86") and "Win32" or "x64"
        local mode = package:debug() and "Debug" or "Release"
        local configs = {solutionFile}
        table.insert(configs, "/property:Configuration=" .. mode)
        table.insert(configs, "/property:Platform=" .. arch)
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

    on_install("mingw", function (package)
        os.cp("include/libusb-1.0/*.h",package:installdir("include/libusb-1.0"))
        if package:is_arch("x64", "x86_64") then
            os.cp("MinGW64/dll/*", package:installdir("bin"))
            os.cp("MinGW64/static/*", package:installdir("lib"))
        elseif package:is_arch("x86", "i386") then
            os.cp("MinGW32/dll/*", package:installdir("bin"))
            os.cp("MinGW32/static/*", package:installdir("lib"))
        end
    end)

    on_install("macosx", "linux", "bsd", function (package)
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
