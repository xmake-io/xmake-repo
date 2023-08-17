package("rsm-bsa")
    set_homepage("https://github.com/Ryan-rsm-McKenzie/bsa")
    set_description("C++ library for working with the Bethesda archive file format")
    set_license("MIT")

    add_urls("https://github.com/Ryan-rsm-McKenzie/bsa/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Ryan-rsm-McKenzie/bsa.git")

    add_versions("4.0.3", "d77729c08c0a383727eef14fc0612286269b960373bbc91b8625688d6be73fbf")

    add_configs("xmem", {description = "build support for the xmem codec proxy", default = false, type = "boolean"})

    add_deps("rsm-mmio", "rsm-binary-io", "lz4", "zlib")
    if is_plat("windows") then
        add_deps("directxtex")
    end

    on_load(function (package)
        if package:config("xmem") then
            package:add("deps", "reproc", "expected-lite", "xbyak")
        end
    end)

    on_install(function (package)
        local ver = package:version()
        io.writefile("xmake.lua", format([[
            option("xmem", {showmenu = true, default = false})
            add_rules("mode.debug", "mode.release")
            set_languages("c++20")
            add_requires("rsm-mmio", "rsm-binary-io", "lz4", "zlib")
            if is_plat("windows") then
                add_requires("directxtex")
                if is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end
            end
            if has_config("xmem") then
                add_requires("reproc", "expected-lite", "xbyak")

                target("rsm-bsa-common")
                    set_kind("$(kind)")
                    add_files("extras/xmem/src/bsa/**.cpp")
                    add_includedirs("extras/xmem/src", {public = true})
                    add_headerfiles("extras/xmem/src/(bsa/**.hpp)")
                    add_packages("rsm-binary-io", "rsm-mmio", "expected-lite", "xbyak")
            end

            target("rsm-bsa")
                set_kind("$(kind)")
                add_files("src/**.cpp")
                add_includedirs("include", "src")
                add_headerfiles("include/(bsa/**.hpp)")
                add_installfiles("visualizers/*.natvis", {prefixdir = "include/natvis"})
                set_configdir("include/bsa")
                add_configfiles("cmake/project_version.hpp.in", {pattern = "@(.-)@"})
                set_configvar("PROJECT_VERSION_MAJOR", %d)
                set_configvar("PROJECT_VERSION_MINOR", %d)
                set_configvar("PROJECT_VERSION_PATCH", %d)
                set_configvar("PROJECT_VERSION", "%s")
                add_packages("rsm-mmio", "rsm-binary-io", "lz4", "zlib")
                if is_plat("windows") then
                    add_packages("directxtex")
                end
                if has_config("xmem") then
                    add_deps("rsm-bsa-common")
                    add_defines("BSA_SUPPORT_XMEM=1")
                    add_packages("reproc")
                end
        ]], ver:major(), ver:minor(), ver:patch(), ver))

        local configs = {}
        if package:config("xmem") then
            configs.xmem = true
            package:add("defines", "BSA_SUPPORT_XMEM=1")
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <bsa/tes4.hpp>
            void test() {
                const char payload[] = { "Hello world!\n" };
                bsa::tes4::file f;
                f.set_data({ reinterpret_cast<const std::byte*>(payload), sizeof(payload) - 1 });
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
