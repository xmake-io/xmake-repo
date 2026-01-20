package("simdutf")
    set_homepage("https://simdutf.github.io/simdutf/")
    set_description("Unicode routines (UTF8, UTF16, UTF32): billions of characters per second using SSE2, AVX2, NEON, AVX-512. Part of Node.js.")
    set_license("Apache-2.0")

    add_urls("https://github.com/simdutf/simdutf/archive/refs/tags/$(version).tar.gz",
             "https://github.com/simdutf/simdutf.git")
    add_versions("v8.0.0", "a21c34c52d91a229591e4ebc8822a876604cf2fffeac9ec065bfda7cbfb9d680")
    add_versions("v7.7.1", "3b119d55c47196f6310f5b7b300563e6f2789b7de352536809438a3de1eb4432")
    add_versions("v7.7.0", "0180de81a1dd48a87b8c0442ffa81734f3db91a7350914107a449935124e3c6f")
    add_versions("v7.5.0", "3cad2f554912ecd77222272e5d1a7c1e5e33b4011bee823269cdc9095d2fdce2")
    add_versions("v7.4.0", "8fd729ebfd5ec56cb0395bcc176c4801e1f8a0ea834d166d52279d7b9e801283")
    add_versions("v7.3.6", "c08f3dce1cbb7a8bead9eb53bcbda778e8a1c69b7d3a0690682f1b09fbb85c31")
    add_versions("v7.3.4", "c42ed66ceff7bc3e5f4981453864d1b7f656032843909b3807a632be46a1f5d4")
    add_versions("v7.3.3", "6d720ecdd2e524790c0204561f559b755952d8a836a237b2b533f716ab6fdfbb")
    add_versions("v7.3.2", "ff5ee7fa9a02372819ca9fbb78983dd6e9a2140a13507c98fd9b91d2766bf9b5")
    add_versions("v7.2.1", "5c2c0f8c752af8bc0f18d5eccdc78595c2c698aedd087beeee8aebd93dba6d1d")
    add_versions("v7.0.0", "5a166016ffb8af4cfda9e9d1efcd5613311a4f9e7aabd1f2e11043bcdf727bec")
    add_versions("v6.5.0", "26348c9b60bcf64b98dc598e0b8ccb3f0928cb991110ae82730e563ae85f2c05")
    add_versions("v6.2.0", "f3ef16cb86d866d2271a9a2a539b6ed9ef9083d524963919ce6792a0e3750fe3")
    add_versions("v5.7.2", "6884f4978cf8a0bab0c39e86d9b6e6057dca41a1d591ca2623fb87f9d5dc83bf")
    add_versions("v5.7.1", "fb63e8a3a495253ba36c545fac8aa311a7e3bdfd0cce505a5ded9c48491323d8")
    add_versions("v5.6.3", "503070ddf27e26c051b9500dfc7354ec8850e11076f47db32635931c85b630c0")
    add_versions("v5.5.0", "47090a770b8eecf610ac4d1fafadde60bb7ba3c9d576d2a3a545aba989a3d749")
    add_versions("v5.4.15", "188a9516ee208659cab9a1e5063c1b8385d63d171c2381e9ce18af97936d9879")
    add_versions("v5.3.11", "7926ae62d903a27452997e85d60c5dc04667d7a5ff44c2086ae90cf32bc4bc2c")
    add_versions("v5.3.4", "ccc9dab0c38bf0ee67374592707c6e6002148b99fb225a6b0c4604e90cfcbbc4")
    add_versions("v5.3.0", "9b568d6e66b14810bdbcf645f19b103475ab8175201b5c85828222c0ff0a735c")
    add_versions("v5.2.8", "2706f1bef85a6d8598f82defd3848f1c5100e2e065c5d416d993118b53ea8d77")
    add_versions("v5.2.6", "ab9e56facf7cf05f4e9d062a0adef310fc6a0f82a8132e8ec1e1bb7ab5e234df")
    add_versions("v5.2.4", "36281d6489a4a8c2b5bfac2d41c03dce8fc89ec1cda15cc05c53d44f5ad30b4d")
    add_versions("v5.2.3", "dfa55d85c3ee51e9b52e55c02701b16f83dcf1921e1075b67f99b1036df5adb8")
    add_versions("v4.0.9", "599e6558fc8d06f8346e5f210564f8b18751c93d83bce1a40a0e6a326c57b61e")
    add_versions("v3.2.17", "c24e3eec1e08522a09b33e603352e574f26d367a7701bf069a65881f64acd519")

    add_configs("iconv", {description = "Whether to use iconv as part of the CMake build if available.", default = false, type = "boolean"})

    add_deps("cmake")

    on_load(function (package)
        if package:config("iconv") then
            package:add("deps", "libiconv")
        end
    end)

    on_install(function (package)
        local configs = {"-DSIMDUTF_TESTS=OFF", "-DSIMDUTF_BENCHMARKS=OFF", "-DSIMDUTF_TOOLS=OFF", }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DSIMDUTF_ICONV=" .. (package:config("iconv") and "ON" or "OFF"))
        io.replace("CMakeLists.txt", "add_subdirectory(singleheader)", "", {plain = true})
        io.replace("src/CMakeLists.txt", "/WX", "", {plain = true})
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <simdutf.h>
            void test() {
                bool validutf8 = simdutf::validate_utf8("1234", 4);
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
