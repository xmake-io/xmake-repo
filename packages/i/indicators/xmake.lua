package("indicators")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/p-ranav/indicators")
    set_description("Activity Indicators for Modern C++")
    set_license("MIT")

    add_urls("https://github.com/p-ranav/indicators/archive/refs/tags/v$(version).zip",
             "https://github.com/p-ranav/indicators.git")
    add_versions("2.2", "08dc0592a1fb5e3a050562961fbaacf4d03dadb76a0eb47f0670e63235d14dc5")

    on_install(function (package)
        os.cp("include/indicators/*", package:installdir("include/indicators"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[                    
            void test() {
                indicators::show_console_cursor(false);
            }
        ]]}, {configs = {languages = "c++11"}, includes = "indicators/cursor_control.hpp"}))
    end)
