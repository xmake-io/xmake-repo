package("semi-static-conditions")
    set_homepage("https://github.com/maxlucuta/semi-static-conditions")
    set_description("Branch Optimisation for High-frequency Trading")
    set_license("MIT")

    add_urls("https://github.com/maxlucuta/semi-static-conditions.git")
    add_versions("2023.09.05", "5fbb086c00e06bd530defe8845fc28d24a28d8fc")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            set_languages("c++17")
            target("semi-static-conditions")
                set_kind("$(kind)")
                add_files("src/**.cpp")
                add_includedirs("include")
                add_headerfiles("include/(**.hpp)")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <branch.hpp>
            int add(int a, int b) {
                return a + b;
            }
            int sub(int a, int b) {
                return a - b;
            }
            void test() {
                BranchChanger branch(add, sub);
                branch.set_direction(true);
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
