package("snappy")
    set_homepage("https://github.com/google/snappy")
    set_description("A fast compressor/decompressor")

    set_urls("https://github.com/google/snappy/archive/$(version).tar.gz",
             "https://github.com/google/snappy.git")

    add_versions("1.1.8", "16b677f07832a612b0836178db7f374e414f94657c138e6993cbfc5dcc58651f")
    add_versions("1.1.9", "75c1fbb3d618dd3a0483bff0e26d0a92b495bbe5059c8b4f1c962b478b6e06e7")
    add_versions("1.1.10", "49d831bffcc5f3d01482340fe5af59852ca2fe76c3e05df0e67203ebbe0f1d90")

    add_patches("1.1.9", "patches/1.1.9/inline.patch", "ed6b247d19486ab3f08f268269133193d7cdadd779523c5e69b5e653f82d535b")
    add_patches("1.1.10", "patches/1.1.10/cmake.patch", "d4883111dcfab81ea35ac1e4e157e55105cec02a0ba804458405be25cbf7b6bb")

    add_deps("cmake")

    add_configs("avx", {description = "Use the AVX instruction set", default = false, type = "boolean"})
    add_configs("avx2", {description = "Use the AVX2 instruction set", default = false, type = "boolean"})
    add_configs("bmi2", {description = "Use the BMI2 instruction set", default = false, type = "boolean"})

    on_install(function (package)
        io.replace("CMakeLists.txt", "-Werror", "", {plain = true})

        if package:version():eq("1.1.10") then
            io.replace("snappy.cc", "(op + deferred_length) < op_limit_min_slop);", "static_cast<ptrdiff_t>(op + deferred_length) < op_limit_min_slop);", {plain = true})
        end
        local configs = {"-DSNAPPY_BUILD_TESTS=OFF", "-DSNAPPY_BUILD_BENCHMARKS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DSNAPPY_REQUIRE_AVX=" .. (package:config("avx") and "ON" or "OFF"))
        table.insert(configs, "-DSNAPPY_REQUIRE_AVX2=" .. (package:config("avx2") and "ON" or "OFF"))
        table.insert(configs, "-DSNAPPY_HAVE_BMI2=" .. (package:config("bmi2") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_COMPILE_PDB_OUTPUT_DIRECTORY=''")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test(int args, char** argv) {
                snappy::Compress(nullptr, nullptr);
            }
        ]]}, {configs = {languages = "c++11"}, includes = "snappy.h"}))
    end)
