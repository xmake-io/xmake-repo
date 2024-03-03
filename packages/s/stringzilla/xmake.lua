package("stringzilla")
    set_kind("library", {headeronly = true})
    set_homepage("https://ashvardanian.com/posts/stringzilla/")
    set_description("Up to 10x faster string search, split, sort, and shuffle for long strings and multi-gigabyte files in Python and C, leveraging SIMD with just a few lines of Arm Neon and x86 AVX2 & AVX-512 intrinsics 🦖")
    set_license("Apache-2.0")

    add_urls("https://github.com/ashvardanian/StringZilla/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ashvardanian/StringZilla.git")

    add_versions("v1.2.2", "2e17c49965841647a1c371247f53b2f576e5fb32fe4b84a080d425b12f17703c")
    add_versions("v2.0.3", "6b52a7b4eb8383cbcf83608eaa08e5ba588a378449439b73584713a16d8920e3")
    add_versions("v2.0.4", "440d3d586f8cfe96bc7648f01f2d3c514c4e2dc22446caeb50599383d1970ed2")
    add_versions("v3.0.0", "50bc3544d97c6c1d82022a78af4ab062010a1d35096330cb84d952b0cf7d54fb")
    add_versions("v3.1.0", "32580513dbc054cc23941d36e19741bce1fa106c3031670065719eb4b95afde8")
    add_versions("v3.1.1", "6f7905ee481fda0230a55075f9f4704284f2c18bd53d9e1c6ef78e3eaf29cea9")
    add_versions("v3.1.2", "aa25438112551eab9eec9a532749e430fe26b6562adae517c56ce0fe762af2b6")
    add_versions("v3.2.0", "12789c5f81d63e569e7a1221933aa371274fa3f22f8143f7bd65b5248c66a7d9")
    add_versions("v3.3.0", "15924a562e3166840a5385959dcc190eb40b49cec82900fde319774963c5d85a")
    add_versions("v3.3.1", "3f6bcf9ce10089628cdb9fdb55bc94026440f07961473a0eb140ae969889aeae")
    add_versions("v3.4.0", "b9f15c00079844b7eb82e613bab59a89204bdb9b1bacd1ef485fa74c8ef7ec77")
    add_versions("v3.4.1", "062587d0ec08b62bba888b1ec0dcb42a68a53043af7ae6b4d0185381543c1297")

    on_install(function (package)
        if package:version():gt("2.0.4") then
            os.cp("include/stringzilla/stringzilla.h", package:installdir("include"))
        else
            os.cp("stringzilla/stringzilla.h", package:installdir("include"))
        end
    end)

    on_test(function (package)
        if package:version():gt("2.0.0") then
            assert(package:has_cfuncs("sz_sort", {includes = "stringzilla.h"}))
        else
            assert(package:has_cxxfuncs("strzl_sort", {includes = "stringzilla.h", configs = {languages = "c++17"}}))
        end
    end)
