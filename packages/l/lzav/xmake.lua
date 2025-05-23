package("lzav")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/avaneev/lzav")
    set_description("Fast In-Memory Data Compression Algorithm (safe, inline C/C++) 460+MB/s compress, 2500+MB/s decompress, ratio better than LZ4")
    set_license("MIT")

    add_urls("https://github.com/avaneev/lzav/archive/refs/tags/$(version).tar.gz",
             "https://github.com/avaneev/lzav.git")

    add_versions("4.19", "e19e093f465b69906aec109ab78f5a38c00fee1d21c61c013d7b185da33911dc")
    add_versions("4.9", "460aaed16cce0ce1d6af03cf20db1dd9566adef7e1cbc8529ce1b8653ede0412")
    add_versions("4.7", "bb888588ec0edce238ce900806ff9cd1722b6109374cb7766587ad8375cd1517")
    add_versions("4.5", "2323c33c0b44e4ed70f93c04ebd36402c1b399cbe967b4c178d56b1599c71ffe")
    add_versions("4.4", "6b1ea3da59162d5b42a9b1e1b23b21c5caca584a7f55c844c3941e4dd1518cd5")
    add_versions("4.3", "5b5aa7bb44213d36d1954fcff730e887bbdc8d89eba7522cf9ed5cdf8c77f72e")
    add_versions("4.0", "bf125517492b0481b76a6b48cef849270dca406b0781f6f4595928046747ea99")
    add_versions("2.14", "98a715dc744d86224c941421beddaf3fcc0defd62ccfad7082eedf83be42dbbd")

    on_install(function (package)
        os.cp("lzav.h", package:installdir("include"))
   end)

    on_test(function (package)
        assert(package:has_cfuncs("lzav_compress_default", {includes = "lzav.h", {configs = {languages = "c99"}}}))
    end)
