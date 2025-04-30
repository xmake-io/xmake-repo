package("libbpf")
    set_homepage("https://github.com/libbpf/libbpf")
    set_description("Automated upstream mirror for libbpf stand-alone build.")

    add_urls("https://github.com/libbpf/libbpf/archive/refs/tags/$(version).tar.gz",
             "https://github.com/libbpf/libbpf.git")

    add_versions("v0.3", "c168d84a75b541f753ceb49015d9eb886e3fb5cca87cdd9aabce7e10ad3a1efc")
    add_versions("v1.3.4", "236f404707977c4856ad53c58182862cf79671bc244b906ee1137cfd3c7d9688")
    add_versions("v1.4.7", "15ffcd76eb7277539410b2f72f0acc3571a1c4a32412e57eaf116d7b3cbf7acf")
    add_versions("v1.5.0", "53492aff6dd47e4da04ef5e672d753b9743848bdb38e9d90eafbe190b7983c44")

    add_configs("make", {description = "Use make buildsystem", default = true, type = "boolean"})

    add_deps("zlib")

    add_includedirs("include", "include/uapi")

    on_load(function (package)
        package:add("defines", "-D_GNU_SOURCE=1", "-D_POSIX_C_SOURCE=200809L")
        if package:config("make") then
            package:add("deps", "autotools", "pkg-config")
        end
        if package:version():gt("0.3") then
            package:add("deps", "elfutils")
        else
            package:add("deps", "libelf")
        end
    end)

    if on_check then
        -- https://github.com/xmake-io/xmake-repo/issues/3182
        on_check("android", function (package)
            if package:version():gt("0.3") then
                local ndk = package:toolchain("ndk")
                local ndk_sdkver = ndk:config("ndk_sdkver")
                local ndkver = ndk:config("ndkver")
                assert(ndkver and tonumber(ndkver) < 26, "package(libbpf): need ndk version < 26 for android")
                assert(ndk_sdkver and tonumber(ndk_sdkver) <= 23, "package(libbpf): need ndk api level <= 23 for android")
            end
        end)
    end

    on_install("linux", "android@linux,macosx", function (package)
        if package:config("make") then
            os.cd("src")
            -- Fix installdir for headers & libs expected installdir()
            io.replace("Makefile", [[PREFIX ?= /usr]], [[PREFIX = ]] .. package:installdir(), {plain = true})
            -- Fix installdir for .so / .a to expected *lib*
            io.replace("Makefile", [[LIBSUBDIR := lib64]], [[LIBSUBDIR := lib]], {plain = true})
            if package:config("shared") then
                -- Build & install only .so
                io.replace("Makefile", [[all: $(STATIC_LIBS) $(SHARED_LIBS) $(PC_FILE)]], [[all: $(SHARED_LIBS) $(PC_FILE)]], {plain = true})
                io.replace("Makefile", [[$(call do_s_install,$(STATIC_LIBS) $(SHARED_LIBS),$(LIBDIR))]], [[$(call do_s_install,$(SHARED_LIBS),$(LIBDIR))]], {plain = true})
            else
                -- Build & install only .a
                io.replace("Makefile", [[all: $(STATIC_LIBS) $(SHARED_LIBS) $(PC_FILE)]], [[all: $(STATIC_LIBS) $(PC_FILE)]], {plain = true})
                io.replace("Makefile", [[$(call do_s_install,$(STATIC_LIBS) $(SHARED_LIBS),$(LIBDIR))]], [[$(call do_s_install,$(STATIC_LIBS),$(LIBDIR))]], {plain = true})
            end
            -- Use expected pkg-config .pc filename provided from xrepo
            io.replace("Makefile", [[--cflags libelf]], [[--cflags elfutils]], {plain = true})
            io.replace("Makefile", [[--libs libelf]], [[--libs elfutils]], {plain = true})
            if package:is_plat("android") then
                -- Resolve unresolved symbol https://man7.org/linux/man-pages/man3/fmemopen.3.html
                io.replace("Makefile", "$(EXTRA_CFLAGS)",
                    "$(EXTRA_CFLAGS) -D__user= -D__force= -D__poll_t=unsigned -Wno-tautological-constant-out-of-range-compare", {plain = true})
            end
            import("package.tools.make").install(package)
        else
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
            import("package.tools.xmake").install(package)
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("bpf_object__open", {includes = "bpf/libbpf.h"}))
    end)
