package("libyaml")

    set_homepage("http://pyyaml.org/wiki/LibYAML")
    set_description("Canonical source repository for LibYAML.")

    set_urls("https://github.com/yaml/libyaml/archive/$(version).tar.gz",
             "https://github.com/yaml/libyaml.git")
    add_versions("0.2.2", "46bca77dc8be954686cff21888d6ce10ca4016b360ae1f56962e6882a17aa1fe")

    on_install("macosx", "linux", function (package)
        if not os.isfile("configure") then
            os.vrun("./bootstrap")
        end
        import("package.tools.autoconf").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("yaml_document_initialize", {includes = "yaml.h"}))
    end)
