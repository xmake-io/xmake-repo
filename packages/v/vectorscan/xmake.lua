package("vectorscan")
    set_homepage("https://github.com/VectorCamp/vectorscan")
    set_description("High-performance regular expression matching library")
    set_license("Apache-2.0")

    set_urls("https://github.com/VectorCamp/vectorscan/archive/refs/tags/v$(version)+vectorscan.zip",
             "https://github.com/VectorCamp/vectorscan.git")
             
    add_versions("5.4.4","35a25fffd7d584aa8e3447e4ea5affba28389744")
    
    add_configs("simd", { description = "Enable SIMD optimizations", default = true, type = "boolean" })
    add_configs("unittests", { description = "Build unit tests", default = false, type = "boolean" })
	add_configs("fat_runtime", { description = "Fat runtime for x86", default = false, type = "boolean" })
    add_deps("cmake")
	add_deps("boost","sqlite3","libpcap")
	add_deps("ragel",, {host = true})
	
    if is_plat("linux", "bsd") then
        add_syslinks("m", "pthread")
    elseif is_plat("windows") then
        add_syslinks("pthread")
    end

    on_load(function(package)
        if not package:config("simd") then
            package:add("defines", "HS_DISABLE_SIMD")
        end

        if package:config("unittests") then
            package:add("defines", "HS_BUILD_TESTS")
        end
    end)

    on_install(function(package)
        local configs = {
            "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"),
            "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"),
            "-DCMAKE_POSITION_INDEPENDENT_CODE=ON",
        }
		table.insert(configs,"-DFAT_RUNTIME=" .. package:config("fat_rumtime") and "ON" or "OFF")
        table.insert(configs, "-DHS_BUILDING_LIBRARY=ON")
        table.insert(configs, "-DHS_BUILD_TESTS=" .. (package:config("unittests") and "ON" or "OFF"))
        table.insert(configs, "-DHS_UNRESTRICTED_VECTORS=" .. (package:config("simd") and "OFF" or "ON"))

        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function(package)
        assert(package:check_cxxsnippets({test = [[
            #include <hs.h>
            void test() {
                hs_compile_t* compile = nullptr;
                hs_compile_error_t* error = nullptr;
                compile = hs_compile("test", 0, 0, nullptr, &error);
                assert(compile != nullptr);
                hs_free_compile(compile);
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
