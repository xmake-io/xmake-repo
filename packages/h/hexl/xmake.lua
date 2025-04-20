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

    if on_check then
        on_check(function (package)
            if not package:is_arch("x86_64", "x64") then
                raise("package(hexl) only support x86_64 arch")
            end
        end)
    end

    on_load(function (package)
        if package:is_debug() then
            package:add("deps", "easyloggingpp")
            package:add("deps", (is_subhost("windows") and "pkgconf") or "pkg-config")
            package:add("patches", "1.2.5", "patches/1.2.5/cmake-find-easyloggingpp.patch", "7b239bebc13cd9548334b4dfcc84f1a11895c37e08b414d87e5ce81c944fb239")
        end
    end)

    on_install("!wasm", function (package)
        os.rmdir("cmake/third-party")
        io.replace("CMakeLists.txt", "set(CMAKE_POSITION_INDEPENDENT_CODE ON)", "", {plain = true})
        io.replace("hexl/CMakeLists.txt", "set_target_properties(hexl PROPERTIES POSITION_INDEPENDENT_CODE ON)", "", {plain = true})
        if package:is_cross() then
            io.replace("hexl/CMakeLists.txt", "-march=native", "", {plain = true})
        end
        io.replace("cmake/hexl/hexl-util.cmake", "if(HEXL_DEBUG AND UNIX)", "if(0)", {plain = true})
        io.replace("cmake/hexl/hexl-util.cmake", "if (CAN_COMPILE AND CAN_RUN STREQUAL 0)", "if(CAN_COMPILE)", {plain = true})
        io.replace("cmake/hexl/hexl-util.cmake", "try_run(CAN_RUN CAN_COMPILE", "try_compile(CAN_COMPILE", {plain = true})

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
