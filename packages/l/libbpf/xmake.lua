package("libbpf")

    set_homepage("https://github.com/libbpf/libbpf")
    set_description("Automated upstream mirror for libbpf stand-alone build.")

    set_urls("https://github.com/libbpf/libbpf/archive/$(version).tar.gz",
             "https://github.com/libbpf/libbpf.git")
    add_versions("v0.3", "c168d84a75b541f753ceb49015d9eb886e3fb5cca87cdd9aabce7e10ad3a1efc")

    add_deps("libelf", "zlib")

    add_includedirs("include", "include/uapi")

    on_install("linux", function (package)
        os.cd("src")
        io.replace("Makefile", "PREFIX ?= /usr", "PREFIX ?= " .. package:installdir(), {plain = true})
        if package:config("shared") then
            io.replace("Makefile", "STATIC_LIBS := .-\n", "STATIC_LIBS :=\n")
        else
            io.replace("Makefile", "ifndef BUILD_STATIC_ONLY", "ifeq (1,0)")
        end
        import("package.tools.make").install(package)
        if package:is_plat("linux") and package:is_arch("x86_64") then
            local lib64 = path.join(package:installdir(), "lib64")
            if os.isdir(lib64) then
                package:add("links", "bpf")
                package:add("linkdirs", "lib64")
            end
        end
        os.cp("../include/uapi", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("bpf_object__open", {includes = "bpf/libbpf.h"}))
    end)
