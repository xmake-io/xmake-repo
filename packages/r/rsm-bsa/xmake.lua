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
        add_syslinks("ole32")
    end

    on_load(function (package)
        if package:config("xmem") then
            package:add("deps", "reproc", "expected-lite", "xbyak", "taywee_args")
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
            end
            set_configvar("PROJECT_VERSION_MAJOR", %d)
            set_configvar("PROJECT_VERSION_MINOR", %d)
            set_configvar("PROJECT_VERSION_PATCH", %d)
            set_configvar("PROJECT_VERSION", "%s")
            if has_config("xmem") then
                add_requires("reproc", "expected-lite", "xbyak", "taywee_args")

                target("rsm-bsa-common")
                    set_kind("$(kind)")
                    add_files("extras/xmem/src/bsa/**.cpp")
                    add_includedirs("extras/xmem/src", {public = true})
                    add_headerfiles("extras/xmem/src/(bsa/**.hpp)")
                    add_packages("rsm-binary-io", "rsm-mmio", "expected-lite", "xbyak", {public = true})
                    if is_plat("windows") and is_kind("shared") then
                        add_rules("utils.symbols.export_all", {export_classes = true})
                    end

                target("xmem")
                    set_kind("binary")
                    set_arch("x86")
                    add_files("extras/xmem/src/main.cpp")
                    add_files("extras/xmem/src/version.rc")
                    add_includedirs("include")
                    add_deps("rsm-bsa-common")
                    add_packages("taywee_args")
                    set_configdir("extras/xmem/src")
                    add_configfiles("extras/xmem/cmake/version.rc.in", {pattern = "@(.-)@"})
                    set_configvar("PROJECT_NAME", "bsa")
            end
            target("rsm-bsa")
                set_kind("$(kind)")
                add_files("src/**.cpp")
                add_includedirs("include", "src")
                add_headerfiles("include/(bsa/**.hpp)")
                add_installfiles("visualizers/*.natvis", {prefixdir = "include/natvis"})
                set_configdir("include/bsa")
                add_configfiles("cmake/project_version.hpp.in", {pattern = "@(.-)@"})
                add_packages("rsm-mmio", "rsm-binary-io", "lz4", "zlib")
                if is_plat("windows") then
                    add_packages("directxtex")
                    add_syslinks("ole32")
                    if is_kind("shared") then
                        add_rules("utils.symbols.export_all", {export_classes = true})
                    end
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
