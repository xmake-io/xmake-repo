package("cereal")
    set_kind("library", {headeronly = true})
    set_homepage("https://uscilab.github.io/cereal/index.html")
    set_description("cereal is a header-only C++11 serialization library.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/USCiLab/cereal/archive/refs/tags/$(version).tar.gz",
             "https://github.com/USCiLab/cereal.git")

    add_versions("v1.3.2", "16a7ad9b31ba5880dac55d62b5d6f243c3ebc8d46a3514149e56b5e7ea81f85f")
    add_versions("v1.3.1", "65ea6ddda98f4274f5c10fb3e07b2269ccdd1e5cbb227be6a2fd78b8f382c976")
    add_versions("v1.3.0", "329ea3e3130b026c03a4acc50e168e7daff4e6e661bc6a7dfec0d77b570851d5")

    add_configs("thread_safe", {description = "Use mutexes to ensure thread safety", default = false, type = "boolean"})

    add_patches("*", "patches/fix-tuple-hpp-after-clang-19.patch", "ac46579974554be92fdb1f7f753542f5039264d6ae34d305e05ed1b952b0f5c6")

    on_load(function (package)
        if package:version() and package:version():ge("1.3.1") then
            package:add("deps", "cmake")
        end

        if package:config("thread_safe") then
            package:add("defines", "CEREAL_THREAD_SAFE=1")
            if package:is_plat("linux", "bsd") then
                package:add("syslinks", "pthread")
            end
        end
    end)

    on_install(function (package)
        if not package:dep("cmake") then
            os.cp("include", package:installdir())
            return
        end

        io.replace("CMakeLists.txt", "add_subdirectory(sandbox)", "", {plain = true})
        io.replace("CMakeLists.txt", "add_subdirectory(doc)", "", {plain = true})

        local configs = {
            "-DBUILD_DOC=OFF",
            "-DBUILD_TESTS=OFF",
            "-DBUILD_SANDBOX=OFF",
            "-DSKIP_PORTABILITY_TEST=ON",
            "-DSKIP_PERFORMANCE_COMPARISON=ON",
            "-DCEREAL_INSTALL=ON",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DTHREAD_SAFE=" .. (package:config("thread_safe") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <fstream>
            void test() {
                std::ofstream os("out.cereal", std::ios::binary);
                cereal::BinaryOutputArchive archive( os );
            }
        ]]}, {configs = {languages = "c++11"}, includes = "cereal/archives/binary.hpp"}))
    end)
