package("liblifthttp")
    set_homepage("https://github.com/jbaldwin/liblifthttp")
    set_description("Safe and easy to use C++17 HTTP client library.")
    set_license("Apache-2.0")

    add_urls("https://github.com/jbaldwin/liblifthttp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/jbaldwin/liblifthttp.git")

    add_versions("v4.1.0", "438fd51fd42e1d6e0218a164acc443713f1ae803a6483d356db084c78abb5b11")

    add_deps("libcurl", "zlib", "libuv")

    on_install("linux", "macosx", "android", "iphoneos", function (package)
        -- patch gcc13
        io.replace("inc/lift/http.hpp", "#include <string>", "#include <string>\n#include <cstdint>", {plain = true})
        io.replace("inc/lift/query_builder.hpp", "#include <string>", "#include <string>\n#include <cstdint>", {plain = true})
        io.replace("inc/lift/resolve_host.hpp", "#include <string>", "#include <string>\n#include <cstdint>", {plain = true})
        io.replace("inc/lift/lift_status.hpp", "#include <string>", "#include <string>\n#include <cstdint>", {plain = true})

        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            set_languages("c++17")
            add_requires("libcurl", "zlib", "libuv")
            add_packages("libcurl", "zlib", "libuv")
            target("lifthttp")
                set_kind("$(kind)")
                add_files("src/*.cpp")
                add_includedirs("inc")
                add_headerfiles("inc/(lift/**.hpp)")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                const std::string url{"https://xmake.io"};
                const std::chrono::seconds timeout{10};
                lift::request sync_request{url, timeout};
            }
        ]]}, {configs = {languages = "c++17"}, includes = "lift/lift.hpp"}))
    end)
