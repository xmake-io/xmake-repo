package("think-cell-library")
    set_homepage("https://www.think-cell.com/en/career/devblog/overview")
    set_description("think-cell core library")
    set_license("BSL-1.0")

    add_urls("https://github.com/think-cell/think-cell-library.git")

    add_versions("2023.05.05", "1848ee3763e4cf3c1c3b800d7fec8f4dadef5737")

    add_deps("boost >=1.75")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            add_requires("boost >=1.75")
            add_packages("boost")
            set_languages("c++20")
            target("think-cell-library")
                set_kind("$(kind)")
                add_files("tc/**.cpp")
                add_headerfiles("(tc/**.h)")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <vector>
            #include <tc/range/meta.h>
            #include <tc/range/filter_adaptor.h>
            void test() {
                std::vector<int> v = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20};
                tc::for_each(
                    tc::filter(v, [](const int& n){ return (n%2==0);}),
                    [&](auto const& n) {}
                );
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
