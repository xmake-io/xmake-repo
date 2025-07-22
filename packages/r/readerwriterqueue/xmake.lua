package("readerwriterqueue")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/cameron314/readerwriterqueue")
    set_description("A fast single-producer, single-consumer lock-free queue for C++")
    set_license("BSD-3-Clause")

    set_urls("https://github.com/cameron314/readerwriterqueue/archive/refs/tags/$(version).tar.gz",
             "https://github.com/cameron314/readerwriterqueue.git")

    add_versions("v1.0.7", "532224ed052bcd5f4c6be0ed9bb2b8c88dfe7e26e3eb4dd9335303b059df6691")
    add_versions("v1.0.6", "fc68f55bbd49a8b646462695e1777fb8f2c0b4f342d5e6574135211312ba56c1")

    on_install(function (package)
        os.cp("*.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("moodycamel::ReaderWriterQueue<int>", {includes = "readerwriterqueue.h"}))
    end)
