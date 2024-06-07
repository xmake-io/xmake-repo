package("libgit2")

    set_homepage("https://libgit2.org/")
    set_description("A cross-platform, linkable library implementation of Git that you can use in your application.")
    set_license("GPL-2.0-only")

    set_urls("https://github.com/libgit2/libgit2/archive/refs/tags/$(version).tar.gz",
             "https://github.com/libgit2/libgit2.git")
    add_versions("v1.8.1", "8c1eaf0cf07cba0e9021920bfba9502140220786ed5d8a8ec6c7ad9174522f8e")
    add_versions("v1.8.0", "9e1d6a880d59026b675456fbb1593c724c68d73c34c0d214d6eb848e9bbd8ae4")
    add_versions("v1.7.1", "17d2b292f21be3892b704dddff29327b3564f96099a1c53b00edc23160c71327")
    add_versions("v1.3.0", "192eeff84596ff09efb6b01835a066f2df7cd7985e0991c79595688e6b36444e")

    add_deps("cmake")
    if is_plat("macosx", "iphoneos") then
        add_frameworks("CoreFoundation", "Security")
        add_syslinks("iconv", "z")
    else
        add_deps("openssl", "zlib")
    end
    if is_plat("linux") then
        add_deps("pcre")
        add_syslinks("pthread", "dl")
    elseif is_plat("windows") then
        add_syslinks("ole32", "rpcrt4", "winhttp", "ws2_32", "user32", "crypt32", "advapi32")
    end

    on_install("macosx", "linux", "windows|x64", "windows|x86", "iphoneos", function (package)
        local configs = {"-DBUILD_TESTS=OFF",
                         "-DBUILD_CLAR=OFF",
                         "-DBUILD_EXAMPLES=OFF",
                         "-DBUILD_FUZZERS=OFF",
                         "-DBUILD_CLI=OFF",
                         "-DUSE_SSH=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("android", "iphoneos") then
            table.insert(configs, "-DUSE_HTTPS=OFF")
        elseif package:is_plat("windows") then
            if package:config("vs_runtime"):startswith("MT") then
                table.insert(configs, "-DSTATIC_CRT=ON")
            else
                table.insert(configs, "-DSTATIC_CRT=OFF")
            end
            io.replace("CMakeLists.txt", "/GL", "", {plain = true})
            if package:version():eq("1.7.1") then
                io.replace("cmake/DefaultCFlags.cmake", "/GL", "", {plain = true})
            end
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("git_repository_init", {includes = "git2.h"}))
    end)
