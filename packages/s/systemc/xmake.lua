package("systemc")
    set_homepage("https://systemc.org/overview/systemc")
    set_description("Fork of the popular zip manipulation library found in the zlib distribution.")
    set_license("Apache-2.0")

    add_urls("https://github.com/accellera-official/systemc.git")

    add_versions("3.0.2", "5b191bb6500712243eb152e155c1c6039066cf38")
    add_versions("3.0.1","e598d4afbef12e7e7002719ce3c7a77c4a227a47")
    add_versions("3.0.0","cfbb862974d239a4105789b7644b24c0557763fc")
    add_versions("2.3.4","e8b9e51917abab02b2223cb2f497a1a55450cc64")
    add_versions("2.3.3","739f1f6ef6d50eaed4102b95cd48a91c5be6a2cf")
    add_versions("2.3.2","032c018cbee2fca005001088fbfba3f2bd0ab1af")

    add_deps("cmake")

    add_configs("shared", {description = "Build shared library", default = false, type = "boolean"})
    add_configs("pthreads", {description = "Use POSIX threads", default = false, type = "boolean"})
    add_configs("assertions", {description = "Enable assertions", default = true, type = "boolean"})
    add_configs("docs", {description = "Build source documentation", default = false, type = "boolean"})
    on_check(function(package)

        local supported_plats = {"linux", "macosx", "windows", "mingw", "cygwin", "bsd"}
        if not table.contains(supported_plats, package:plat()) then
            raise("systemc does not support platform %s, supported: %s",
                package:plat(), table.concat(supported_plats, ", "))
        end
    end)
    on_load(function (package)
        if package:config("shared") == nil then
            -- if windows use static
            local default_shared = not package:is_plat("windows")
            package:set_config("shared", default_shared)
        end
    end)

    on_install(function (package)
        local configs = {
            "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"),
            "-DENABLE_PTHREADS=" .. (package:config("pthreads") and "ON" or "OFF"),
            "-DENABLE_ASSERTIONS=" .. (package:config("assertions") and "ON" or "OFF"),
            "-DBUILD_SOURCE_DOCUMENTATION=" .. (package:config("docs") and "ON" or "OFF"),
            "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"),
            "-DCMAKE_CXX_STANDARD=17",
            "-DCMAKE_CXX_STANDARD_REQUIRED=ON",
            "-DCMAKE_CXX_EXTENSIONS=OFF",
        }
        table.insert(configs, "-DCMAKE_INSTALL_PREFIX=" .. package:installdir())

        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        local snippet = [[
            #include <systemc.h>
            int main() {
                sc_core::sc_clock clk("clk", 1, sc_core::SC_NS);
                return 0;
            }
        ]]
        local opts = {
            configs = { languages = "c++17" },
            -- 显式指定要链接的库（库名通常为 systemc）
            links = "systemc",
        }
        -- 使用 check_cxxsnippets 可以同时检查编译和链接
        assert(package:check_cxxsnippets({test = snippet}, opts),
               "SystemC test program failed to compile/link")
    end)

