package("lilv")
    set_description("LV2 host library.")
    set_license("ISC")

    add_urls("https://gitlab.com/lv2/lilv/-/archive/v$(version)/lilv-v$(version).tar.gz",
             "https://gitlab.com/lv2/lilv.git")

    add_versions("0.28.0", "006065dcb59ccaad5463e6bb4598160e41dd6474a959838e74820f60a849bfdb")

    add_deps("meson", "ninja", "zix", "lv2", "serd", "sord", "sratom")

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    else
        add_configs("shared", {description = "Build shared library.", default = true, type = "boolean"})
    end

    if is_subhost("windows") then
        add_deps("pkgconf", {host = true})
    else
        add_deps("pkg-config", {host = true})
    end
    add_configs("tools", { description = "Build command line utilities", default = false, type = "boolean"})
    add_configs("dynmanifest", {description = "Build dynamic manifest support", default = false, type = "boolean"})
    add_configs("bindings_cpp", {description = "Build C++ bindings", default = true, type = "boolean"})
    add_configs("bindings_py", {description = "Build Python bindings", default = false, type = "boolean"})

    on_load(function (package)
        if not package:config("shared") then
            package:add("defines", "LILV_STATIC")
        end

        if package:config("tools") then
            package:add("deps", "libsndfile")
        end

        if package:config("bindings_py") then
            package:add("deps", "python")
        end

        package:add("includedirs", "include/lilv-0")
    end)

    on_install("!android", function (package)
        local configs = {
            "-Ddocs=disabled",
            "-Dtests=disabled",
        }
        table.insert(configs, "-Dtools=" .. (package:config("tools") and "enabled" or "disabled"))
        table.insert(configs, "-Ddynmanifest=" .. (package:config("dynmanifest") and "enabled" or "disabled"))
        table.insert(configs, "-Dbindings_cpp=" .. (package:config("bindings_cpp") and "enabled" or "disabled"))
        table.insert(configs, "-Dbindings_py=" .. (package:config("bindings_py") and "enabled" or "disabled"))
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
        assert(package:has_cfuncs("lilv_world_new", {includes = "lilv/lilv.h"}))
    end)
