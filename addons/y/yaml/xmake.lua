package("yaml")
    set_kind("addon")
    set_homepage("https://github.com/xmake-addons/yaml")
    set_description("The YAML addon, it provides the yaml parser, the yaml emitter and a command line tool.")
    set_license("Apache-2.0")

    add_urls("https://github.com/xmake-addons/yaml/archive/refs/tags/$(version).tar.gz",
             "https://github.com/xmake-addons/yaml.git")
    add_versions("v1.0.0", "a46c9dc7c3d7b2b788df3059361f1cb7d530481423f817ca2923b3f0bcda82b0")

    on_test(function (package)
        assert(package:has_addon({modules = "yaml"}))

        -- the module and the command line tool
        os.vrunv("xmake", {"lua", "-c", [[
            import("@addon.yaml.yaml")
            local value = yaml.decode("name: xmake\ntags: [build, lua]\ndeps:\n  - name: tbox\n")
            assert(value.name == "xmake")
            assert(value.tags[2] == "lua")
            assert(value.deps[1].name == "tbox")
            assert(yaml.encode({a = 1}) == "a: 1\n")
        ]]})
        os.vrunv("xmake", {"lua", "@addon.yaml.yaml", "--help"})
    end)
