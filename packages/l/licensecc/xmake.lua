package("licensecc")
    set_homepage("https://open-license-manager.github.io/licensecc")
    set_description("Copy protection, licensing library and license generator for Windows and Linux.")
    set_license("BSD 3-Clause")
    add_urls("https://github.com/open-license-manager/licensecc.git", {submodules = true})
    add_versions("v2.0.0", "7fc7843f9e6d700135ed1ee63d0f252b820c67da0b0d637d04cd4ea383339145")

    add_configs("key_path", {description = "public_key.h and private_key.rsa will be automatically generated if they does not exist.", default = "", type = "string"})

    add_deps("cmake")
    add_deps("openssl")
    add_deps("zlib")
    add_deps("boost", {configs = {date_time = true, filesystem = true, program_options = true, system = true, unit_test_framework = true}})
    
    add_includedirs("include", "include/licensecc/DEFAULT")
    add_linkdirs("lib/licensecc/DEFAULT")
    add_linkdirs("licensecc/DEFAULT")

    if is_plat("mingw", "windows") then
        add_syslinks("iphlpapi")
    elseif is_plat("linux") then
        add_syslinks("pthread")
    end

    on_install("windows", "mingw", "linux", function (package)
        io.replace("CMakeLists.txt", "unit_test_framework", "", {plain = true})
        io.replace("extern/license-generator/CMakeLists.txt", "unit_test_framework", "", {plain = true})
        io.replace("src/inspector/CMakeLists.txt", "Boost::unit_test_framework", "", {plain = true})
        io.replace("extern/license-generator/src/base_lib/base64.h", "#include <vector>", "#include <vector>\n#include <cstdint>", {plain = true})
        io.replace("src/library/base/base64.h", "#include <vector>", "#include <vector>\n#include <cstdint>", {plain = true})
        io.replace("src/library/os/cpu_info.hpp", "#include <string>", "#include <string>\n#include <cstdint>", {plain = true})
        
        if package:config("key_path") ~= "" then 
            os.cp(path.join(package:config("key_path"), "public_key.h"), path.join(package:cachedir(), "source", "licensecc", "projects", "DEFAULT", "include", "licensecc", "DEFAULT", "public_key.h"))
            os.cp(path.join(package:config("key_path"), "private_key.rsa"), path.join(package:cachedir(), "source", "licensecc", "projects", "DEFAULT", "private_key.rsa"))
            print("public_key: ", path.join(package:cachedir(), "source", "licensecc", "projects", "DEFAULT", "include", "licensecc", "DEFAULT", "public_key.h"))
            print("private_key: ", path.join(package:cachedir(), "source", "licensecc", "projects", "DEFAULT", "private_key.rsa"))
            io.replace("src/library/os/CMakeLists.txt", "add_dependencies( os project_initialize )", "", {plain = true})
        end

        local configs = {"-DBoost_USE_STATIC_LIBS=ON", "-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows", "mingw") then
            table.insert(configs, "-DBoost_USE_STATIC_RUNTIME=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            #include "licensecc/licensecc.h"
            void test () {
                LCC_API_HW_IDENTIFICATION_STRATEGY hw_id_method = LCC_API_HW_IDENTIFICATION_STRATEGY::STRATEGY_ETHERNET;
                char identifier_out[LCC_API_PC_IDENTIFIER_SIZE + 1];
                size_t buf_size = LCC_API_PC_IDENTIFIER_SIZE + 1;
                ExecutionEnvironmentInfo execution_environment_info;
                
                bool ok = identify_pc(hw_id_method, identifier_out, &buf_size, &execution_environment_info);
                if (ok) {
                    std::cout << identifier_out << std::endl;
                }
                else {
                    std::cout << "NA" << std::endl;
                }
            }
        ]]}))
    end)

