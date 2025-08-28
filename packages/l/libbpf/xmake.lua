package("libbpf")
    set_homepage("https://github.com/libbpf/libbpf")
    set_description("Automated upstream mirror for libbpf stand-alone build.")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/libbpf/libbpf/archive/refs/tags/$(version).tar.gz",
             "https://github.com/libbpf/libbpf.git")
    add_versions("v1.6.2", "16f31349c70764cba8e0fad3725cc9f52f6cf952554326aa0229daaa21ef4fbd")
    add_versions("v0.3", "c168d84a75b541f753ceb49015d9eb886e3fb5cca87cdd9aabce7e10ad3a1efc")

    add_deps("zlib")

    if on_check then
        on_check("android", function (package)
            local ndk = package:toolchain("ndk")
            local ndk_sdkver = ndk:config("ndk_sdkver")
            if package:version() and package:version():lt("0.5") then
                assert(ndk_sdkver and tonumber(ndk_sdkver) >= 23, "package(libbpf) dep(libelf): need ndk api level >= 23 for android")
            else
                -- elfutils needs api level <= 23
                assert(ndk_sdkver and tonumber(ndk_sdkver) == 23, "package(libbpf) dep(elfutils): need ndk api level == 23 for android")
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

    add_includedirs("include", "include/uapi")

    on_install("linux", "android", function (package)
        local libelfname = package:version():lt("0.5") and "libelf" or "elfutils"
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
                    add_defines("__user=", "__force=", "__poll_t=uint32_t")
                end
        ]], libelfname, libelfname))
        local configs = {}
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("bpf_object__open", {includes = "bpf/libbpf.h"}))
    end)
