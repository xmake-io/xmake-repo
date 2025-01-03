package("ada")
    set_homepage("https://www.ada-url.com")
    set_description("WHATWG-compliant and fast URL parser written in modern C++")
    set_license("Apache-2.0")

    set_urls("https://github.com/ada-url/ada/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ada-url/ada.git")

    add_versions("v2.9.2", "f41575ad7eec833afd9f6a0d6101ee7dc2f947fdf19ae8f1b54a71d59f4ba5ec")
    add_versions("v2.9.1", "64eb3d91db941645d1b68ac8d1cbb7b534fbe446b66c1da11e384e17fca975e7")
    add_versions("v2.9.0", "8b992f0ce9134cb4eafb74b164d2ce2cb3af1900902162713b0e0c5ab0b6acd8")
    add_versions("v2.8.0", "83b77fb53d1a9eea22b1484472cea0215c50478c9ea2b4b44b0ba3b52e07c139")
    add_versions("v2.7.8", "8de067b7cb3da1808bf5439279aee6048d761ba246bf8a854c2af73b16b41c75")
    add_versions("v2.7.7", "7116d86a80b79886efbc9d946d3919801815060ae62daf78de68c508552af554")
    add_versions("v2.7.6", "e2822783913c50b9f5c0f20b5259130a7bdc36e87aba1cc38a5de461fe45288f")
    add_versions("v2.4.1", "e9359937e7aeb8e5889515c0a9e22cd5da50e9b053038eb092135a0e64888fe7")
    add_versions("v2.4.0", "14624f1dfd966fee85272688064714172ff70e6e304a1e1850f352a07e4c6dc7")
    add_versions("v2.3.1", "298992ec0958979090566c7835ea60c14f5330d6372ee092ef6eee1d2e6ac079")

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::ada-url")
    elseif is_plat("macosx") then
        add_extsources("brew::ada-url")
    end

    add_deps("cmake")

    on_install(function (package)
        io.replace("CMakeLists.txt", "add_subdirectory(singleheader)", "", {plain = true})
        io.replace("CMakeLists.txt", "add_subdirectory(tools)", "", {plain = true})

        local configs = {"-DBUILD_TESTING=OFF", "-DADA_TOOLS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
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
