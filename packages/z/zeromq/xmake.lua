package("zeromq")

    set_homepage("https://zeromq.org/")
    set_description("High-performance, asynchronous messaging library")

    set_urls("https://github.com/zeromq/libzmq/releases/download/v$(version)/zeromq-$(version).tar.gz",
             "https://github.com/zeromq/libzmq.git")

    add_versions("4.3.2", "ebd7b5c830d6428956b67a0454a7f8cbed1de74b3b01e5c33c5378e22740f763")

    on_install("linux", "macosx", function (package)
        import("package.tools.autoconf").install(package)
    end)
 
    on_test(function (package)
        assert(package:has_cfuncs("zmq_msg_init_size", {includes = "zmq.h"}))
    end)
