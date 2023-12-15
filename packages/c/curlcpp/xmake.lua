package("curlcpp")
    set_homepage("https://josephp91.github.io/curlcpp")
    set_description("An object oriented C++ wrapper for CURL (libcurl)")
    set_license("MIT")

    add_urls("https://github.com/JosephP91/curlcpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/JosephP91/curlcpp.git")

    add_versions("3.1", "ba7aeed9fde9e5081936fbe08f7a584e452f9ac1199e5fabffbb3cfc95e85f4b")

    if is_plat("macosx") then
        add_extsources("brew::curlcpp")
    end

    add_deps("libcurl >=7.34.0")

    on_install("windows", "linux", "macosx", "cross", function (package)
        io.writefile("xmake.lua", [[
            add_requires("libcurl >=7.34.0")
            add_rules("mode.debug", "mode.release")
            set_languages("c++11")
            target("curlcpp")
                set_kind("$(kind)")
                add_files("src/*.cpp")
                add_includedirs("include")
                add_headerfiles("include/*.h", {prefixdir = "curlcpp"})
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end
                add_packages("libcurl")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <curlcpp/curl_easy.h>
            using curl::curl_easy;
            void test() {
                curl_easy easy;
                easy.add<CURLOPT_URL>("http://<your_url_here>");
                easy.add<CURLOPT_FOLLOWLOCATION>(1L);
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
