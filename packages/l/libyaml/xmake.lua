package("libyaml")

    set_homepage("http://pyyaml.org/wiki/LibYAML")
    set_description("Canonical source repository for LibYAML.")
    set_license("MIT")

    set_urls("https://github.com/yaml/libyaml/archive/$(version).tar.gz",
             "https://github.com/yaml/libyaml.git")
    add_versions("0.2.2", "46bca77dc8be954686cff21888d6ce10ca4016b360ae1f56962e6882a17aa1fe")
    add_versions("0.2.5", "fa240dbf262be053f3898006d502d514936c818e422afdcf33921c63bed9bf2e")

    if not is_subhost("windows") then
        add_extsources("pkgconfig::yaml-0.1")
    end

    on_load("windows", function (package)
        if not package:config("shared") then
            package:add("defines", "YAML_DECLARE_STATIC")
        end
    end)

    on_install("windows", "macosx", "linux", "mingw", function (package)
        local ver = package:version()
        io.writefile("xmake.lua", format([[
            add_rules("mode.debug", "mode.release")
            target("yaml")
                set_kind("$(kind)")
                add_files("src/*.c")
                add_headerfiles("include/yaml.h")
                add_includedirs("include", "$(buildir)")
                set_configvar("YAML_VERSION_MAJOR", %d)
                set_configvar("YAML_VERSION_MINOR", %d)
                set_configvar("YAML_VERSION_PATCH", %d)
                set_configvar("YAML_VERSION_STRING", "%s")
                add_configfiles("cmake/config.h.in", {pattern = "@(.-)@"})
                add_defines("HAVE_CONFIG_H")
                if is_kind("static") then
                    add_defines("YAML_DECLARE_STATIC")
                else
                    add_defines("YAML_DECLARE_EXPORT")
                end
        ]], ver:major(), ver:minor(), ver:patch(), ver))
        import("package.tools.xmake").install(package, {kind = package:config("shared") and "shared" or "static"})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("yaml_document_initialize", {includes = "yaml.h"}))
    end)
