package("boringssl")
    set_homepage("https://boringssl.googlesource.com/boringssl")
    set_description("BoringSSL is a fork of OpenSSL that is designed to meet Google's needs.")
    set_license("Apache-2.0")

    add_urls("https://github.com/google/boringssl/archive/refs/tags/$(version).tar.gz", {
        version = function (version)
            if version:ge("2024.09.13") then
                return format("0.%s.0", version:gsub("%.", ""))
            else
                return "fips-" .. version:gsub("%.", "")
            end
        end})
    add_urls("https://github.com/google/boringssl.git",
             "https://boringssl.googlesource.com/boringssl.git", {alias = "git"})

    add_versions("2025.11.24", "d47f89b894bf534c82071d7426c5abf1e5bd044fee242def53cd5d3d0f656c09")
    add_versions("2022.06.13", "a343962da2fbb10d8fa2cd9a2832839a23045a197c0ff306dc0fa0abb85759b3")
    add_versions("2021.12.29", "d80f17d5c94b21c4fb2e82ee527bfe001b3553f2")

    add_versions("git:2025.11.24", "0.20251124.0")

    add_patches("2022.06.13", path.join(os.scriptdir(), "patches", "2022.06.13", "cmake.patch"), "c44e5c2b4b4f010a6fab1c0bce22a50feb5d85f37a870cf9a71f8d58bdfbd169")
    add_patches("2021.12.29", path.join(os.scriptdir(), "patches", "2021.12.29", "cmake.patch"), "d8bb6312b87b8aad434ea3f9f4275f769af3cdbaab78adf400e8e3907443b505")

    if is_plat("linux") then
        add_syslinks("pthread", "dl", "m")
    elseif is_plat("windows", "mingw") then
        add_syslinks("ws2_32", "advapi32")
    end

    add_links("ssl", "crypto")

    add_deps("cmake", "go")
    if is_plat("windows", "mingw") then
        add_deps("nasm")
    end

    on_load("windows", function (package)
        if package:is_plat("windows") and package:version():ge("2022.06.13") and (not package:is_precompiled()) then
            package:add("deps", "strawberry-perl")
        end
    end)

    on_install("!mingw and (!windows or windows|!arm64)", function (package)
        import("net.fasturl")

        local configs = {}
        local proxyurls = {"https://goproxy.cn", "https://proxy.golang.org"}
        fasturl.add(proxyurls)
        proxyurls = fasturl.sort(proxyurls)
        if #proxyurls > 0 then
            os.setenv("GOPROXY", proxyurls[1])
        end

        io.replace("CMakeLists.txt", "-WX", "", {plain = true})
        io.replace("CMakeLists.txt", "-Werror", "", {plain = true})
        if package:is_plat("wasm") then
            io.replace("CMakeLists.txt", "-Wa,-g", "", {plain = true})
        end

        local configs = {"-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:version() and package:version():ge("2022.06.13") then
            import("package.tools.cmake").install(package, configs)
            if package:is_plat("windows") then
                os.mv(package:installdir("lib/*.dll"), package:installdir("bin"))
            end
        else
            -- we need suppress "hidden symbol ... is referenced by DSO"
            local cxflags
            if not package:config("shared") and package:is_plat("linux") then
                cxflags = "-DBORINGSSL_SHARED_LIBRARY"
            end
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
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("SSL_new", {includes = "openssl/ssl.h"}))
    end)
