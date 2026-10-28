package("nepdate")
    set_homepage("https://github.com/sanamhub/nepdate-cpp")
    set_description("Bikram Sambat (Nepali calendar) dates for C++20, with an optional patro library for tithi, public holidays and events.")
    set_license("MIT")

    add_urls("https://github.com/sanamhub/nepdate-cpp/archive/refs/tags/v$(version).tar.gz",
             "https://github.com/sanamhub/nepdate-cpp.git")

    add_versions("0.1.0-beta.1", "c2229885a84c0acaf2a59e844598dedf981d4454f7c9d78d651c47a08c4b716d")

    add_configs("patro", {description = "Build the compiled nepdate::patro library (tithi, public holidays, events).", default = true, type = "boolean"})

    if on_check then
        on_check(function (package)
            assert(package:check_cxxsnippets({test = [[
                #include <chrono>
                #include <ranges>
                #include <span>
                constexpr auto ymd = std::chrono::year{2024} / 7 / 30;
                static_assert(std::chrono::sys_days{ymd}.time_since_epoch().count() == 19934);
                static_assert(std::ranges::range<std::ranges::empty_view<int>>);
            ]]}, {configs = {languages = "c++20"}}), "package(nepdate) requires C++20 with <chrono> calendar and <ranges> support")
        end)
    end

    on_load(function (package)
        if package:config("patro") then
            package:add("deps", "cmake")
        else
            package:set("kind", "library", {headeronly = true})
        end
    end)

    on_install(function (package)
        if not package:config("patro") then
            os.cp("include/nepdate", package:installdir("include"))
        else
            -- upstream's internal size-check program, not part of the package
            io.replace("CMakeLists.txt", "add_subdirectory(tools/coreonly)", "", {plain = true})
            -- The upstream size assertion assumes a 64-bit pointer.
            io.replace("patro/include/nepdate/patro.hpp", "static_assert(sizeof(day_info) == 16);",
                       "static_assert(sizeof(day_info) == (sizeof(void*) == 8 ? 16 : 8));", {plain = true})
            local configs = {"-DNEPDATE_BUILD_PATRO=ON", "-DNEPDATE_BUILD_TESTS=OFF", "-DNEPDATE_BUILD_TOOLS=OFF"}
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
            table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
            import("package.tools.cmake").install(package, configs)
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                const nepdate::date d = nepdate::make_date(2081, 4, 15).value();
                const auto ad = d.to_year_month_day();
            }
        ]]}, {configs = {languages = "c++20"}, includes = "nepdate/nepdate.hpp"}))
        if package:config("patro") then
            assert(package:check_cxxsnippets({test = [[
                void test() {
                    const nepdate::date d = nepdate::make_date(2081, 4, 15).value();
                    auto events = nepdate::patro::info(d).events();
                }
            ]]}, {configs = {languages = "c++20"}, includes = "nepdate/patro.hpp"}))
        end
    end)
