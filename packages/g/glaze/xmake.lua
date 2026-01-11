package("glaze")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/stephenberry/glaze")
    set_description("Extremely fast, in memory, JSON and interface library for modern C++")
    set_license("MIT")

    add_urls("https://github.com/stephenberry/glaze/archive/refs/tags/$(version).tar.gz",
             "https://github.com/stephenberry/glaze.git")

    add_versions("v7.0.0", "8a6c67d3b3320017100252ad7a84af4f7eb619421e011b3c860ad71f11f7fac9")
    add_versions("v6.1.0", "4ec01e893363701735d1ef3842fa77a74c4a664edaf08d6a1da0e744900d4125")
    add_versions("v6.0.3", "f73f70b813df0bf1536c4bb868aec7c0e55f9160b8798b6fc9d66735ab475ef4")
    add_versions("v6.0.2", "639e058ba7b3be7acb709baf9330a1409383966b86513b33c27df6598053eb9d")
    add_versions("v6.0.1", "fecf2b15c4f375f13d5c84e7b5da79d5f90a76edeeef9501a4d0519eb8a4d6c7")
    add_versions("v6.0.0", "cf7450ceba973349130ce9526dec8b7726e20dd22b0ef1bda4d8eb24df7e103f")
    add_versions("v5.7.1", "c896ec90927a93ea43d33113ca2fd7b62961b870cb7fc12586cc865f335992f7")
    add_versions("v5.6.0", "6f21e4186ce14b5243a5d2e58419f45fda260da2c0fa9ef793a5c46eaa05b2b3")
    add_versions("v5.5.5", "c2ae536d634aa12f49ac7521f169d2891af55b3376648cbb0053daadb78b6ef1")
    add_versions("v5.5.4", "309184e6cf046669f22b336b85a1ab92278a45ad05fce079be4c0f45e19dcbd2")
    add_versions("v5.5.2", "92382568999829a531db5a3800a36d8699674d640d3862fcb7e79ee2879d95ec")
    add_versions("v5.5.1", "a30fedaffca7a0afdfa8e7b6f570fbbdc5fed6b0c8146c7922c0e11252d12404")
    add_versions("v5.5.0", "378ba049e37b4c318fe0bdb2c6803369576707e40bad777959ed706dc361fc6b")
    add_versions("v5.4.1", "a5d578e58fa0e0930eb02bf99ebcb0cb732ce04ce427ec608d773c6f5258e545")
    add_versions("v5.4.0", "b6f7f62dba80b863df16a9370f676bc32f72a2d2ee401952aa9305b202136476")
    add_versions("v5.3.1", "4c7a31abfc37a021a5120e9bc7d9de8116c10ce1470e09f4306c6e5a1a6fb555")
    add_versions("v5.3.0", "5a130dc52d789cd82d52e172d7c2b1fdcc893f3354462ae6b8825f38746f04dd")
    add_versions("v5.2.1", "ae3f7f0c7bd3a800466a030856a3532e0bb4fd9ef757a1123690900d6f8fec2e")
    add_versions("v5.2.0", "761b4bc97482f2e20273b3d180059b870c6996e7f9ab58eecdc675b44044c7da")
    add_versions("v5.1.2", "bf8d7187a05b6c49481ede2bda933c853de97b4ea0bf3f4d3e0b1a68b0ae207e")
    add_versions("v5.1.0", "c91265728918f914a69a935e2d1dbca26d025170b6d338220fc83b698c913f80")
    add_versions("v5.0.2", "ed47ba0b5dcef5a2d2a41b4863e91a3b509c469a70c1a1fed885545d1b672681")
    add_versions("v4.4.3", "d0dd03f156f95860bf9c2957da0704ee0f7651e21089ff34e3d26fa0190e8684")
    add_versions("v4.4.2", "5f9c8efe35491f90755ef7a9d392ddd2ac395fd2e005e3ca61b5daf54ebfc9de")
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

    add_configs("ssl", {description = "Enable SSL support for networking", default = false, type = "boolean"})

    add_deps("cmake")

    on_load(function (package)
        if package:config("ssl") then
            package:add("deps", "openssl3")
            package:add("defines", "GLZ_ENABLE_SSL")
        end
    end)

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
                "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"),
                "-Dglaze_ENABLE_SSL=" .. (package:config("ssl") and "ON" or "OFF")
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
