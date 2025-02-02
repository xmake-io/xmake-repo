package("libfswatch")
    set_homepage("https://emcrisostomo.github.io/fswatch/")
    set_description("A cross-platform file change monitor with multiple backends: Apple OS X File System Events, *BSD kqueue, Solaris/Illumos File Events Notification, Linux inotify, Microsoft Windows and a stat()-based backend.")
    set_license("GPL-3.0")

    add_urls("https://github.com/emcrisostomo/fswatch/archive/refs/tags/$(version).tar.gz",
             "https://github.com/emcrisostomo/fswatch.git")

    add_versions("1.18.2", "698f21fe5489311dabe9e90463fb9d40796780abac8d207b857e86ade7345d86")
    add_versions("1.17.1", "bd492b6e203b10b30857778f4dd26f688426cd352937bd7779ee245139bafa2b")

    add_deps("cmake")

    if is_plat("macosx") then
        add_frameworks("CoreFoundation", "CoreServices")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread", "dl")
    end

    if on_check then
        on_check(function (package)
            if package:version() and package:version():eq("1.18.2") then
                if package:is_plat("bsd") then
                    -- libfswatch/src/libfswatch/c++/kqueue_monitor.cpp:134:29: error: unknown type name '__darwin_time_t'; did you mean '__sbintime_t'
                    raise("package(libfswatch 1.18.2) unsupported current platform")
                end
            end
        end)
    end

    on_install("linux", "bsd", "macosx", function (package)
        io.replace("CMakeLists.txt", "add_subdirectory(test/src)", "", {plain = true})
        io.replace("CMakeLists.txt", "add_subdirectory(fswatch/src)", "", {plain = true})

        local configs = {"-DUSE_NLS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("fsw_add_path", {includes = "libfswatch/c/libfswatch.h"}))
    end)
