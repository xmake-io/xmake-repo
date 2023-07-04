package("zeromq")
    set_homepage("https://zeromq.org/")
    set_description("High-performance, asynchronous messaging library")
    set_license("GPL-3.0")

    set_urls("https://github.com/zeromq/libzmq/releases/download/v$(version)/zeromq-$(version).tar.gz",
             "https://github.com/zeromq/libzmq.git")
    add_versions("4.3.2", "ebd7b5c830d6428956b67a0454a7f8cbed1de74b3b01e5c33c5378e22740f763")
    add_versions("4.3.4", "c593001a89f5a85dd2ddf564805deb860e02471171b3f204944857336295c3e5")

    add_patches("4.3.4", "https://github.com/zeromq/libzmq/commit/438d5d88392baffa6c2c5e0737d9de19d6686f0d.patch", "08f8068e109225ff628f9205597b917f633f02bc0be9382b06fbd98b0de2f8a0")

    if is_plat("linux") then
        add_configs("libunwind", {description = "Enable libunwind.", default = false, type = "boolean"})
    end

    if is_plat("windows") then
        add_deps("cmake")
        add_syslinks("ws2_32", "advapi32", "rpcrt4", "iphlpapi")
    elseif is_plat("linux") then
        add_syslinks("pthread")
    end
    on_load("windows", "linux", function (package)
        if package:is_plat("windows") and not package:config("shared") then
            package:add("defines", "ZMQ_STATIC")
        end
        if package:is_plat("linux") and package:config("libunwind") then
            package:add("deps", "libunwind")
        end
    end)

    on_install("windows", function (package)
        io.replace("CMakeLists.txt", "NOT ${CMAKE_BUILD_TYPE} MATCHES \"Debug\"", "FALSE", {plain = true})
        local configs = {"-DBUILD_TESTS=OFF", "-DLIBZMQ_WERROR=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DBUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_install("linux", "macosx", function (package)
        local configs = {"--disable-dependency-tracking", "--without-docs", "--enable-libbsd=no", "--disable-Werror"}
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-libunwind=" .. (package:config("libunwind") and "yes" or "no"))
        if package:config("pic") then
            table.insert(configs, "--with-pic")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("zmq_msg_init_size", {includes = "zmq.h"}))
    end)
