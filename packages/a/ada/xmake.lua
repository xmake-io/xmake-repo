package("ada")
    set_homepage("https://www.ada-url.com")
    set_description("WHATWG-compliant and fast URL parser written in modern C++, part of Internet Archive, Node.js, Clickhouse, Redpanda, Kong, Telegram, Adguard, Datadog and Cloudflare Workers")
    set_license("Apache-2.0")

    set_urls("https://github.com/ada-url/ada/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ada-url/ada.git")

    add_versions("v3.4.2", "3aceb6028eb0787ea77c8f3035a5aaa15108ab11d0fe24f23fe850cf94816523")
    add_versions("v3.4.1", "befb20175cd05fd10f345bbfd4202af31ad6bb25732beaacac69793eeefa8d4f")
    add_versions("v3.3.0", "75565e2d4cc8e3ce2dd7927f5c75cc5ebbd3b620468cb0226501dae68d8fe1cd")
    add_versions("v3.2.7", "91094beb8090875b03af74549f03b9ad3f21545d29c18e88dff0d8004d7c1417")
    add_versions("v3.2.6", "2e0b0c464ae9b5d97bc99fbec37878dde4a436fa0a34127f5755a0dfeb2c84a0")
    add_versions("v3.2.5", "cfda162be4b4e30f368e404e8df6704cdb18f0f26c901bb2f0290150c91e04b5")
    add_versions("v3.2.4", "ce79b8fb0f6be6af3762a16c5488cbcd38c31d0655313a7030972a7eb2bda9e5")
    add_versions("v3.2.3", "8b9aa4dff92772d0029d8bc1f3f704afe34a899e23334bf04c7f0d019a5071c2")
    add_versions("v3.2.2", "2eb3d3d7bd2e0c74785f873fc98cf56556294ac76532ef69a01605329b629162")
    add_versions("v3.2.1", "2530b601224d96554333ef2e1504cebf040e86b79a4166616044f5f79c47eaa5")
    add_versions("v3.1.3", "8bd8df0413d57b56b32e6a5216a1c7f402a52edf33172a39e80484ccce0bb627")
    add_versions("v3.0.1", "525890a87a002b1cc14c091800c53dcf4a24746dbfc5e3b8a9c80490daad9263")
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

    if on_check then
        on_check("android", function (package)
            if package:version() and package:version():ge("3.0.0") then
                local ndk = package:toolchain("ndk"):config("ndkver")
                assert(ndk and tonumber(ndk) > 22, "package(ada >=3.0.0) require ndk version > 22")
            end
        end)
    end

    on_install(function (package)
        io.replace("CMakeLists.txt", "add_subdirectory(singleheader)", "", {plain = true})
        io.replace("CMakeLists.txt", "add_subdirectory(tools)", "", {plain = true})

        io.replace("src/CMakeLists.txt", "/WX", "", {plain = true})

        local configs = {"-DBUILD_TESTING=OFF", "-DADA_TOOLS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DADA_SANITIZE=" .. (package:config("asan") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        local languages
        if package:version() and package:version():ge("3.0.0") then
            languages = "c++20"
        else
            languages = "c++17"
        end
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            #include <ada.h>
            void test() {
                auto url = ada::parse<ada::url_aggregator>("https://xmake.io");
            }
        ]]}, {configs = {languages = languages}}))
    end)
