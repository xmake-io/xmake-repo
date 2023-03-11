package("snitch")

    set_homepage("https://github.com/cschreib/snitch")
    set_description("Lightweight C++20 testing framework.")
    set_license("BSL-1.0")

    add_urls("https://github.com/cschreib/snitch/archive/refs/tags/v$(version).tar.gz",
             "https://github.com/cschreib/snitch.git")
    add_versions("1.0.0", "9616a854e5d7d26b9003d1bb0fa1a1e4dba03a6e380b0f71ac989648e452a994")

    add_configs("main", {description = "Using your own main function", default = false, type = "boolean"})

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DSNITCH_DO_TEST=OFF", "-DSNITCH_CREATE_HEADER_ONLY=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DSNITCH_DEFINE_MAIN=" .. (package:config("main") and "OFF" or "ON"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        -- xmake always add main function
        if not package:config("main") then
            return
        end

        assert(package:check_cxxsnippets({test = [[
            #include <snitch/snitch.hpp>

            unsigned int Factorial( unsigned int number ) {
                return number <= 1 ? number : Factorial(number-1)*number;
            }

            TEST_CASE("Factorials are computed", "[factorial]" ) {
                REQUIRE( Factorial(0) == 1 ); // this check will fail
                REQUIRE( Factorial(1) == 1 );
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
