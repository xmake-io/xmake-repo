package("uvwasi")
    set_homepage("https://github.com/nodejs/uvwasi")
    set_description("WASI syscall API built atop libuv")
    set_license("MIT")

    add_urls("https://github.com/nodejs/uvwasi/archive/refs/tags/$(version).tar.gz",
             "https://github.com/nodejs/uvwasi.git")

    add_versions("v0.0.23", "cdb148aac298883b51da887657deca910c7c02f35435e24f125cef536fe8d5e1")
    add_versions("v0.0.21", "5cf32f166c493f41c0de7f3fd578d0be1b692c81c54f0c68889e62240fe9ab60")
    add_versions("v0.0.20", "417e5ecc40005d9c8008bad2b6a2034e109b2a0a1ebd108b231cb419cfbb980a")
    add_versions("v0.0.12", "f310a628d2657b9ed523a19284f58e4a407466f2e17efb2250d2e58524d02c53")

    add_patches("v0.0.23", path.join(os.scriptdir(), "patches", "0.0.23", "cmake.patch"), "7c572636693a9ade904ca746a3f365299d312d794fe7b4438b7cfb8dbedc7698")
    add_patches("v0.0.20", path.join(os.scriptdir(), "patches", "0.0.20", "cmake.patch"), "50d70983aa498e63e02e66d71e3c7c78ed1c802c61063d1b085e8a12abbcf751")

    add_includedirs("include", "include/uvwasi")

    add_deps("cmake", "libuv")

    on_install("linux", "windows", "macosx", function (package)
        local test_config = package:version():ge("0.0.22") and "-DBUILD_TESTING=OFF" or "-DUVWASI_BUILD_TESTS=OFF"
        local configs = {test_config}
        if package:version():ge("0.0.20") then
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
            table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
            if package:is_plat("windows") and package:config("shared") then
                table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
            end
            import("package.tools.cmake").install(package, configs, {packagedeps = "libuv"})
        else
            table.insert(configs, "-DWITH_SYSTEM_LIBUV=ON")
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
            table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
            if package:config("shared") then
                io.replace("CMakeLists.txt", "-fvisibility=hidden", "", {plain = true})
            end
            import("package.tools.cmake").build(package, configs, {packagedeps = "libuv"})
            os.cp("include", package:installdir())
            local dir = package.builddir and package:builddir() or package:buildir()
            if package:config("shared") then
                os.trycp(path.join(dir, "**.dll"), package:installdir("bin"))
                os.trycp(path.join(dir, "*.lib"), package:installdir("lib"))
                os.trycp(path.join(dir, "*.so"), package:installdir("lib"))
                os.trycp(path.join(dir, "*.dylib"), package:installdir("lib"))
            else
                os.trycp(path.join(dir, "*.a"), package:installdir("lib"))
                os.trycp(path.join(dir, "*.lib"), package:installdir("lib"))
            end
            if package:is_plat("windows") then
                package:add("linkdirs", "lib")
                package:add("links", "uvwasi_a")
            end
        end
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test() {
                uvwasi_t uvwasi;
                uvwasi_options_t options = {0};
                uvwasi_init(&uvwasi, &options);
            }
        ]]}, {includes = "uvwasi.h"}))
    end)
