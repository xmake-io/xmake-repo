package("libbpf")
    set_homepage("https://github.com/libbpf/libbpf")
    set_description("Automated upstream mirror for libbpf stand-alone build.")

    add_urls("https://github.com/libbpf/libbpf/archive/refs/tags/$(version).tar.gz",
             "https://github.com/libbpf/libbpf.git")

    add_versions("v1.5.1", "e5ff89750e48ab5ecdfc02a759aa0dacd1e7980e98e16bdb4bfa8ff0b3b4b98f")
    add_versions("v1.5.0", "53492aff6dd47e4da04ef5e672d753b9743848bdb38e9d90eafbe190b7983c44")
    add_versions("v1.4.7", "15ffcd76eb7277539410b2f72f0acc3571a1c4a32412e57eaf116d7b3cbf7acf")
    add_versions("v1.3.4", "236f404707977c4856ad53c58182862cf79671bc244b906ee1137cfd3c7d9688")    
    add_versions("v0.3", "c168d84a75b541f753ceb49015d9eb886e3fb5cca87cdd9aabce7e10ad3a1efc")

    add_deps("zlib")

    add_includedirs("include", "include/uapi")

    if on_check then
        -- https://github.com/xmake-io/xmake-repo/issues/3182
        on_check("android", function (package)
            if package:version() and package:version():gt("0.4") then
                local ndk = package:toolchain("ndk")
                local ndk_sdkver = ndk:config("ndk_sdkver")
                local ndkver = ndk:config("ndkver")
                assert(ndkver and tonumber(ndkver) < 26, "package(libbpf): need ndk version < 26 for android")
                assert(ndk_sdkver and tonumber(ndk_sdkver) <= 23, "package(libbpf): need ndk api level <= 23 for android")
            end
        end)
    end

    on_load(function (package)
        if package:version() and package:version():lt("0.5") then
            package:add("deps", "libelf")
        else
            package:add("deps", "elfutils")
        end
    end)

    on_install("linux", "android", function (package)
        io.writefile("xmake.lua", format([[
            add_rules("mode.debug", "mode.release")
            add_requires("%s", "zlib")
            target("bpf")
                set_kind("$(kind)")
                add_files("src/*.c")
                add_includedirs("include", "include/uapi")
                add_packages("%s", "zlib")
                add_headerfiles("src/(*.h)", {prefixdir = "bpf"})
                add_headerfiles("include/(uapi/**.h)")
                if is_plat("android") then
                    add_defines("__user=", "__force=", "__poll_t=uint32_t", "_GNU_SOURCE=1")
                end
        ]], package:version():lt("0.5") and "libelf" or "elfutils",
            package:version():lt("0.5") and "libelf" or "elfutils"))
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("bpf_object__open", {includes = "bpf/libbpf.h"}))
    end)
