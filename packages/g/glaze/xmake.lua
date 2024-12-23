package("glaze")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/stephenberry/glaze")
    set_description("Extremely fast, in memory, JSON and interface library for modern C++")
    set_license("MIT")

    add_urls("https://github.com/stephenberry/glaze/archive/refs/tags/$(version).tar.gz",
             "https://github.com/stephenberry/glaze.git")

    add_versions("v4.2.2", "965e32de67e60d185402e8cfe684c6d40c1f018a4fa5e781b11b0cac0817edb9")
    add_versions("v4.0.1", "0026aca33201ee6d3a820fb5926f36ba8c838bfd3120e2e179b0eee62b5bd231")
    add_versions("v3.6.2", "74b14656b7a47c0a03d0a857adf5059e8c2351a7a84623593be0dd16b293216c")
    add_versions("v3.6.0", "d394fed35440bd1cb1a2aec059b967acc43fc04764ecb0915ba24b9f5a9ca0a3")
    add_versions("v3.3.2", "e492d3f662c3c096ce7abac86780af6c84f74c4f19b29223ad92fccc054aafad")
    add_versions("v3.1.7", "388483bb3dfa1fe25c1dfec24f0afd1651e0303833cfa1b7f51020a2569e992a")
    add_versions("v2.9.5", "67fda0fb0cc701451c261bb1e0c94d63bafaaba13390527521e02a034eff085e")
    add_versions("v2.7.0", "8e3ee2ba725137cd4f61bc9ceb74e2225dc22b970da1c5a43d2a6833115adbfc")
    add_versions("v2.6.4", "79aff3370c6fe79be8e1774c4fab3e450a10444b91c2aa15aeebf5f54efedc5d")
    add_versions("v2.5.3", "f4c5eb83c80f1caa0feaa831715e9982203908ea140242cb061aead161e2b09b")
    add_versions("v2.4.4", "98ef6af4209e0b98d449d6d414b7e0d69b7a79f78d1c9efeb9dfeca011c0600c")
    add_versions("v2.4.2", "2593617e874d6afc33158a68843c74d875e8e443b430aef826d69662459b280e")
    add_versions("v2.3.1", "941bf3f8cea5b6a024895d37dceaaaa82071a9178af63e9935a1d9fd80caa451")
    add_versions("v2.2.0", "1d6e36029a58bf8c4bdd035819e1ab02b87d8454dd80fa2f5d46c96a1e6d600c")
    add_versions("v1.3.5", "de5d59cb7f31193d45f67f25d8ced1499df50c0d926a1461432b87f2b2368817")

    add_patches("4.0.1", "https://github.com/stephenberry/glaze/commit/8f35df43bcb1210a0c1e07a68b99608e29ecea43.patch", "66eba4c0eea1469c1bf21b2b6ea31cb320391d1095ffe06c5a7ff3dfda796763")

    add_deps("cmake")

    if on_check then
        on_check(function (package)
            if package:is_plat("windows") then
                local vs_toolset = package:toolchain("msvc"):config("vs_toolset")
                if vs_toolset then
                    local vs_toolset_ver = import("core.base.semver").new(vs_toolset)
                    local minor = vs_toolset_ver:minor()
                    assert(minor and minor >= 30, "package(glaze) require vs_toolset >= 14.3")
                end
            elseif package:is_plat("android") then
                local ndk = package:toolchain("ndk"):config("ndkver")
                assert(ndk and tonumber(ndk) >= 27, "package(glaze) require ndk version >= 27")
            end

            if package:has_tool("cxx", "gcc") then
                assert(package:check_cxxsnippets({test = [[
                    constexpr void f() {
                        static constexpr int g = 1;
                    }
                ]]}, {configs = {languages = "c++2b"}}), "package(glaze) require >= c++23")
            end

            assert(package:check_cxxsnippets({test = [[
                #include <bit>
                #include <cstdint>
                void test() {
                    constexpr double f64v = 19880124.0; 
                    constexpr auto u64v = std::bit_cast<std::uint64_t>(f64v);
                }
            ]]}, {configs = {languages = "c++20"}}), "package(glaze) require >= c++20")
        end)
    end

    on_install(function (package)
        local version = package:version()
        if version and version:ge("2.9.5") then
            if package:has_tool("cxx", "cl") then
                package:add("cxxflags", "/Zc:preprocessor", "/permissive-", "/Zc:lambda")
            end

            import("package.tools.cmake").install(package, {
                "-Dglaze_DEVELOPER_MODE=OFF",
                "-DCMAKE_CXX_STANDARD=23",
                "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release")
            })
        else
            os.cp("include", package:installdir())
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            struct obj_t {
                double x{};
                float y{};
            };
            template <>
            struct glz::meta<obj_t> {
                static constexpr auto value = object("x", &obj_t::x, "y", &obj_t::y);
            };
            void test() {
                std::string buffer{};
                obj_t obj{};
                glz::write_json(obj, buffer);
            }
        ]]}, {configs = {languages = "c++2b"}, includes = "glaze/glaze.hpp"}))
    end)
