package("yaml-cpp")

    set_homepage("https://github.com/jbeder/yaml-cpp/")
    set_description("A YAML parser and emitter in C++")
    set_license("MIT")

    add_urls("https://github.com/jbeder/yaml-cpp/archive/refs/tags/$(version).tar.gz", {version = function (version)
        return version:le("0.7.0") and "yaml-cpp-" .. tostring(version) or version
    end})
    add_urls("https://github.com/jbeder/yaml-cpp.git")
    add_versions("0.6.3", "77ea1b90b3718aa0c324207cb29418f5bced2354c2e483a9523d98c3460af1ed")
    add_versions("0.7.0", "43e6a9fcb146ad871515f0d0873947e5d497a1c9c60c58cb102a97b47208b7c3")
    add_versions("0.8.0", "fbe74bbdcee21d656715688706da3c8becfd946d92cd44705cc6098bb23b3a16")

    add_deps("cmake")
    on_load("windows", function (package)
        if not package:config("shared") then
            package:add("defines", "YAML_CPP_STATIC_DEFINE")
        end
    end)

    on_install("windows", "linux", "macosx", "mingw", function (package)
        local configs = {"-DYAML_CPP_BUILD_TESTS=OFF"}
        table.insert(configs, "-DYAML_BUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DYAML_MSVC_SHARED_RT=" .. (package:config("vs_runtime"):startswith("MT") and "OFF" or "ON"))
        end
        import("package.tools.cmake").install(package, configs, {buildir = os.tmpfile() .. ".dir"})
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("YAML::Parser", {configs = {languages = "c++11"}, includes = "yaml-cpp/yaml.h"}))
    end)
