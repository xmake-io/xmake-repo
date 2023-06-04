package("liblifthttp")

    set_homepage("https://github.com/jbaldwin/liblifthttp")
    set_description("Safe and easy to use C++17 HTTP client library.")

    set_urls("https://github.com/jbaldwin/liblifthttp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/jbaldwin/liblifthttp.git")

    add_versions("v2022.1", "177dbb7bf13ac80abf2fcbbc722c3e240c4898aa7660dfc0c5d358d3a491b1d8")

    add_deps("libuv")
    add_deps("libcurl >=7.59.0", {configs = {ssl = true, zlib = true}})

    on_install("linux", "macosx", function (package)
        assert(not package:dep("libcurl"):version():eq("7.81.0"), "Unsupported libcurl version")

        local configs = {}
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            add_requires("libuv")
            add_requires("libcurl >=7.59.0", {configs = {ssl = true, zlib = true}})
            target("liblifthttp")
                set_kind("$(kind)")
                add_files("src/*.cpp")
                add_headerfiles("(inc/**.h)")
                set_languages("c++17")
                add_includedirs("inc")
                add_packages("libuv", "libcurl")
        ]])
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            #include <lift/lift.hpp>
            void test() {
                const std::string url{"https://xmake.io"};
                const std::chrono::seconds timeout{10};
                lift::request sync_request{url, timeout};
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
