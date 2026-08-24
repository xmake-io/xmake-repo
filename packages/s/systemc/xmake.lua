package("systemc")
    set_homepage("https://accellera.org")
    set_description("SystemC: A modeling language for system-level design")
    set_license("Apache-2.0")

    add_urls("https://github.com/accellera-official/systemc.git")

    add_versions("3.0.2", "5b191bb6500712243eb152e155c1c6039066cf38")
    add_versions("3.0.1","e598d4afbef12e7e7002719ce3c7a77c4a227a47")
    add_versions("3.0.0","cfbb862974d239a4105789b7644b24c0557763fc")
    add_versions("2.3.4","e8b9e51917abab02b2223cb2f497a1a55450cc64")
    add_versions("2.3.3","739f1f6ef6d50eaed4102b95cd48a91c5be6a2cf")
    add_versions("2.3.2","032c018cbee2fca005001088fbfba3f2bd0ab1af")

    add_deps("cmake")

    add_configs("pthreads",  {description = "Use POSIX threads",    type = "boolean", default = false})
    add_configs("assertions",{description = "Enable assertions",    type = "boolean", default = true})


    on_install("linux", "macosx", "windows", "mingw", "bsd",function(package)
        import("package.tools.cmake")

        if package:is_plat("windows") then
            local src_file = "src/sysc/datatypes/int/sc_int64_io.cpp"
            
            if os.exists(src_file) then
                io.replace(src_file, "([%w_]+)%.osfx%(%)", "%1.flush()", {plain = false})
                io.replace(src_file, "([%w_]+)%.opfx%(%)", "%1.good()", {plain = false})
            end
        end

        local configs = {
            "-DENABLE_ASSERTIONS=" .. (package:config("assertions") and "ON" or "OFF"),
            "-DBUILD_SOURCE_DOCUMENTATION=OFF",
            "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"),
            "-DCMAKE_INSTALL_PREFIX=" .. package:installdir(),
            "-DCMAKE_CXX_STANDARD=17",
            "-DCMAKE_CXX_STANDARD_REQUIRED=ON",
            "-DCMAKE_CXX_EXTENSIONS=OFF",
        }

        if package:is_plat("windows") then
            table.insert(configs,"-DBUILD_SHARED_LIBS=OFF")
        else
            table.insert(configs,"-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        end


        if package:is_plat("macosx") then
            table.insert(configs, "-DENABLE_PTHREADS=ON")
        end
        if not package:is_plat("windows") then
            table.insert(configs, "-DENABLE_PTHREADS=" .. (package:config("pthreads") and "ON" or "OFF"))
        else
            table.insert(configs, "-DENABLE_PTHREADS=OFF")
        end


        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function(package)
        assert(package:check_cxxsnippets({test = [[
            #include <systemc.h>
            int sc_main(int argc, char* argv[]) {
                sc_core::sc_clock clk("clk", 1, sc_core::SC_NS);
                return 0;
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)