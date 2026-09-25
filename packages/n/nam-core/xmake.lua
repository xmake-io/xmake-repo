package("nam-core")
    set_homepage("https://github.com/sdatkinson/NeuralAmpModelerCore")
    set_description("Core DSP library for NAM plugins")
    set_license("MIT")

    add_urls("https://github.com/sdatkinson/NeuralAmpModelerCore/archive/refs/tags/$(version).tar.gz",
             "https://github.com/sdatkinson/NeuralAmpModelerCore.git")

    add_versions("v0.5.4", "3fd9d82851660fab3f12f3baceb94ec5ed017ff5a85ca6e66a9f6b0a81332c3f")

    add_configs("a2_fast", {description = "Build the A2 fast-path WaveNet.", default = true, type = "boolean"})

    add_deps("eigen", "nlohmann_json")

    on_install("!bsd", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")

            add_requires("eigen", "nlohmann_json")
            add_packages("eigen", "nlohmann_json")

            option("a2_fast", {default = false})

            set_languages("c++17")

            target("NAM")
                add_files("NAM/**.cpp")
                add_includedirs("NAM", {public = true})
                add_headerfiles("(NAM/**.h)", "(NAM/**.hpp)")
                set_kind("$(kind)")

                if has_config("a2_fast") then
                    add_defines("NAM_ENABLE_A2_FAST")
                end

                if is_plat("windows") then
                    add_defines("NOMINMAX", "WIN32_LEAN_AND_MEAN")
                    if is_kind("shared") then
                        add_rules("utils.symbols.export_all", {export_classes = true})
                    end
                end
        ]])
        io.writefile(path.join("NAM", "json.hpp"), "#include <nlohmann/json.hpp>")
        io.writefile(path.join("NAM", "wavenet", "json.hpp"), "#include <nlohmann/json.hpp>")
        import("package.tools.xmake").install(package, {a2_fast = package:config("a2_fast")})
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("nam::verify_config_version(\"\")", {includes = "NAM/dsp.h", configs = {languages = "c++17"}}))
    end)
