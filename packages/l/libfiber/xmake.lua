package("libfiber")
    set_homepage("https://github.com/iqiyi/libfiber")
    set_description("The high performance coroutine library for Linux/FreeBSD/MacOS/Windows, supporting select/poll/epoll/kqueue/iocp/windows GUI")

    add_urls("https://github.com/iqiyi/libfiber/archive/refs/tags/$(version).tar.gz", {version = function (version)
        return version:gsub("%+", ".")
    end})
    add_urls("https://github.com/iqiyi/libfiber.git")
    add_versions("v0.9.0+0", "9359a7ebc8d9c48cfaa4c7d1445b3a3e1c392a238574f1d4f7c1191ec8242af2")

    add_deps("cmake")
    if is_plat("linux") then
        add_syslinks("pthread", "dl", "m")
    end

    on_load(function (package)
        if package:is_plat("windows") then
            if package:config("shared") then
                package:add("defines", "FIBER_DLL")
            else
                package:add("defines", "FIBER_LIB")
            end
        end
    end)

    on_install("linux", "macosx", "windows", "android", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        os.cd("c")
        io.replace("CMakeLists.txt", "-Werror", "", {plain = true})
        import("package.tools.cmake").install(package, configs, {buildir = "build"})
        os.cp("include", package:installdir())
        os.cp("build/lib", package:installdir())
        os.cd("../cpp")
        io.replace("CMakeLists.txt", "-Werror", "", {plain = true})
        import("package.tools.cmake").install(package, configs, {buildir = "build"})
        os.cp("include/**.hpp", package:installdir("include/fiber"))
        os.cp("build/lib/*", package:installdir("lib"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("acl_fiber_create", {includes = "fiber/lib_fiber.h"}))
    end)
