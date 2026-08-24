package("systemc")
    set_homepage("https://accellera.org")
    set_description("SystemC: A modeling language for system-level design")
    set_license("Apache-2.0")

    add_urls("https://github.com/accellera-official/systemc/archive/refs/tags/$(version).tar.gz",
             "https://github.com/accellera-official/systemc.git")

    add_versions("3.0.2", "9b3693ed286aab958b9e5d79bb0ad3bc523bbc46931100553275352038f4a0c4")

    add_configs("pthreads",   {description = "Use POSIX threads", type = "boolean", default = is_plat("macosx")})
    add_configs("assertions", {description = "Enable assertions", type = "boolean", default = true})

    if is_plat("windows", "mingw") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")

    on_load(function (package)
        if package:config("pthreads") and package:is_plat("macosx", "linux", "bsd") then
            package:add("syslinks", "pthread")
        end
    end)

    on_install("linux", "windows", "mingw@windows", "mingw@linux", "bsd", function (package)
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
            "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"),
            "-DCMAKE_CXX_STANDARD=17",
            "-DCMAKE_CXX_STANDARD_REQUIRED=ON",
            "-DCMAKE_CXX_EXTENSIONS=OFF",
            "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"),
            "-DENABLE_PTHREADS=" .. (package:config("pthreads") and "ON" or "OFF")
        }
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
