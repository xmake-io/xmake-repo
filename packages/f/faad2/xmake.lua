package("faad2")

    set_homepage("https://sourceforge.net/projects/faac")
    set_description("FAAD2 is a HE, LC, MAIN and LTP profile, MPEG2 and MPEG-4 AAC decoder.")
    set_license("GPL-2.0")

    add_urls("https://github.com/knik0/faad2/archive/refs/tags/$(version).tar.gz", {version = function (version)
        return version:gsub("%.", "_")
    end})
    add_versions("2.10.0", "0c6d9636c96f95c7d736f097d418829ced8ec6dbd899cc6cc82b728480a84bfb")

    if not is_plat("windows") then
        add_deps("autoconf", "automake", "libtool")
    end

    on_install("windows", function (package)
        if package:is_plat("windows") then
            local vs = import("core.tool.toolchain").load("msvc"):config("vs")
            if tonumber(vs) < 2019 then
                raise("Your compiler is too old to use this library.")
            end
        end
        os.cd("project/msvc")
        local configs = {"faad2.sln"}
        table.insert(configs, "/p:Configuration=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "/p:Platform=" .. (package:is_arch("x64") and "x64" or "Win32"))
        import("package.tools.msbuild").build(package, configs)
        os.cp("../../include/*.h", package:installdir("include"))
        os.cd(path.join("bin", package:debug() and "Debug" or "Release"))
        os.cp("faad.exe", package:installdir("bin"))
        if package:config("shared") then
            os.cp("libfaad2_dll.dll", package:installdir("bin"))
            os.cp("libfaad2_dll.lib", package:installdir("lib"))
        else
            os.cp("libfaad.lib", package:installdir("lib"))
        end
        package:addenv("PATH", "bin")
    end)

    on_install("macosx", "linux", function (package)
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        local libtool = package:dep("libtool")
        if libtool then
            os.vrun("autoreconf --force --install -I" .. libtool:installdir("share", "aclocal"))
        else
            os.vrun("autoreconf --force --install")
        end
        import("package.tools.autoconf").install(package, configs)
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        assert(package:has_cfuncs("NeAACDecInit", {includes = "neaacdec.h"}))
    end)
