package("flatcc")
    set_homepage("https://github.com/dvidelabs/flatcc")
    set_description("FlatBuffers Compiler and Library in C for C")
    set_license("Apache-2.0")

    add_urls("https://github.com/dvidelabs/flatcc/archive/refs/tags/$(version).tar.gz",
             "https://github.com/dvidelabs/flatcc.git")

    add_versions("v0.6.1", "2533c2f1061498499f15acc7e0937dcf35bc68e685d237325124ae0d6c600c2b")

    add_configs("reflection", {description = "generation of binary flatbuffer schema files", default = false, type = "boolean"})

    add_deps("cmake")

    on_load(function (package)
        if not package:is_cross() then
            package:addenv("PATH", "bin")
        end
    end)

    on_install(function (package)
        io.replace("CMakeLists.txt", [[set(CMAKE_EXECUTABLE_SUFFIX "_d${CMAKE_EXECUTABLE_SUFFIX}")]], "", {plain = true})

        local configs = {
            "-DFLATCC_INSTALL=ON",
            "-DFLATCC_TEST=OFF",
            "-DFLATCC_CXX_TEST=OFF",
            "-DFLATCC_COVERAGE=OFF",
            "-DFLATCC_ALLOW_WERROR=OFF",
            "-DFLATCC_DEBUG_CLANG_SANITIZE=OFF",
            "-DCMAKE_POLICY_DEFAULT_CMP0057=NEW",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:config("shared") and package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end

        table.insert(configs, "-DFLATCC_RTONLY=" .. (package:is_cross() and "ON" or "OFF"))
        table.insert(configs, "-DFLATCC_REFLECTION=" .. (package:config("reflection") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)

        os.trymv(package:installdir("lib/*.dll"), package:installdir("bin"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("flatcc_builder_init", {includes = "flatcc/flatcc_builder.h"}))
        if not package:is_cross() then
            os.vrun("flatcc --version")
        end
    end)
