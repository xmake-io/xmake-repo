package("date")

    set_homepage("https://github.com/HowardHinnant/date")
    set_description("A date and time library for use with C++11 and C++14.")
    set_license("MIT")

    add_urls("https://github.com/HowardHinnant/date/archive/refs/tags/v$(version).tar.gz", {alias = "release"})
    add_urls("https://github.com/HowardHinnant/date.git", {alias = "git"})
    
    add_versions("release:3.0.3", "30de45a34a2605cca33a993a9ea54e8f140f23b1caf1acf3c2fd436c42c7d942")
    add_versions("git:2024.05.14", "1ead6715dec030d340a316c927c877a3c4e5a00c")
    add_versions("git:2021.04.17", "6e921e1b1d21e84a5c82416ba7ecd98e33a436d0")

    if is_plat("windows", "mingw") then
        add_syslinks("ole32", "shell32")
    elseif is_plat("macosx", "iphoneos") then
        add_frameworks("Foundation")
    end

    add_deps("cmake")
    if is_plat("macosx", "iphoneos") then
        add_deps("zlib")
    end

    on_install(function (package)
        local configs = {"-DBUILD_TZ_LIB=ON",
                         "-DUSE_SYSTEM_TZ_DB=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <date/date.h>
            void test() {
                using namespace date;
                year_month_weekday_last{year{2015}, month{3u}, weekday_last{weekday{0u}}};
            }
        ]]}, {configs = {languages = "c++11"}}))
        assert(package:check_cxxsnippets({test = [[
            #include <date/tz.h>
            void test() {
                using namespace date;
                using namespace std::chrono;
                make_zoned(current_zone(), system_clock::now());
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
