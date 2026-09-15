package("photoshop-api")
    set_homepage("https://photoshopapi.readthedocs.io/en/latest/")
    set_description("A modern and performant C++20 read/write parser of Photoshop Files (*.psd and *.psb) with fully fledged Python bindings hosted on PyPi")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/EmilDohne/PhotoshopAPI/archive/refs/tags/$(version).tar.gz",
             "https://github.com/EmilDohne/PhotoshopAPI.git")

    add_versions("v0.4.0", "c62fb9bfdb53de5f5851a2822ac1732f9af4d866a9af6fae9912ed3b829e9422")

    add_deps("c-blosc2", {configs = {zlib = true, zstd = true}})
    add_deps("simdutf", {configs = {iconv = false}})
    add_deps("libdeflate")

    on_install(function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                auto layeredFile  = PhotoshopAPI::LayeredFile<bpp8_t>::read("InputFile.psd");
            }
        ]]}, {configs = {languages = "c++20"}, includes = "PhotoshopAPI.h"}))
    end)
