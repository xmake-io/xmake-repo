package("folly")

    set_homepage("https://github.com/facebook/folly")
    set_description("An open-source C++ library developed and used at Facebook.")
    set_license("Apache-2.0")

    add_urls("https://github.com/facebook/folly/releases/download/v$(version).00/folly-v$(version).00.zip",
             "https://github.com/facebook/folly.git")
    add_versions("2021.06.28", "477765d43045d82ac6a2750142aed9534cd5efc1fbf2be622bb682a8c02a45a4")
    add_versions("2021.08.02", "03159657ef7a08c1207d90e63f02d4d6b1241dcae49f11a72441c0c269b269fa")
    add_versions("2021.11.01", "2620ad559f1e041f50328c91838cde666d422ed09f23b31bcdbf61e709da5c17")
    add_versions("2022.02.14", "6a50d4cc954f0f77efc85af231ee6b7f676a0d743c12b7080fb03fd3da3ffbf2")
    add_versions("2022.04.25", "7d5cd59613780d7d2b9c946c810bfd6b0d11ed3a8a74c5ab00d4e9de5d1b2104")
    add_versions("2022.08.29", "3adac6d4b203c2917185fd190fc04d615051cb2a4f6b988ddf3c42034efc8d4d")
    add_versions("2023.11.20", "7aabcfc5d85ca88fbd06bca1a7381654ec8b0c31fe919788b8d7c18ba50f38ff")
    add_versions("2024.02.26", "ed7086aa7a3e66e9afd2aeb1ddb746d94dcc0c80b792635cb72cd3622e2de9e3")
    add_versions("2024.03.04", "55fadd809f749b1834d20f1dff9aeb410f39b3e3025218d3b2e014948b58763d")
    add_versions("2024.03.11", "771f638669bdb514f0c66caff404d1df0e65868b65555405eb22a7c9298d3a7a")
    add_versions("2024.03.18", "037bd742b91e35e057d13bedcbdf55328e35805cf91f7bc1ca850a72ba974578")
    add_versions("2024.03.25", "3c57b0d1f1266e935aef1ed54535561fd2eeedc1aa946fbc46871e839014f74c")
    add_versions("2024.04.01", "f09e522c76a5f102c40c54726f6f255b0dc127c78f9c8c9ac117fc0f7ac284bb")
    add_versions("2024.06.10", "27d7f825a9a3469b59a4f0a5ba2edac733407ea8dcc036e7ca9279d803ece1e9")
    add_versions("2024.06.17", "a26cda1cf5f9914f2ff05b5f8e4062d73f5a1ff71ee1911e734dc758313f6d30")
    add_versions("2024.06.24", "05ce0aed45c3a8125334438564364fbf32cd0d80b2a58c010cc821f5f16def50")
    add_versions("2024.07.01", "a619f2759e821d4657aa9f1cae0dedcec2085e656e16a3c458e053a759d2ce83")
    add_versions("2024.07.08", "93c9c7c7e3cb30c1b4437ac3043c05a245383fbb6e558abda704d61f14dc67bd")
    add_versions("2024.07.15", "cbdd4400999c86d7ba271fdf3c15485ec5e250302aa98aebbca6f7e5715e6d8a")
    add_versions("2024.10.07", "8702d7b82d8bde1bebe9ecb50f0e3d4db73a7e128f5d809ac75f69a52c346205")
    add_versions("2025.04.14", "9393cbeeeb417d9be9849388c102a592a8ef39fac1aa0e13798e3b35aea76e68")

    add_patches("<=2022.08.29", path.join(os.scriptdir(), "patches", "2021.06.28", "reorder.patch"), "9a6bf283881580474040cfc7a8e89d461d68b89bae5583d89fff0a3198739980")
    add_patches("<=2022.08.29", path.join(os.scriptdir(), "patches", "2021.06.28", "regex.patch"), "6a77ade9f48dd9966d3f7154e66ca8a5c030ae2b6d335cbe3315784aefd8f495")
    add_patches("<=2025.04.14", path.join(os.scriptdir(), "patches", "2023.11.20", "pkgconfig.patch"), "6838623d453418569853f62ad97c729e802a120c13d804aabba6d6455997e674")
    add_patches("<=2025.04.14", path.join(os.scriptdir(), "patches", "2023.11.20", "msvc.patch"), "1ee01c75528bd42736541022af461e44af3031c01d62c9342006f0abc0f44f2d")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_configs("lzma", {description = "Support LZMA for compression", default = true, type = "boolean"})
    add_configs("libaio", {description = "Support compile with libaio", default = true, type = "boolean"})
    add_configs("liburing", {description = "Support compile with liburing", default = true, type = "boolean"})
    add_configs("libdwarf", {description = "Support compile with libdwarf", default = true, type = "boolean"})

    add_deps("cmake")
    add_deps("boost", {configs = {date_time = true, iostreams = true, context = true, filesystem = true, program_options = true, regex = true, system = true, thread = true}})
    add_deps("libevent", {configs = {openssl = true}})
    add_deps("double-conversion", "fast_float", "gflags", "glog <0.7.0", "zlib", "fmt <11")
    add_deps("bzip2", "lz4", "zstd", {optional = true})
    if is_plat("linux") then
        add_syslinks("pthread")
    end
    if is_plat("macosx") then
        add_syslinks("c++abi")
    end

    on_load(function (package)
        if package:config("lzma") then
            package:add("deps", "xz")
        end
        if package:is_plat("linux") and package:config("libaio") then
            package:add("deps", "libaio")
        end
        if package:is_plat("linux") and package:config("liburing") then
            package:add("deps", "liburing")
        end
        if package:config("libdwarf") then
            package:add("deps", "libdwarf")
        end
    end)

    on_install("windows|x64", "macosx", "linux", function (package)
        local configs = {"-DBUILD_TESTS=OFF",
                         "-DCMAKE_DISABLE_FIND_PACKAGE_Libiberty=ON",
                         "-DCMAKE_DISABLE_FIND_PACKAGE_LibURCU=ON",
                         "-DLIBURCU_FOUND=OFF",
                         "-DBOOST_LINK_STATIC=ON",
                         "-DCMAKE_CXX_STANDARD=17"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DBoost_USE_STATIC_RUNTIME=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test("windows|x64", "macosx", function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <cassert>
            void test() {
                folly::CpuId id;
                assert(folly::kIsArchAmd64 == id.mmx());
            }
        ]]}, {configs = {languages = "c++17"}, includes = "folly/CpuId.h"}))
    end)

    on_test("linux", function (package)
        if package:config("libaio") then
            assert(package:check_cxxsnippets({test = [[
                void test() {
                    folly::AsyncIOOp asyncIOOp;
                }
            ]]}, {configs = {languages = "c++17"}, includes = "folly/experimental/io/AsyncIO.h"}))
        end

        if package:config("liburing") then
            assert(package:check_cxxsnippets({test = [[
                void test() {
                    folly::IoUringOp ioUringOp;
                }
            ]]}, {configs = {languages = "c++17"}, includes = "folly/experimental/io/IoUring.h"}))
        end
    end)
