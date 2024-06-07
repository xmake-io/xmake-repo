package("ls-hpack")
    set_homepage("https://github.com/litespeedtech/ls-hpack")
    set_description("LiteSpeed HPACK (RFC7541) Library")
    set_license("MIT")

    add_urls("https://github.com/litespeedtech/ls-hpack/archive/refs/tags/$(version).tar.gz",
             "https://github.com/litespeedtech/ls-hpack.git")

    add_versions("v2.3.3", "3d7d539bd659fefc7168fb514368065cb12a1a7a0946ded60e4e10f1637f1ea2")

    add_deps("xxhash")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")

            set_symbols("none")

            add_requires("xxhash")
            add_packages("xxhash")

            target("ls-hpack")
                set_kind("$(kind)")
                add_files("*.c")
                add_headerfiles("*.h")

                add_defines("XXH_HEADER_NAME=<xxhash.h>")

                if is_plat("windows") then
                    add_includedirs("compat/windows")
                    add_headerfiles("compat/windows/(sys/*.h)")

                    if is_kind("shared") then
                        add_rules("utils.symbols.export_all")
                    end
                end

                on_config(function(target)
                    if not target:has_cincludes("sys/queue.h") then
                        target:add("includedirs", "compat/queue")
                        target:add("headerfiles", "compat/queue/(sys/*.h)")
                    end
                end)
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("lshpack_enc_init", {includes = "lshpack.h"}))
    end)
