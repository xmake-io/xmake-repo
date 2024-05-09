package("libbpf")

    set_homepage("https://github.com/libbpf/libbpf")
    set_description("Automated upstream mirror for libbpf stand-alone build.")

    add_urls("https://github.com/libbpf/libbpf/archive/refs/tags/$(version).tar.gz",
             "https://github.com/libbpf/libbpf.git")
    add_versions("v1.4.1", "cc01a3a05d25e5978c20be7656f14eb8b6fcb120bb1c7e8041e497814fc273cb")
    add_versions("v0.3", "c168d84a75b541f753ceb49015d9eb886e3fb5cca87cdd9aabce7e10ad3a1efc")

    add_deps("libelf", "zlib")

    add_includedirs("include", "include/uapi")

    on_install("linux", "android", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            add_requires("libelf", "zlib")
            target("bpf")
                set_kind("$(kind)")
                add_files("src/*.c")
                add_includedirs("include", "include/uapi")
                add_packages("libelf", "zlib")
                add_headerfiles("src/(*.h)", {prefixdir = "bpf"})
                add_headerfiles("include/(uapi/**.h)")
                if is_plat("android") then
                    add_defines("__user=", "__force=", "__poll_t=uint32_t")
                end
        ]])
        local configs = {}
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("bpf_object__open", {includes = "bpf/libbpf.h"}))
    end)
