package("libb2")
    set_homepage("https://blake2.net")
    set_description("C library providing BLAKE2b, BLAKE2s, BLAKE2bp, BLAKE2sp")
    set_license("CC0-1.0")

    add_urls("https://github.com/BLAKE2/libb2/archive/643decfbf8ae600c3387686754d74c84144950d1.tar.gz",
             "https://github.com/BLAKE2/libb2.git")

    add_versions("v0.98.1", "9eb776149c41a34619e801adeae8056ca68faadc7cea3a68a54b2a4d93ef1937")

    add_configs("openmp", {description = "Enable Openmp", default = false, type = "boolean"})
    add_configs("sse", {description = "Enable SSE", default = false, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("m")
    end

    on_load(function (package)
        if package:config("openmp") then
            package:add("deps", "openmp")
        end
    end)

    on_install(function (package)
        if package:config("shared") then
            package:add("defines", "BLAKE2_DLL")
        end

        local configs = {
            openmp = package:config("openmp"),
            sse = package:config("sse"),
        }

        io.writefile("src/config.h")
        io.replace("src/blake2-impl.h",
            "#define BLAKE2_IMPL_NAME(fun)  BLAKE2_IMPL_EVAL(fun, SUFFIX)",
            "#define BLAKE2_IMPL_NAME", {plain = true})
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("blake2", {includes = "blake2.h"}))
    end)
