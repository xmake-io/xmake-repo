package("epoll-shim")
    set_homepage("https://github.com/jiixyj/epoll-shim")
    set_description("small epoll implementation using kqueue; includes all features needed for libinput/libevdev")
    set_license("MIT")

    add_urls("https://github.com/jiixyj/epoll-shim/archive/refs/tags/$(version).tar.gz",
             "https://github.com/jiixyj/epoll-shim.git")

    add_versions("v0.0.20240608", "8f5125217e4a0eeb96ab01f9dfd56c38f85ac3e8f26ef2578e538e72e87862cb")

    add_deps("cmake")

    on_install("bsd", "macosx", function (package)
        io.replace("CMakeLists.txt", [[set(CMAKE_INSTALL_INCLUDEDIR "${CMAKE_INSTALL_INCLUDEDIR}/libepoll-shim")]], "", {plain = true})
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("epoll_create", {includes = "sys/epoll.h"}))
        assert(package:has_cfuncs("eventfd", {includes = "sys/eventfd.h"}))
        assert(package:has_cfuncs("signalfd", {includes = "sys/signalfd.h"}))
        assert(package:has_cfuncs("timerfd_create", {includes = "sys/timerfd.h"}))
    end)
