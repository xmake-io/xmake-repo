package("liburing")

    set_homepage("https://github.com/axboe/liburing")
    set_description("liburing provides helpers to setup and teardown io_uring instances")
    set_license("MIT")

    add_urls("https://github.com/axboe/liburing/archive/refs/tags/liburing-$(version).tar.gz",
             "https://github.com/axboe/liburing.git")
    add_versions("2.9", "897b1153b55543e8b92a5a3eb9b906537a5fedcf8afaf241f8b8787940c79f8d")
    add_versions("2.8", "3ed7891d1b2bbe743ef3fb6d0a4970e630aa02d7c7bd3b0212791fb7be815984")
    add_versions("2.7", "56202ad443c50e684dde3692819be3b91bbe003e1c14bf5abfa11973669978c1")
    add_versions("2.6", "682f06733e6db6402c1f904cbbe12b94942a49effc872c9e01db3d7b180917cc")
    add_versions("2.5", "456f5f882165630f0dc7b75e8fd53bd01a955d5d4720729b4323097e6e9f2a98")
    add_versions("2.4", "2398ec82d967a6f903f3ae1fd4541c754472d3a85a584dc78c5da2fabc90706b")
    add_versions("2.3", "60b367dbdc6f2b0418a6e0cd203ee0049d9d629a36706fcf91dfb9428bae23c8")
    add_versions("2.2", "e092624af6aa244ade2d52181cc07751ac5caba2f3d63e9240790db9ed130bbc")
    add_versions("2.1", "f1e0500cb3934b0b61c5020c3999a973c9c93b618faff1eba75aadc95bb03e07")

    on_install("linux|native", function (package)
        local cflags
        if package:config("pic") ~= false then
            cflags = "-fPIC"
        end
        import("package.tools.autoconf").install(package, {"--use-libc"}, {makeconfigs = {CFLAGS = cflags}})

        -- liburing build for static and shared by default without giving 
        -- any option to choose between the two, so remove the wrong kind afterward
        if package:config("shared") then
            os.rm(path.join(package:installdir("lib"), "*.a"))
        else
            os.rm(path.join(package:installdir("lib"), "*.so*"))
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("io_uring_submit", {includes = "liburing.h"}))
    end)
