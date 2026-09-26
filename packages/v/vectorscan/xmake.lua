package("vectorscan")
    set_homepage("https://github.com/VectorCamp/vectorscan")
    set_description("High-performance regular expression matching library")
    set_license("Apache-2.0")

    set_urls("https://github.com/VectorCamp/vectorscan/archive/refs/tags/vectorscan/$(version).tar.gz")
    add_versions("5.4.13", "11bfcd2dde32d8a08d1a2eebb09294b12a3fa2be140078f8091b751fa1fabd89")

    add_configs("simd", { description = "Enable SIMD optimizations", default = true, type = "boolean" })
    add_configs("fat_runtime", { description = "Fat runtime for x86", default = false, type = "boolean" })
	add_configs("assert", { description = "Fat runtime for x86", default = true, type = "boolean" })
	
    add_deps("cmake")
    add_deps("boost",{configs = {
        graph = true ,
        math = true ,
        regex = true ,
        system = true ,
        chrono = true ,
        date_time = true ,
        thread = true ,
        
    }})
    add_deps("libpcap","sqlite3")
    add_deps("ragel", {host = true})
    add_deps("pcre",{configs = {cpp=false}})
    if is_plat("linux") then
        add_syslinks("m", "pthread")
    end

    on_install("!windows and !wasm and !mingw and !bsd and !iphoneos and !armeabi and !armeabi-v7a",function(package)
        local arch = package:arch()
        local configs = {
            "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"),
            "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"),
            "-DCMAKE_POSITION_INDEPENDENT_CODE=ON",
            "-DFAT_RUNTIME=" .. (package:config("fat_runtime") and "ON" or "OFF"),
            "-DDISABLE_ASSERTS=" .. (package:config("assert") and "ON" or "OFF"),
            "-DBUILD_TESTS=OFF",
            "-DBUILD_BENCHMARKS=OFF",
            "-DBUILD_EXAMPLES=OFF",
            "-DBUILD_DOC=OFF",
            "-DDUMP_SUPPORT=OFF",
        }

		table.insert(configs, "-DBUILD_TOOLS=OFF")
		table.insert(configs, "-DBUILD_UNIT_TESTS=OFF")

        if not package:is_arch("x86") and not package:is_arch("x86_64") then
            table.insert(configs, "-DFAT_RUNTIME=OFF")
            table.insert(configs, "-DBUILD_AVX2=OFF")
            table.insert(configs, "-DBUILD_AVX512=OFF")
            table.insert(configs, "-DBUILD_AVX512VBMI=OFF")
        else
            if package:config("simd") then
                table.insert(configs, "-DBUILD_AVX2=ON")
                table.insert(configs, "-DBUILD_AVX512=ON")
                table.insert(configs, "-DBUILD_AVX512VBMI=ON")
            end
        end
        if not package:is_arch("aarch64") then
            table.insert(configs, "-DBUILD_SVE=OFF")
            table.insert(configs, "-DBUILD_SVE2=OFF")
            table.insert(configs, "-DBUILD_SVE2_BITPERM=OFF")
        else
            if package:config("simd") then
                table.insert(configs, "-DBUILD_SVE=ON")
                table.insert(configs, "-DBUILD_SVE2=ON")
                table.insert(configs, "-DBUILD_SVE2_BITPERM=ON")
            end
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function(package)
        assert(package:check_cxxsnippets({test = [[
            #include <hs/hs.h>
            #include <assert.h>
            void test() {
                hs_database_t *database = nullptr;
                hs_compile_error_t *error = nullptr;
                hs_error_t err = hs_compile("test", 0, HS_MODE_BLOCK, nullptr, &database, &error);
                assert(err == HS_SUCCESS);
                hs_free_database(database);
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
