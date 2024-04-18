package("boringssl")
    set_homepage("https://boringssl.googlesource.com/boringssl")
    set_description("A fork of OpenSSL that is designed to meet Google's needs.")

    add_urls("https://github.com/google/boringssl.git")
    add_versions("2021.12.29", "d80f17d5c94b21c4fb2e82ee527bfe001b3553f2")
    add_versions("2022.06.13", "0c6f40132b828e92ba365c6b7680e32820c63fa7")

    add_patches("2021.12.29", path.join(os.scriptdir(), "patches", "2021.12.29", "cmake.patch"), "d8bb6312b87b8aad434ea3f9f4275f769af3cdbaab78adf400e8e3907443b505")

    add_deps("cmake", "go")

    if is_plat("linux") then
        add_syslinks("pthread", "dl", "m")
    elseif is_plat("windows") then
        add_syslinks("advapi32")
        add_deps("nasm")
    end
    add_links("ssl", "crypto")

    on_install("linux", "macosx", "windows", function (package)
        import("net.fasturl")
        local configs = {}
        local proxyurls = {"https://goproxy.cn", "https://proxy.golang.org"}
        fasturl.add(proxyurls)
        proxyurls = fasturl.sort(proxyurls)
        if #proxyurls > 0 then
            os.setenv("GOPROXY", proxyurls[1])
        end
        -- we need suppress "hidden symbol ... is referenced by DSO"
        local cxflags
        if not package:config("shared") and package:is_plat("linux") then
            cxflags = "-DBORINGSSL_SHARED_LIBRARY"
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        io.replace("CMakeLists.txt", "-WX", "", {plain = true})
        import("package.tools.cmake").install(package, configs, {cxflags = cxflags, buildir = "build"})
        os.cp("include", package:installdir())
        if package:config("shared") then
            if package:is_plat("windows") then
                os.cp("build/ssl/*/ssl.dll", package:installdir("bin"))
                os.cp("build/ssl/*/ssl.lib", package:installdir("lib"))
                os.cp("build/crypto/*/crypto.dll", package:installdir("bin"))
                os.cp("build/crypto/*/crypto.lib", package:installdir("lib"))
            elseif package:is_plat("macosx") then
                os.cp("build/ssl/libssl.dylib", package:installdir("lib"))
                os.cp("build/crypto/libcrypto.dylib", package:installdir("lib"))
            else
                os.cp("build/ssl/libssl.so", package:installdir("lib"))
                os.cp("build/crypto/libcrypto.so", package:installdir("lib"))
            end
        elseif package:is_plat("windows") then
            os.cp("build/ssl/*/ssl.lib", package:installdir("lib"))
            os.cp("build/crypto/*/crypto.lib", package:installdir("lib"))
        else
            os.cp("build/ssl/libssl.a", package:installdir("lib"))
            os.cp("build/crypto/libcrypto.a", package:installdir("lib"))
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("SSL_new", {includes = "openssl/ssl.h"}))
    end)
