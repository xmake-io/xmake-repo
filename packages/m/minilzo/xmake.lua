package("minilzo")
    set_homepage("http://www.oberhumer.com/opensource/lzo/#minilzo")
    set_description("A very lightweight subset of the LZO library intended for easy inclusion with your application")

    add_urls("http://www.oberhumer.com/opensource/lzo/download/minilzo-$(version).tar.gz")
    add_versions("2.10", "eb4ce543aad19533c83550746e0e9d7bcf716b35a42429e3ba17d60fa0f3e47a")

    on_install(function (package)
        local configs = {}
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("minilzo")
               set_kind("$(kind)")
               add_files("minilzo.c")
               add_headerfiles("*.h")
        ]])
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("lzo1x_1_compress", {includes = "minilzo.h"}))
    end)
