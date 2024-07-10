package("date")

    set_homepage("https://github.com/HowardHinnant/date")
    set_description("A date and time library for use with C++11 and C++14.")
    set_license("MIT")

    add_urls("https://github.com/HowardHinnant/date/archive/refs/tags/$(version).zip",
             "https://github.com/HowardHinnant/date.git")

    add_versions("v3.0.1", "f4300b96f7a304d4ef9bf6e0fa3ded72159f7f2d0f605bdde3e030a0dba7cf9f")

    if is_plat("windows", "mingw") then
        add_syslinks("ole32", "shell32")
    end

    add_deps("cmake")

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
        ]]}, {configs = {languages = "c++14"}}))
        assert(package:check_cxxsnippets({test = [[
            #include <date/tz.h>
            void test() {
                using namespace date;
                using namespace std::chrono;
                make_zoned(current_zone(), system_clock::now());
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
