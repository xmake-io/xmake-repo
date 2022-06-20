package("zydis")
    set_homepage("https://zydis.re")
    set_description("Fast and lightweight x86/x86-64 disassembler and code generation library")
    set_license("MIT")

    add_urls("https://github.com/zyantific/zydis/archive/refs/tags/$(version).tar.gz",
             "https://github.com/zyantific/zydis.git")
    add_versions("v3.2.1", "349a2d27270e54499b427051dd45f7b6064811b615588414b096cdeeaeb730ad")
    add_patches("v3.2.1", path.join(os.scriptdir(), "patches", "v3.2.1", "cmake.patch"), "8464810921f507206b8c21618a20de0f5b96cbef7656ebc549079f941f8718fc")
    
    add_deps("cmake")
    on_load(function (package)
        local zycore_c_vers = {
            ["v3.2.1"] = "v1.1.0",
            ["v4.0.0"] = "v1.2.0"
        }
        package:add("deps", "zycore-c " .. zycore_c_vers[package:version_str()])
    end)

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DZYDIS_BUILD_EXAMPLES=OFF")
        table.insert(configs, "-DZYDIS_BUILD_SHARED_LIB=" .. (package:config("shared") and "ON" or "OFF"))
        if package:config("shared") then 
            table.insert(configs, "-DCMAKE_POSITION_INDEPENDENT_CODE=ON")
        end
        import("package.tools.cmake").install(package, configs, {packagedeps = "zycore-c"})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <Zydis/Zydis.h>
            #include <Zycore/LibC.h>
            void test() {
                ZyanU8 encoded_instruction[ZYDIS_MAX_INSTRUCTION_LENGTH];
                ZyanUSize encoded_length = sizeof(encoded_instruction);
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
