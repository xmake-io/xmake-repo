package("ada")

    set_homepage("https://www.ada-url.com")
    set_description("WHATWG-compliant and fast URL parser written in modern C++")
    set_license("Apache-2.0")

    set_urls("https://github.com/ada-url/ada/archive/refs/tags/v$(version).tar.gz",
             "https://github.com/ada-url/ada.git")

    add_versions("2.3.1", "298992ec0958979090566c7835ea60c14f5330d6372ee092ef6eee1d2e6ac079")
    add_versions("2.4.0", "14624f1dfd966fee85272688064714172ff70e6e304a1e1850f352a07e4c6dc7")
    add_versions("2.4.1", "e9359937e7aeb8e5889515c0a9e22cd5da50e9b053038eb092135a0e64888fe7")

    add_deps("cmake")

    if is_plat("macosx") then
        add_extsources("brew::ada-url")
    end

    on_install("windows", "linux", "macosx", "bsd", "mingw", "msys", "android", "iphoneos", "cross", function (package)
        local configs = {"-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        io.replace("CMakeLists.txt", "  add_subdirectory(singleheader)", "", {plain = true})
        io.replace("CMakeLists.txt", "  add_subdirectory(tools)", "", {plain = true})
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <ada.h>
            void test() {
                auto url = ada::parse<ada::url_aggregator>("https://xmake.io");
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
