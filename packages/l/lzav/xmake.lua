package("lzav")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/avaneev/lzav")
    set_description("Fast In-Memory Data Compression Algorithm (safe, inline C/C++) 460+MB/s compress, 2500+MB/s decompress, ratio better than LZ4")
    set_license("MIT")

    add_urls("https://github.com/avaneev/lzav/archive/refs/tags/$(version).tar.gz",
             "https://github.com/avaneev/lzav.git")

    add_versions("4.2", "0b5643605c67dd6fa1e1dbb8c8b25bfd7d91f852d76a7426aae6748612b7497b")
    add_versions("4.0", "bf125517492b0481b76a6b48cef849270dca406b0781f6f4595928046747ea99")
    add_versions("2.14", "98a715dc744d86224c941421beddaf3fcc0defd62ccfad7082eedf83be42dbbd")

    on_install(function (package)
        io.replace("lzav.h", "_refblk:", "_refblk:\n;", {plain = true})
        os.cp("lzav.h", package:installdir("include"))
   end)

    on_test(function (package)
        assert(package:has_cfuncs("lzav_compress_default", {includes = "lzav.h", {configs = {languages = "c99"}}}))
    end)
