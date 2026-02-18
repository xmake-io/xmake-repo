package("faker-cxx")
    set_homepage("https://cieslarmichal.github.io/faker-cxx/")
    set_description("C++ Faker library for generating fake (but realistic) data.")
    set_license("MIT")

    add_urls("https://github.com/cieslarmichal/faker-cxx/archive/refs/tags/$(version).tar.gz",
             "https://github.com/cieslarmichal/faker-cxx.git", {submodules = false})

    add_versions("v4.3.1", "1fb0d21719097fe2a46ad3c068012e2fe6dcce4b06640e388b9ecdee6fc87f81")
    add_versions("v4.1.0", "e5b8d4b77d82947652d1a1b282573491208ed71b35c2d875084994486962b0fe")
    add_versions("v4.0.1", "ebeac25780878905d0e73cd6a5211bd0b5ce065d06961570f0de7f1a25ec7d9d")
    add_versions("v3.0.0", "63d6846376593e05da690136cabe8e7bf42ddcdd4edad3ae9b48696f86d80468")
    add_versions("v2.0.0", "8a7f5441f4453af868444675878a2d9a74918c1595caa65d537d3ea327e46a49")

    add_deps("cmake")

    if on_check then
        on_check(function (package)
            if package:version() and package:version():ge("4.0.0") then
                if package:is_plat("mingw") then
                    raise("package(faker-cxx v4.0.1) unsupported platform. You can open a pr to fix build error")
                elseif package:is_plat("windows") then
                    local vs_toolset = package:toolchain("msvc"):config("vs_toolset")
                    if vs_toolset then
                        local vs_toolset_ver = import("core.base.semver").new(vs_toolset)
                        local minor = vs_toolset_ver:minor()
                        assert(minor and minor >= 30, "package(faker-cxx) require vs_toolset >= 14.3")
                    end
                end
            end

            assert(package:check_cxxsnippets({test = [[
                #include <concepts>
                #include <ranges>
                #include <format>
                static_assert(std::integral<bool>);
                void test() {
                    const auto v = {4, 1, 3, 2};
                    auto it = std::ranges::find(v, 3);
                    std::format("Hello {}!\n", "world");
                }
            ]]}, {configs = {languages = "c++20"}}), "package(faker-cxx) Require at least C++20.")
        end)
    end

    on_load(function (package)
        if package:version() and package:version():lt("4.0.0") then
            package:add("deps", "fmt")
        end
    end)

    on_install(function (package)
        if not package:config("shared") then
            package:add("defines", "FAKER_CXX_STATIC_DEFINE")
        end

        local configs = {"-DBUILD_TESTING=OFF", "-DUSE_SYSTEM_DEPENDENCIES=ON", "-DUSE_STD_FORMAT=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        if package:version() and package:version():lt("4.0.0") then
            if package:is_plat("windows") and package:config("shared") then
                table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
            end
        end

        local cxflags
        if package:has_tool("cxx", "cl") then
            cxflags = "/utf-8"
        end
        import("package.tools.cmake").install(package, configs, {cxflags = cxflags})
    end)

    on_test(function (package)
        local includes = "faker-cxx/string.h"
        local snippets = [[
            void test() {
                const auto id = faker::string::uuidV4();
            }
        ]]

        local version = package:version()
        if version then
            if version:lt("3.0.0") then
                includes = "faker-cxx/String.h"
            end
            if version:lt("4.0.0") then
                snippets = [[
                    void test() {
                        const auto id = faker::string::uuid();
                    }
                ]]
            end
        end

        assert(package:check_cxxsnippets({test = snippets}, {configs = {languages = "c++20"}, includes = includes}))
    end)
