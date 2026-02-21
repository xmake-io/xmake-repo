package("libfiber")
    set_homepage("https://github.com/iqiyi/libfiber")
    set_description("The high performance coroutine library for Linux/FreeBSD/MacOS/Windows, supporting select/poll/epoll/kqueue/iocp/windows GUI")
    set_license("LGPL-3.0")

    add_urls("https://github.com/iqiyi/libfiber/archive/refs/tags/$(version).tar.gz", {version = function (version)
        return version:gsub("%+", ".")
    end})
    add_urls("https://github.com/iqiyi/libfiber.git")
    add_versions("v1.1.0", "d9729a34b5a8438fab9387eaf9564cd0316673d142043f187f24cba9dc12d694")
    add_versions("v0.9.0+0", "9359a7ebc8d9c48cfaa4c7d1445b3a3e1c392a238574f1d4f7c1191ec8242af2")

    add_deps("cmake")
    if is_plat("linux") then
        add_syslinks("pthread", "dl", "m")
    end

    on_install("linux", "macosx", "android", function (package)
        local configs = {"-Wno-dev"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        io.writefile("CMakeLists.txt", [[
        cmake_minimum_required(VERSION 2.8)
        project(libfiber)
        add_subdirectory("c")
        add_subdirectory("cpp")]])
        io.replace("c/CMakeLists.txt", "-Werror", "", {plain = true})
        io.replace("cpp/CMakeLists.txt", "-Werror", "", {plain = true})
        import("package.tools.cmake").install(package, configs, {buildir = "build"})
        os.cp("c/include", package:installdir())
        os.cp("cpp/include/**.hpp", package:installdir("include/fiber"))
        os.cp("build/lib", package:installdir())
    end)

    on_test(function (package)
        assert(package:has_cfuncs("acl_fiber_create", {includes = "fiber/lib_fiber.h"}))
    end)
