package("vectorscan")
    set_homepage("https://github.com/VectorCamp/vectorscan")
    set_description("High-performance regular expression matching library")
    set_license("Apache-2.0")

    set_urls("https://github.com/VectorCamp/vectorscan.git")
    add_versions("5.4.4", "35a25fffd7d584aa8e3447e4ea5affba28389744")

    add_configs("simd", { description = "Enable SIMD optimizations", default = true, type = "boolean" })
    add_configs("unittests", { description = "Build unit tests", default = false, type = "boolean" })
    add_configs("fat_runtime", { description = "Fat runtime for x86", default = false, type = "boolean" })

    add_deps("cmake")
    add_deps("boost")
    add_deps("ragel", {host = true})

    if is_plat("linux", "bsd") then
        add_syslinks("m", "pthread")
    end

    on_install(function(package)
        local arch = package:arch()
        local configs = {
            "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"),
            "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"),
            "-DCMAKE_POSITION_INDEPENDENT_CODE=ON",
            "-DFAT_RUNTIME=" .. (package:config("fat_runtime") and "ON" or "OFF"),
            "-DBUILD_TESTS=" .. (package:config("unittests") and "ON" or "OFF"),
            "-DBUILD_BENCHMARKS=OFF",
            "-DBUILD_EXAMPLES=OFF",
            "-DBUILD_DOC=OFF",
        }

		table.insert(configs, "-DBUILD_TOOLS=OFF")
		table.insert(configs, "-DBUILD_UNIT_TESTS=OFF")

        if arch == "arm64" or arch == "aarch64" then
            table.insert(configs, "-DFAT_RUNTIME=OFF")
        end

        if not package:config("simd") then
            if arch == "x86" or arch == "x86_64" then
                table.insert(configs, "-DBUILD_AVX2=OFF")
                table.insert(configs, "-DBUILD_AVX512=OFF")
                table.insert(configs, "-DBUILD_AVX512VBMI=OFF")
            end
        end

        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function(package)
        assert(package:check_cxxsnippets({test = [[
            #include <hs.h>
            #include <assert.h>
            void test() {
                hs_database_t *database = nullptr;
                hs_compile_error_t *error = nullptr;
                hs_error_t err = hs_compile("test", 0, HS_MODE_BLOCK, nullptr, &database, &error);
                assert(err == HS_SUCCESS);
                hs_free_database(database);
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
