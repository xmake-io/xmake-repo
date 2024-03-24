package("stringzilla")
    set_kind("library", {headeronly = true})
    set_homepage("https://ashvardanian.com/posts/stringzilla/")
    set_description("Up to 10x faster string search, split, sort, and shuffle for long strings and multi-gigabyte files in Python and C, leveraging SIMD with just a few lines of Arm Neon and x86 AVX2 & AVX-512 intrinsics 🦖")
    set_license("Apache-2.0")

    add_urls("https://github.com/ashvardanian/StringZilla/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ashvardanian/StringZilla.git")

    add_versions("v3.7.0", "214d926fc827e5975fabe63f112cbd4d676d5ceb1c37fc4d6d83785a50c518e0")
    add_versions("v3.6.8", "9e29b31f4924fe89c835f40d852e3f8b62e3dfb164a657283bdc92ce014286cc")
    add_versions("v3.6.7", "d7f8ed81367047bade36f550880e1df9fed60d08722a2f58405434690b3a1ffe")
    add_versions("v3.6.6", "41a39fc8873b30fc6986cc9f7a80cd1b9f119a0ff3dbe5d6400b1c9fd3cb0f38")
    add_versions("v3.6.5", "047083d8778bbb684a0c335e8fd91b036e5b0e1db4c8ecbf3c93a37ffe8ca907")
    add_versions("v3.6.4", "342619f79c259fdf338c60678145123244fe1101b2eb077ef84bf9cc3cec64a5")
    add_versions("v3.6.3", "3f570bd7c9e9f780259148b42335e8eafcce70c96fe1e33cbf2b90d5d7ca68c4")
    add_versions("v3.6.2", "5e6905348afb4ea55195e20b684abf8ad1e1373dbe2680d1d238cb27f59020b8")
    add_versions("v3.6.1", "416ca84773b2fa2f401bfa767d69bb146e525f163c4edf785e9dfbdfb2411fd9")
    add_versions("v3.6.0", "a8b0eea55c535e72451fc1ca4c6c8531268b1fdf2562acf38ca6030b5c97d64d")
    add_versions("v3.5.0", "a7b990e32859683496b4c16e4e756cc862316f78f676fc642b14ddc4190cf39a")
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


    on_install("android|!armeabi-v7a",function (package)
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
