package("robotstxt")

    set_homepage("https://github.com/google/robotstxt")
    set_description("The repository contains Google's robots.txt parser and matcher as a C++ librar.")
    set_license("Apache-2.0")

    add_urls("https://github.com/google/robotstxt.git")
    add_versions("2021.11.24", "02bc6cdfa32db50d42563180c42aeb47042b4f0c")

    add_deps("abseil")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            add_requires("abseil")
            target("librobotstxt")
                set_kind("$(kind)")
                add_files("robots.cc")
                add_packages("abseil")
                add_headerfiles("robots.h")
                set_languages("c99", "c++17")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end
        ]])
        import("package.tools.xmake").install(package, {buildir = "xmake_build"})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                googlebot::RobotsMatcher matcher;
                std::vector<std::string> user_agents(1, "Chrome");
                bool allowed = matcher.AllowedByRobots("robots_content", &user_agents, "url");
            }
        ]]}, {configs = {languages = "c++17"}, includes = "robots.h"}))
    end)
