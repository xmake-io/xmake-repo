package("crossguid")
    set_homepage("https://github.com/graeme-hill/crossguid")
    set_description("Lightweight cross platform C++ GUID/UUID library")
    set_license("MIT")

    add_urls("https://github.com/graeme-hill/crossguid.git")
    add_versions("2019.3.29", "ca1bf4b810e2d188d04cb6286f957008ee1b7681")

    -- Apply patch and necessary lib
    if is_plat("macosx", "iphoneos") then
        add_patches("2019.3.29", path.join(os.scriptdir(), "patches", "warnings.patch"), "9953cb5ef68bdffa7cc9cb138a2119dd3460f3055db14a13aecc4dd256104c09")
        add_frameworks("CoreFoundation")
    elseif is_plat("linux") then
        add_deps("libuuid")
    elseif is_plat("windows", "mingw") then
        add_syslinks("ole32")
    end

    add_deps("cmake")

    on_install("windows", "linux", "macosx", "iphoneos", "android", "mingw", function (package)
        local configs = {"-DCROSSGUID_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs, {buildir = "build"})

        if package:is_plat("windows") then
            os.trycp("build/pdb/**.pdb", package:installdir("lib"))
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                auto g = xg::newGuid();
            }
        ]]}, {configs = {languages = "c++17"}, includes = "crossguid/guid.hpp"}))
    end)
