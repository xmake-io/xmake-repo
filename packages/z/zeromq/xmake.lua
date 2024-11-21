package("zeromq")
    set_homepage("https://zeromq.org/")
    set_description("High-performance, asynchronous messaging library")
    set_license("MPL-2.0")

    set_urls("https://github.com/zeromq/libzmq/releases/download/v$(version)/zeromq-$(version).tar.gz",
             "https://github.com/zeromq/libzmq.git")

    add_versions("4.3.5", "6653ef5910f17954861fe72332e68b03ca6e4d9c7160eb3a8de5a5a913bfab43")
    add_versions("4.3.2", "ebd7b5c830d6428956b67a0454a7f8cbed1de74b3b01e5c33c5378e22740f763")
    add_versions("4.3.4", "c593001a89f5a85dd2ddf564805deb860e02471171b3f204944857336295c3e5")

    add_patches("4.3.5", "patches/4.3.5/mingw.patch", "d36460c7080f928cd83f2a5752ed832cc2dd8c0ce4d8d69fc8e23f09d48f166c")
    add_patches("4.3.4", "https://github.com/zeromq/libzmq/commit/438d5d88392baffa6c2c5e0737d9de19d6686f0d.patch", "08f8068e109225ff628f9205597b917f633f02bc0be9382b06fbd98b0de2f8a0")

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::zeromq")
    elseif is_plat("linux") then
        add_extsources("pacman::zeromq")
    elseif is_plat("macosx") then
        add_extsources("brew::zeromq")
    end

    add_configs("openpgm", {description = "Build with support for OpenPGM", default = false, type = "boolean", readonly = true})
    add_configs("norm", {description = "Build with support for NORM", default = false, type = "boolean", readonly = true})
    add_configs("vmci", {description = "Build with support for VMware VMCI socket", default = false, type = "boolean", readonly = true})

    add_configs("curve", {description = "Enable CURVE security", default = false, type = "boolean"})
    if is_plat("linux") then
        add_configs("libunwind", {description = "Enable libunwind.", default = false, type = "boolean"})
    end

    if is_plat("windows", "mingw") then
        add_syslinks("ws2_32", "advapi32", "rpcrt4", "iphlpapi")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")

    on_load(function (package)
        if not package:config("shared") then
            package:add("defines", "ZMQ_STATIC")
        end

        if package:config("openpgm") then
            package:add("deps", "openpgm")
        end
        if package:config("norm") then
            package:add("deps", "norm")
        end
        if package:config("curve") then
            package:add("deps", "libsodium")
        end

        if package:is_plat("linux") and package:config("libunwind") then
            package:add("deps", "libunwind")
        end
    end)

    on_install(function (package)
        io.replace("CMakeLists.txt", "NOT ${CMAKE_BUILD_TYPE} MATCHES \"Debug\"", "FALSE", {plain = true})

        local configs = {
            "-DBUILD_TESTS=OFF",
            "-DLIBZMQ_WERROR=OFF",
            "-DWITH_DOC=OFF",
            "-DWITH_DOCS=OFF",
            "-DWITH_PERF_TOOL=OFF",
            "-DENABLE_CPACK=OFF",
            "-DENABLE_CLANG=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DBUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_ASAN=" .. (package:config("asan") and "ON" or "OFF"))
        if (package:is_plat("windows") and package:is_cross()) or package:is_plat("mingw") then
            -- hardcode win10
            table.insert(configs, "-DCMAKE_SYSTEM_VERSION=10.0")
        end

        table.insert(configs, "-DWITH_OPENPGM=" .. (package:config("openpgm") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_NORM=" .. (package:config("norm") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_VMCI=" .. (package:config("vmci") and "ON" or "OFF"))
        if package:is_plat("mingw") then
            table.insert(configs, "-DPOLLER=epoll")
        end

        local libsodium = package:dep("libsodium")
        if libsodium then
            table.insert(configs, "-DENABLE_CURVE=ON")
            table.insert(configs, "-DWITH_LIBSODIUM=ON")
            table.insert(configs, "-DWITH_LIBSODIUM_STATIC=" .. (libsodium:config("shared") and "OFF" or "ON"))
        else
            table.insert(configs, "-DENABLE_CURVE=OFF")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("zmq_msg_init_size", {includes = "zmq.h"}))
    end)
