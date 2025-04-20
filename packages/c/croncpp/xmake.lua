package("croncpp")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/mariusbancila/croncpp")
    set_description("A C++11/14/17 header-only cross-platform library for handling CRON expressions")
    set_license("MIT")

    add_urls("https://github.com/mariusbancila/croncpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/mariusbancila/croncpp.git")

    add_versions("v2023.03.30", "0731b7f900a670c009585eb5e9639722aeff6531dbbd5bfc9ce895459733837e")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            #include <ctime>
            int main() {
                auto cr = cron::make_cron("* 0/5 * * * ?");
                auto time = cron::utils::to_tm("2024-08-28 20:01:00");
                auto next = cron::cron_next(cr, time);
                std::cout << std::asctime(&next);
            }
        ]]}, {configs = {languages = "c++14"}, includes = "croncpp.h"}))
    end)
