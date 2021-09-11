package("gf")

    set_homepage("https://gamedevframework.github.io")
    set_description("A C++17 framework for 2D games")
    set_license("zlib")

    set_urls("https://github.com/GamedevFramework/gf/archive/refs/tags/$(version).tar.gz",
             "https://github.com/GamedevFramework/gf.git")
    add_versions("v0.21.0", "1b8a35e8eae753315a6e0f7c5fab1266fad500bf20356d7a85c1938ee4b03853")
    add_patches("v0.21.0", path.join(os.scriptdir(), "patches", "v0.21.0", "fix_cmake.patch"), "f1d8fa0bbb25123b28e9b2842da07604238b77e51b918260a369f97c2f694c89")

    add_extsources("vcpkg::gamedev-framework")

    add_deps("cmake >=3.10.2", "libsdl >=2.0.8", "freetype >=2.9.1", "zlib >=1.2.11", "pugixml >=1.8.1", "stb")
    add_deps("boost >=1.65", {configs = {exception = true}})

    on_load(function (package)
        if not package:config("shared") then
            package:add("defines", "GF_STATIC")
        end
    end)

    on_install("windows", "linux", function (package)
        local configs = {"-DGF_BUILD_DOCUMENTATION=OFF", "-DGF_BUILD_EXAMPLES=OFF", "-DBUILD_TESTING=OFF", "-DGF_USE_EMBEDDED_LIBS=OFF"}
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DGF_DEBUG=" .. (package:debug() and "ON" or "OFF"))

        import("package.tools.cmake").install(package, configs, {packagedeps={"zlib"}})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            void test() {
                gf::Library lib;
                std::cout << "Plaform: " << gf::SystemInfo::getPlatformName() << '\n';
                std::cout << "CPU count: " << gf::SystemInfo::getCpuCount() << '\n';
                std::cout << "RAM size: " << gf::SystemInfo::getSystemRamSize() << " MiB\n";
                std::cout << "Cache line size: " << gf::SystemInfo::getCpuCacheLineSize() << " kiB\n";
            }
        ]]}, {configs = {languages = "c++17"}, includes = {"gf/Library.h", "gf/SystemInfo.h"}}))
    end)
