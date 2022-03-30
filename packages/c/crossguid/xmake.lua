package("crossguid")
    set_homepage("https://github.com/graeme-hill/crossguid")
    set_description("Lightweight cross platform C++ GUID/UUID library")
    set_license("MIT")

    add_urls("https://github.com/graeme-hill/crossguid.git")
    add_versions("master", "40aaf2e0e8fddb67dd2e1dc89091a47f1c417459b5afeeb590292fa041650952")

    if is_plat("macosx") then
        add_patches("master", path.join(os.scriptdir(), "patches", "warnings.patch"), "52546cb4b33bb467bd901d54a1bc97a467b5861ff54c5e39063de9540313adbb")
    elseif is_plat("linux") then
        add_deps("libuuid")
    end

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DCROSSGUID_TESTS:BOOL=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)

        if package:is_plat("windows") then
            if package:config("shared") then
                os.trycp(path.join(package:buildir(), "bin", "**.pdb"), package:installdir("bin"))
            else
                os.trycp(path.join(package:buildir(), "lib", "**.pdb"), package:installdir("lib"))
            end
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <crossguid/guid.hpp>
            auto g = xg::newGuid();
        ]]}))
    end)
