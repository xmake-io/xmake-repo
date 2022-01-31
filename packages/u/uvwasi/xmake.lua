package("uvwasi")
    set_homepage("https://github.com/nodejs/uvwasi")
    set_description("WASI syscall API built atop libuv")
    set_license("MIT")

    add_urls("https://github.com/nodejs/uvwasi/archive/refs/tags/$(version).tar.gz",
             "https://github.com/nodejs/uvwasi.git")
    add_versions("v0.0.12", "f310a628d2657b9ed523a19284f58e4a407466f2e17efb2250d2e58524d02c53")

    add_deps("cmake", "libuv")

    on_install("linux", "windows", "macosx", function (package)
        local configs = {"-DWITH_SYSTEM_LIBUV=ON", "-DUVWASI_BUILD_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:config("shared") then
            io.replace("CMakeLists.txt", "-fvisibility=hidden", "", {plain = true})
        end
        if package:is_plat("windows") then
            table.insert(configs, "-DLIBUV_LIBRARIES=uv_a.lib")
        end
        import("package.tools.cmake").install(package, configs, {buildir = "build", packagedeps = "libuv"})
        os.cp("include", package:installdir())
        if package:config("shared") then
            os.trycp("build/*.dll", package:installdir("bin"))
            os.trycp("build/*.so", package:installdir("lib"))
            os.trycp("build/*.dylib", package:installdir("lib"))
        else
            os.trycp("build/*.a", package:installdir("lib"))
            os.trycp("build/*.lib", package:installdir("lib"))
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("uvwasi_init", {includes = "uvwasi.h"}))
    end)
