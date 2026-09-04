package("toml")
    set_kind("addon")
    set_homepage("https://github.com/xmake-addons/toml")
    set_description("The TOML addon, it provides the toml parser, the toml emitter and a command line tool.")
    set_license("Apache-2.0")

    add_urls("https://github.com/xmake-addons/toml/archive/refs/tags/$(version).tar.gz",
             "https://github.com/xmake-addons/toml.git")
    add_versions("v1.0.0", "aab78a90577a76fca2efea265a85d89c0955c1072b0dcfeb12d732facc479300")

    on_test(function (package)
        assert(package:has_addon({modules = "toml"}))

        -- the module and the command line tool
        --
        -- @note the toml text has `[[deps]]` in it, so the long string needs a deeper
        -- level, `[[` would close it right there
        os.vrunv("xmake", {"lua", "-c", [==[
            import("@addon.toml.toml")
            local value = toml.decode('name = "xmake"\ntags = ["build", "lua"]\n\n[[deps]]\nname = "tbox"\n')
            assert(value.name == "xmake")
            assert(value.tags[2] == "lua")
            assert(value.deps[1].name == "tbox")
            assert(toml.encode({a = 1}) == "a = 1\n")
        ]==]})
        os.vrunv("xmake", {"lua", "@addon.toml.toml", "--help"})
    end)
