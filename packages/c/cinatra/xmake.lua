package("cinatra")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/qicosmos/cinatra")
    set_description("modern c++(c++20), cross-platform, header-only, easy to use http framework")
    set_license("MIT")

    add_urls("https://github.com/qicosmos/cinatra/archive/refs/tags/v$(version).tar.gz",
             "https://github.com/qicosmos/cinatra.git")

    add_versions("0.8.0", "4e14d5206408eccb43b3e810d3a1fe228fbc7496ded8a16b041ed12cbcce4479")

    add_configs("ssl", {description = "Enable SSL", default = false, type = "boolean"})
    add_configs("gzip", {description = "Enable GZIP", default = false, type = "boolean"})

    add_deps("asio")
    add_deps("async_simple", {configs = {aio = false}})

    on_load("windows", "linux", "macosx", function (package)
        package:add("defines", "ASIO_STANDALONE")
        if package:config("ssl") then
            package:add("deps", "openssl")
            package:add("defines", "CINATRA_ENABLE_SSL")
        end
        if package:config("gzip") then
            package:add("deps", "zlib")
            package:add("defines", "CINATRA_ENABLE_GZIP")
        end
    end)

    on_install("windows", "linux", "macosx", function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <cinatra.hpp>
            using namespace cinatra;
            void test() {
                http_server server(std::thread::hardware_concurrency());
                server.listen("0.0.0.0", "8080");
                server.set_http_handler<GET, POST>("/", [](request& req, response& res) {
                    res.set_status_and_content(status_type::ok, "hello world");
                });
                server.run();
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
