package("xent-core")
    set_homepage("https://github.com/Project-Xent/xent-core")
    set_description("A declarative C++20 layout & reactivity engine.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/Project-Xent/xent-core.git")
    add_versions("2026.01.30", "cb485c8dc62c33fbdcf188385222193f39be3f1f")

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("yoga")

    if on_check then
        on_check(function (package)
            assert(package:check_cxxsnippets({test = [[
                #include <bit>
                #include <cstdint>
                void test() {
                    constexpr double f64v = 19880124.0; 
                    constexpr auto u64v = std::bit_cast<std::uint64_t>(f64v);
                }
            ]]}, {configs = {languages = "c++20"}}), "package(xent-core) Require at least C++20.")
        end)
    end

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            set_languages("c++20")
            add_requires("yoga")
            target("xent-core")
                set_kind("$(kind)")
                add_includedirs("include")
                add_files("src/*.cpp")
                add_headerfiles("include/xent/(**.hpp)", {prefixdir = "xent"})
                add_packages("yoga")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <xent/hstack.hpp>
            #include <xent/spacer.hpp>
            #include <xent/text.hpp>
            #include <xent/vstack.hpp>
            using namespace xent;
            void test() {
                auto task_row = make<HStack>();
                task_row->Width(500).Height(60).Padding(10).AlignItems(YGAlignCenter);
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
