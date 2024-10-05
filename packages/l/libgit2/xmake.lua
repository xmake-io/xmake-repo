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

    add_configs("ssh", {description = "Enable SSH support", default = false, type = "boolean"})
    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("pthread", "dl")
    elseif is_plat("windows", "mingw") then
        add_syslinks("ole32", "rpcrt4", "winhttp", "ws2_32", "user32", "crypt32", "advapi32")
    elseif is_plat("macosx", "iphoneos") then
        add_frameworks("CoreFoundation", "Security")
        add_syslinks("iconv", "z")
    end

    add_deps("cmake")
    if is_subhost("windows") then
        add_deps("pkgconf")
    end

    add_deps("pcre2", "llhttp")
    if not is_plat("macosx", "iphoneos") then
        add_deps("openssl", "zlib")
    end

    if on_check then
        on_check("windows", function (package)
            -- undefined symbol __except_handler4_common(msvcrt)
            if package:is_arch("x86") and package:has_runtime("MD", "MDd") and package:config("shared") then
                raise("package(libgit2) unsupported x86 & MD & shared")
            end
        end)
    end

    on_load(function (package)
        if package:config("ssh") then
            package:add("deps", "libssh2", {configs = {backend = "openssl"}})
        end
    end)

    on_install("!wasm", function (package)
        if package:is_plat("android") then
            for _, file in ipairs(os.files("src/**.txt")) do
                if path.basename(file) == "CMakeLists" then
                    io.replace(file, "C_STANDARD 90", "C_STANDARD 99", {plain = true})
                end
            end
        elseif package:is_plat("windows") then
            -- MDd == _MT + _DLL + _DEBUG
            io.replace("cmake/DefaultCFlags.cmake", "/D_DEBUG", "", {plain = true})
            -- Use CMAKE_MSVC_RUNTIME_LIBRARY
            io.replace("cmake/DefaultCFlags.cmake", "/MT", "", {plain = true})
            io.replace("cmake/DefaultCFlags.cmake", "/MTd", "", {plain = true})
            io.replace("cmake/DefaultCFlags.cmake", "/MD", "", {plain = true})
            io.replace("cmake/DefaultCFlags.cmake", "/MDd", "", {plain = true})

            io.replace("CMakeLists.txt", "/GL", "", {plain = true})
            if package:version():eq("1.7.1") then
                io.replace("cmake/DefaultCFlags.cmake", "/GL", "", {plain = true})
            end
        end

        local configs = {
            "-DBUILD_TESTS=OFF",
            "-DBUILD_CLAR=OFF",
            "-DBUILD_EXAMPLES=OFF",
            "-DBUILD_FUZZERS=OFF",
            "-DREGEX_BACKEND=pcre2",
            "-DUSE_HTTP_PARSER=llhttp",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_SSH=" .. (package:config("ssh") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_CLI=" .. (package:config("tools") and "ON" or "OFF"))

        if package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_COMPILE_PDB_OUTPUT_DIRECTORY=''")
        end

        local opt = {}
        local pcre2 = package:dep("pcre2")
        if not pcre2:config("shared") then
            opt.cxflags = "-DPCRE2_STATIC"
        end
        import("package.tools.cmake").install(package, configs, opt)

        if package:is_plat("windows") and package:is_debug() then
            local dir = package:installdir(package:config("shared") and "bin" or "lib")
            os.vcp(path.join(package:buildir(), "*.pdb"), dir)
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("git_repository_init", {includes = "git2.h"}))
    end)
