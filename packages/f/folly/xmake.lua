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

    add_patches("<=2022.08.29", path.join(os.scriptdir(), "patches", "2021.06.28", "reorder.patch"), "9a6bf283881580474040cfc7a8e89d461d68b89bae5583d89fff0a3198739980")
    add_patches("<=2022.08.29", path.join(os.scriptdir(), "patches", "2021.06.28", "regex.patch"), "6a77ade9f48dd9966d3f7154e66ca8a5c030ae2b6d335cbe3315784aefd8f495")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")
    add_deps("boost", {configs = {context = true, filesystem = true, program_options = true, regex = true, system = true, thread = true}})
    add_deps("libevent", {configs = {openssl = true}})
    add_deps("double-conversion", "gflags", "glog", "zlib", "fmt")
    add_deps("bzip2", "lz4", "zstd", {optional = true})
    if is_plat("linux") then
        add_syslinks("pthread")
    end

    on_install("windows|x64", "linux", "macosx", function (package)
        local configs = {"-DBUILD_TESTS=OFF",
                         "-DCMAKE_DISABLE_FIND_PACKAGE_LibDwarf=ON",
                         "-DCMAKE_DISABLE_FIND_PACKAGE_Libiberty=ON",
                         "-DCMAKE_DISABLE_FIND_PACKAGE_LibAIO=ON",
                         "-DCMAKE_DISABLE_FIND_PACKAGE_LibURCU=ON",
                         "-DLIBAIO_FOUND=OFF",
                         "-DLIBURCU_FOUND=OFF",
                         "-DBOOST_LINK_STATIC=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DBoost_USE_STATIC_RUNTIME=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <cassert>
            void test() {
                folly::CpuId id;
                assert(folly::kIsArchAmd64 == id.mmx());
            }
        ]]}, {configs = {languages = "c++17"}, includes = "folly/CpuId.h"}))
    end)
