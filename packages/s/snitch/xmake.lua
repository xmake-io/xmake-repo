package("snitch")

    set_homepage("https://github.com/cschreib/snitch")
    set_description("Lightweight C++20 testing framework.")
    set_license("BSL-1.0")

    add_urls("https://github.com/cschreib/snitch/archive/refs/tags/v$(version).tar.gz",
             "https://github.com/cschreib/snitch.git")
    add_versions("1.3.1", "f9ae374014515a6077df025f8958b7e80ccecd9cf7ee3abd9f17150398eee8db")
    add_versions("1.2.5", "87be73638ebf14667ef7dd9e6372faa7ad4fa9b2c6367c844f733469680469a2")
    add_versions("1.2.4", "0dbcbd2fa682c9215f049905e9f13be00a6bb6a3c5c4a83704e0237d71dbd23b")
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
