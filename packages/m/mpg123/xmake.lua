package("mpg123")
    set_homepage("https://www.mpg123.de/")
    set_description("Fast console MPEG Audio Player and decoder library")
    set_license("LGPL-2.1-or-later")

    add_urls("https://github.com/libsdl-org/mpg123.git", {alias = "git"})
    add_urls("https://sourceforge.net/projects/mpg123/files/mpg123/$(version)/mpg123-$(version).tar.bz2",
             "https://www.mpg123.de/download/mpg123-$(version).tar.bz2")

    add_versions("1.33.4", "3ae8c9ff80a97bfc0e22e89fbcd74687eca4fc1db315b12607f27f01cb5a47d9")
    add_versions("1.30.2", "c7ea863756bb79daed7cba2942ad3b267a410f26d2dfbd9aaf84451ff28a05d7")

    add_versions("git:1.33.4", "2eb4320e161247a15f991a30e7919902a3629f19")

    if is_plat("linux") then
        add_syslinks("m")
    elseif is_plat("windows", "mingw") then
        add_syslinks("shlwapi")
    end

    add_deps("cmake")
    if is_plat("windows") then
        add_deps("yasm")
    end

    on_install(function (package)
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "LINK_MPG123_DLL")
        end

        -- fix detect error
        if package:is_arch("arm.*") then
            io.replace("ports/cmake/src/CMakeLists.txt",
                "cmake_host_system_information(RESULT HAVE_FPU QUERY HAS_FPU)",
                "set(HAVE_FPU 1)", {plain = true})
        end

        local configs = {"-DBUILD_PROGRAMS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        os.cd("ports/cmake")
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mpg123_init", {includes = "mpg123.h"}))
    end)
