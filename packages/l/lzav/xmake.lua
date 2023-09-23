package("lzav")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/avaneev/lzav")
    set_description("Fast In-Memory Data Compression Algorithm (safe, inline C/C++) 460+MB/s compress, 2500+MB/s decompress, ratio better than LZ4")
    set_license("MIT")

    add_urls("https://github.com/avaneev/lzav/archive/refs/tags/$(version).tar.gz",
             "https://github.com/avaneev/lzav.git")

    add_versions("2.14", "98a715dc744d86224c941421beddaf3fcc0defd62ccfad7082eedf83be42dbbd")

    on_install(function (package)
        os.cp("lzav.h", package:installdir("include"))
   end)

    on_test(function (package)
        assert(package:has_cfuncs("lzav_compress_default", {includes = "lzav.h", {configs = {languages = "c99"}}}))
    end)
