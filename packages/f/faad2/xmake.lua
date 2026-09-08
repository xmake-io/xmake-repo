package("faad2")
    set_homepage("https://sourceforge.net/projects/faac/")
    set_description("FAAD2 is a HE, LC, MAIN and LTP profile, MPEG2 and MPEG-4 AAC decoder.")
    set_license("GPL-2.0")

    add_urls("https://github.com/knik0/faad2/archive/refs/tags/$(version).tar.gz", {version = function (version)
        return version:ge("2.10.1") and tostring(version) or (version:gsub("%.", "_"))
    end})
    add_urls("https://github.com/knik0/faad2.git")

    add_versions("2.11.3", "860ab62087e336c1844a70e33196c1790b525fb9a9e7b6ac4fab1a1a4e4d5ce8")
    add_versions("2.11.2", "3fcbd305e4abd34768c62050e18ca0986f7d9c5eca343fb98275418013065c0e")
    add_versions("2.10.0", "0c6d9636c96f95c7d736f097d418829ced8ec6dbd899cc6cc82b728480a84bfb")

    if is_plat("linux", "bsd") then
        add_syslinks("m")
    end

    on_load(function (package)
        if not package:version() or package:version():ge("2.11.0") then
            package:add("deps", "cmake")
            package:add("links", "faad")
        elseif not package:is_plat("windows") then
            package:add("deps", "autoconf", "automake", "libtool")
            package:add("links", "faad")
        end
    end)

    on_install(function (package)
        if not package:version() or package:version():ge("2.11.0") then
            local configs = {"-DFAAD_BUNDLED_MODE=OFF"}
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
            table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
            table.insert(configs, "-DCMAKE_POSITION_INDEPENDENT_CODE=" .. (package:config("pic") ~= false and "ON" or "OFF"))
            if package:is_plat("iphoneos", "wasm") then
                table.insert(configs, "-DFAAD_BUILD_CLI=OFF")
            end
            import("package.tools.cmake").install(package, configs)
            package:addenv("PATH", "bin")
        elseif package:is_plat("windows") then
            local vs = import("core.tool.toolchain").load("msvc"):config("vs")
            if tonumber(vs) < 2019 then
                raise("Your compiler is too old to use this library.")
            end
            os.cd("project/msvc")
            if package:is_arch("arm64") then
                io.replace("faad2.sln", "|x64", "|ARM64", {plain = true})
                for _, vcxproj in ipairs(os.files("*.vcxproj")) do
                    io.replace(vcxproj, "|x64", "|ARM64", {plain = true})
                    io.replace(vcxproj, "<Platform>x64</Platform>", "<Platform>ARM64</Platform>", {plain = true})
                end
            end
            local configs = {"faad2.sln"}
            table.insert(configs, "/p:Configuration=" .. (package:is_debug() and "Debug" or "Release"))
            table.insert(configs, "/p:Platform=" .. (package:is_arch("arm64") and "ARM64" or (package:is_arch("x64") and "x64" or "Win32")))
            import("package.tools.msbuild").build(package, configs)
            os.cp("../../include/*.h", package:installdir("include"))
            os.cd(path.join("bin", package:is_debug() and "Debug" or "Release"))
            os.cp("faad.exe", package:installdir("bin"))
            if package:config("shared") then
                os.cp("libfaad2_dll.dll", package:installdir("bin"))
                os.cp("libfaad2_dll.lib", package:installdir("lib"))
            else
                os.cp("libfaad.lib", package:installdir("lib"))
            end
            package:addenv("PATH", "bin")
        elseif package:is_plat("macosx", "linux") then
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
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("NeAACDecInit", {includes = "neaacdec.h"}))
    end)
