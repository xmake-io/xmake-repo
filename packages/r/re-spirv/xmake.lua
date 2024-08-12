package("re-spirv")
    set_homepage("https://github.com/rt64/re-spirv")
    set_description("Lightweight and fast SPIR-V re-optimizer designed around spec constant usage.")
    set_license("MIT")

    add_urls("https://github.com/rt64/re-spirv.git", {submodules = false})
    add_versions("2024.08.07", "f0ad27a50339e72d4c86b3436b9f74de83a20544")

    add_deps("spirv-headers")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_requires("spirv-headers")
            add_rules("mode.debug", "mode.release")
            set_languages("c++17")
            target("re-spirv")
                set_kind("$(kind)")
                add_files("re-spirv.cpp")
                add_headerfiles("re-spirv.h")
                add_packages("spirv-headers")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end
            target("re-spirv-cli")
                set_kind("binary")
                add_files("re-spirv-cli.cpp")
                add_deps("re-spirv")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                respv::Shader shader;
            }
        ]]}, {configs = {languages = "c++17"}, includes = "re-spirv.h"}))
    end)
