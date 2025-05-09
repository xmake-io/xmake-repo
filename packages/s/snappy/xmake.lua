package("snappy")
    set_homepage("https://github.com/google/snappy")
    set_description("A fast compressor/decompressor")

    set_urls("https://github.com/google/snappy/archive/$(version).tar.gz",
             "https://github.com/google/snappy.git")

    add_versions("1.1.8", "16b677f07832a612b0836178db7f374e414f94657c138e6993cbfc5dcc58651f")
    add_versions("1.1.9", "75c1fbb3d618dd3a0483bff0e26d0a92b495bbe5059c8b4f1c962b478b6e06e7")
    add_versions("1.1.10", "49d831bffcc5f3d01482340fe5af59852ca2fe76c3e05df0e67203ebbe0f1d90")
    add_versions("1.2.0", "9b8f10fbb5e3bc112f2e5e64f813cb73faea42ec9c533a5023b5ae08aedef42e")
    add_versions("1.2.1", "736aeb64d86566d2236ddffa2865ee5d7a82d26c9016b36218fcc27ea4f09f86")
    add_versions("1.2.2", "90f74bc1fbf78a6c56b3c4a082a05103b3a56bb17bca1a27e052ea11723292dc")

    add_patches("1.1.9", "patches/1.1.9/inline.patch", "ed6b247d19486ab3f08f268269133193d7cdadd779523c5e69b5e653f82d535b")
    add_patches("1.1.10", "patches/1.1.10/cmake.patch", "d4883111dcfab81ea35ac1e4e157e55105cec02a0ba804458405be25cbf7b6bb")
    add_patches(">=1.2.0 <=1.2.1", "patches/1.2.1/update-neon-flag-aarch64.patch", "13100aa56de71a11bb3704bd7507613fd53caa3ab6e7dbec3de74875deb46ba5")

    add_deps("cmake")

    add_configs("avx", {description = "Use the AVX instruction set", default = false, type = "boolean"})
    add_configs("avx2", {description = "Use the AVX2 instruction set", default = false, type = "boolean"})
    add_configs("bmi2", {description = "Use the BMI2 instruction set", default = false, type = "boolean"})

    on_install(function (package)
        io.replace("CMakeLists.txt", "cmake_minimum_required(VERSION 3.1)", "cmake_minimum_required(VERSION 3.3)", {plain = true})
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
        assert(package:has_cxxfuncs("snappy::Compress(nullptr, nullptr)", {includes = "snappy.h", configs = {languages = package:is_plat("windows") and "c++14" or "c++11"}}))
    end)
