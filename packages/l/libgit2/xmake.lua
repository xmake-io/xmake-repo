package("libgit2")

    set_homepage("https://libgit2.org/")
    set_description("A cross-platform, linkable library implementation of Git that you can use in your application.")
    set_license("GPL-2.0-only")

    set_urls("https://github.com/libgit2/libgit2/archive/refs/tags/$(version).tar.gz",
             "https://github.com/libgit2/libgit2.git")
    add_versions("v1.3.0", "192eeff84596ff09efb6b01835a066f2df7cd7985e0991c79595688e6b36444e")

    if is_plat("macosx") then
        add_frameworks("CoreFoundation", "Security")
        add_syslinks("iconv")
    else
        add_deps("openssl", "zlib")
    end

    on_install(function (package)
        local configs = {"-DBUILD_TESTS=OFF", "-DBUILD_EXAMPLES=OFF", "-DBUILD_FUZZERS=OFF", "-DUSE_SSH=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("git_repository_init", {includes = "git2.h"}))
    end)
