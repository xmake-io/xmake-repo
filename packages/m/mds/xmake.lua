package("mds")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/chen-qingyu/MyDataStructure")
    set_description("A C++ containers library that is as easy to use as Python's containers library.")
    set_license("GPL-3.0")

    add_urls("https://github.com/chen-qingyu/MyDataStructure/archive/refs/tags/v$(version).zip",
             "https://github.com/chen-qingyu/MyDataStructure.git")
    add_versions("1.1.0", "70c985b335137c443e6cb170337d2476fd32bab663193f398c7078c4e6916f0d")

    on_install(function (package)
        os.cp("sources/*.hpp", package:installdir("include/mds"))
    end)
