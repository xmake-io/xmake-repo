package("hexl")
    set_homepage("https://intel.github.io/hexl")
    set_description("Intel:registered: Homomorphic Encryption Acceleration Library accelerates modular arithmetic operations used in homomorphic encryption")
    set_license("Apache-2.0")

    add_urls("https://github.com/intel/hexl/archive/refs/tags/$(version).tar.gz",
             "https://github.com/intel/hexl.git")

    add_versions("v1.2.5", "3692e6e6183dbc49253e51e86c3e52e7affcac925f57db0949dbb4d34b558a9a")

    add_configs("experimental", {description = "Enable experimental features", default = false, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("pthread", "m")
    end

    add_deps("cmake")
    add_deps("cpu-features")

    on_load(function (package)
        if package:is_debug() then
            package:add("deps", "easyloggingpp")
            package:add("deps", (is_subhost("windows") and "pkgconf") or "pkg-config")
            package:add("patches", "1.2.5", "patches/1.2.5/cmake-find-easyloggingpp.patch", "d284399824952840318e53599978bff6491e3e95f41fae7ccd584d2e6c1fa52d")
        end
    end)

    on_install(function (package)
        os.rmdir("cmake/third-party")
        io.replace("CMakeLists.txt", "set(CMAKE_POSITION_INDEPENDENT_CODE ON)", "", {plain = true})
        io.replace("hexl/CMakeLists.txt", "set_target_properties(hexl PROPERTIES POSITION_INDEPENDENT_CODE ON)", "", {plain = true})
        if package:is_cross() then
            io.replace("hexl/CMakeLists.txt", "-march=native", "", {plain = true})
        end

        local configs = {"-DHEXL_BENCHMARK=OFF", "-DHEXL_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DHEXL_SHARED_LIB=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_COMPILE_PDB_OUTPUT_DIRECTORY=''")
            if package:config("shared") then
                table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
            end
        end
        table.insert(configs, "-DHEXL_EXPERIMENTAL=" .. (package:config("experimental") and "ON" or "OFF"))
        if package:is_debug() then
            local dir = path.unix(package:dep("easyloggingpp"):installdir("lib/cmake"))
            table.insert(configs, "-DCMAKE_MODULE_PATH=" .. dir)
        end
        import("package.tools.cmake").install(package, configs)

        if package:is_plat("windows") and package:is_debug() then
            local dir = package:installdir(package:config("shared") and "bin" or "lib")
            os.vcp(path.join(package:buildir(), "**.pdb"), dir)
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                uint64_t modulus = 10;
                uint64_t op1[]{1, 2, 3, 4, 5, 6, 7, 8};
                uint64_t op2[]{1, 3, 5, 7, 2, 4, 6, 8};
                uint64_t exp_out[]{2, 5, 8, 1, 7, 0, 3, 6};

                intel::hexl::EltwiseAddMod(op1, op1, op2, std::size(op1), modulus);
            }
        ]]}, {configs = {languages = "c++17"}, includes = {"hexl/hexl.hpp"}}))
    end)
