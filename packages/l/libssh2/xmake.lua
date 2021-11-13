package("libssh2")

    set_homepage("https://www.libssh2.org/")
    set_description("C library implementing the SSH2 protocol")
    set_license("BSD-3-Clause")

    set_urls("https://github.com/libssh2/libssh2/releases/download/libssh2-$(version)/libssh2-$(version).tar.gz",
             "https://www.libssh2.org/download/libssh2-$(version).tar.gz",
             "https://github.com/libssh2/libssh2.git")
    add_versions("1.10.0", "2d64e90f3ded394b91d3a2e774ca203a4179f69aebee03003e5a6fa621e41d51")

    add_deps("cmake", "libgcrypt", "libgpg-error")
    if is_plat("linux") then
        add_deps("openssl")
    end

    on_install("macosx", "linux", function (package)
        local configs = {"-DBUILD_EXAMPLES=OFF", "-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs, {packagedeps = "libgpg-error"})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("libssh2_exit", {includes = "libssh2.h"}))
    end)
