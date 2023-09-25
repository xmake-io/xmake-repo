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

    add_deps("cmake", "libcurl >=7.34.0")

    on_install("windows", "linux", "macosx", "mingw", "cross", function (package)
        local configs = {"-DBUILD_TEST=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
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
