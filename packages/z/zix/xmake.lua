package("zix")
    set_description("A lightweight C99 portability and data structure library")
    set_license("ISC")

    add_urls("https://gitlab.com/drobilla/zix/-/archive/v$(version)/zix-v$(version).tar.gz",
             "https://gitlab.com/drobilla/zix.git")

    add_versions("0.8.0", "51d70d63e970214db84e32d55377d84090c02145f5768265ab140d117f2b8e24")

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("meson", "ninja")

    if is_subhost("windows") then
        add_deps("pkgconf", {host = true})
    else
        add_deps("pkg-config", {host = true})
    end

    on_load(function (package)
        package:add("includedirs", "include/zix-0")
        if not package:config("shared") then
            package:add("defines", "ZIX_STATIC")
        end
    end)

    on_install(function (package)
        local configs = {
            "-Dbenchmarks=disabled",
            "-Ddocs=disabled",
            "-Dtests=disabled",
            "-Dtests_cpp=disabled",
        }
        import("package.tools.meson").install(package, configs)
        -- Copying .pc files from libdata/pkgconfig to lib/pkgconfig after install fixes the FreeBSD package discovery issue.
        if package:is_plat("bsd") then
            local srcdir = path.join(package:installdir(), "libdata", "pkgconfig")
            local dstdir = path.join(package:installdir(), "lib", "pkgconfig")
            if os.isdir(srcdir) then
                os.mkdir(dstdir)
                os.cp(path.join(srcdir, "*.pc"), dstdir)
            end
        end
    end)

    on_test(function (package)		
        assert(package:has_cfuncs("zix_strerror", {includes = "zix/status.h"}))
    end)
