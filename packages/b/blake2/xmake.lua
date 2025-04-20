package("blake2")
    set_homepage("https://blake2.net")
    set_description("BLAKE2 official implementations")
    set_license("CC0-1.0")

    add_urls("https://github.com/BLAKE2/BLAKE2/archive/ed1974ea83433eba7b2d95c5dcd9ac33cb847913.tar.gz",
             "https://github.com/BLAKE2/BLAKE2.git")

    add_versions("2023.02.12", "e1d1194cde9fec0f150961cca8f3d9bdf7c5a5cbe020d1cdfb962b4887793124")

    add_configs("openmp", {description = "Enable Openmp", default = false, type = "boolean"})
    add_configs("sse", {description = "Enable SSE", default = false, type = "boolean"})
    add_configs("neno", {description = "Enable neno", default = false, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("m")
    end

    on_load(function (package)
        if package:config("openmp") then
            package:add("deps", "openmp")
        end
    end)

    on_install(function (package)
        local configs = {
            openmp = package:config("openmp"),
            sse = package:config("sse"),
            neno = package:config("neno"),
        }
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("blake2", {includes = "blake2.h"}))
    end)
