package("libfswatch")
    set_homepage("https://emcrisostomo.github.io/fswatch/")
    set_description("A cross-platform file change monitor with multiple backends: Apple OS X File System Events, *BSD kqueue, Solaris/Illumos File Events Notification, Linux inotify, Microsoft Windows and a stat()-based backend.")

    add_urls("https://github.com/emcrisostomo/fswatch/archive/refs/tags/$(version).tar.gz",
             "https://github.com/emcrisostomo/fswatch.git")
    add_versions("1.17.1", "bd492b6e203b10b30857778f4dd26f688426cd352937bd7779ee245139bafa2b")

    add_deps("cmake")

    if is_plat("macosx") then
        add_frameworks("CoreFoundation", "CoreServices")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread", "dl")
    end

    on_install("linux", "bsd", "macosx", "windows", function (package)
        local configs = {"-DUSE_NLS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        io.replace("CMakeLists.txt", "add_subdirectory(test/src)", "", {plain = true})
        io.replace("CMakeLists.txt", "add_subdirectory(fswatch/src)", "", {plain = true})
        if package:is_plat("windows") then
            io.replace("CMakeLists.txt", "find_library(PTHREAD_LIBRARY pthread)", "", {plain = true})
            io.replace("CMakeLists.txt", "set(EXTRA_LIBS ${EXTRA_LIBS} ${PTHREAD_LIBRARY})", "", {plain = true})
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("fsw_add_path", {includes = "libfswatch/c/libfswatch.h"}))
    end)
