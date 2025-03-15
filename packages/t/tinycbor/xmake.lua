package("tinycbor")

    set_homepage("https://github.com/intel/tinycbor")
    set_description("Concise Binary Object Representation (CBOR) Library")
    set_license("MIT")

    add_urls("https://github.com/intel/tinycbor/archive/refs/tags/$(version).tar.gz",
             "https://github.com/intel/tinycbor.git")
    add_versions("v0.6.1", "0f9944496d1143935e9c996bc6233ca0dd5451299def33ef400a409942f8f34b")
    add_versions("v0.6.0", "512e2c9fce74f60ef9ed3af59161e905f9e19f30a52e433fc55f39f4c70d27e4")

    add_configs("float", {description = "Enable floating point data type.", default = true, type = "boolean"})

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            option("enable_float", {default = true, showmenu = true})
            option("HAS_OPEN_MEMSTREAM")
                add_cfuncs("open_memstream")
                add_cincludes("stdio.h")
                add_defines("_GNU_SOURCE")
            option("HAS_FOPENCOOKIE")
                add_cfuncs("fopencookie")
                add_cincludes("stdio.h")
                add_defines("_GNU_SOURCE")
            option("HAS_FUNOPEN")
                add_cfuncs("funopen")
                add_cincludes("stdio.h")
                add_defines("_GNU_SOURCE")
            target("tinycbor")
                set_kind("$(kind)")
                add_files("src/cbor*.c")
                if not has_config("HAS_OPEN_MEMSTREAM") then
                    if has_config("HAS_FOPENCOOKIE") and has_config("HAS_FUNOPEN") then
                        add_files("src/open_memstream.c")
                    else
                        add_defines("WITHOUT_OPEN_MEMSTREAM")
                    end
                end
                if not has_config("enable_float") then
                    add_defines("CBOR_NO_FLOATING_POINT")
                end
                if is_plat("windows") and is_kind("shared") then
                    add_defines("CBOR_API=__declspec(dllexport)")
                end
                add_headerfiles("src/cbor.h", "src/cborjson.h", "src/tinycbor-version.h")
                after_build(function (target)
                    if target:is_plat("windows") and target:is_shared() then
                        io.replace("src/cbor.h", "#define CBOR_API", "define CBOR_API __declspec(dllimport)", {plain = true})
                    end
                end)
        ]])
        import("package.tools.xmake").install(package, {enable_float = package:config("float")})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("cbor_encoder_init", {includes = "cbor.h"}))
    end)
