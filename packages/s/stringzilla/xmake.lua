package("stringzilla")
    set_kind("library", {headeronly = true})
    set_homepage("https://ashvardanian.com/posts/stringzilla/")
    set_description("Up to 10x faster strings for C, C++, Python, Rust, Swift & Go, leveraging NEON, AVX2, AVX-512, SVE, & SWAR to accelerate search, hashing, sort, edit distances, and memory ops 🦖")
    set_license("Apache-2.0")

    add_urls("https://github.com/ashvardanian/StringZilla/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ashvardanian/StringZilla.git")

    add_configs("cpp", {description = "Enable C++ support.", default = true, type = "boolean"})
    add_configs("stringzillas", {description = "Enable advanced API support.", default = false, type = "boolean"})

    add_versions("v4.6.0", "cba35adab6f0b25d277451e0130798d1a8742e4c52d0ab29c5a5fca54242d0e3")
    add_versions("v4.5.1", "2b706dff69baa28911f7df445f62391b8cc4b6b599c542a015dd685e7ea01948")
    add_versions("v4.4.2", "5c49782bc7f5a7392c8b960248d3cc9ba87b3a9629b665f731a2d407fefe425b")
    add_versions("v4.3.0", "59c31f316ee7d7dc9f8e4dcb0ef7bc39d4b067565335036fbed8d41e92d0a022")
    add_versions("v4.0.14", "a8485e26057725910dded847a2f21f64397dcd7a2b25df79a42759e304bdcf22")
    add_versions("v4.0.0", "17589e9c4b1e21caaec02305a68b03f11c4aec8d3edeb300808f6b4b4b3d725b")
    add_versions("v3.12.6", "1255cac3aced48b4b73e045829a80e3122c54eca5621274073839c9036f48fe8")
    add_versions("v3.12.5", "52d107322b59c15b653d1eab3732c575b82eb44a9d5e3ff752b1f2902b71e8ee")
    add_versions("v3.12.4", "f5ae5ccc713e96e80dee92bc67efdc22b50cd7a1ba5d535191628606e0e2610b")
    add_versions("v3.12.3", "94f10a6ee4f9231afe3dd314cb1cbe5901e9098c44ba538362c529d79ff01ce5")
    add_versions("v3.12.2", "a9d8518766a29b605bcd3a26c1d12e00d6fcddfc3541687d6adafd4aa7fe1c5f")
    add_versions("v3.12.1", "fcbd53fe4e827fa49eb1153f1116095a719a57fa6fb0a8680ba713088ad29d3e")
    add_versions("v3.11.3", "8ca47c1f1bb8ba67a89c54951fff08483087fa637a43941de1a44fb04a2ba83e")
    add_versions("v3.11.1", "44d2a38ddd610e6e22fc3ed83a5a453f9887b45746dd250d68c4d690b860c8f0")
    add_versions("v3.11.0", "8267ca9bf33efba61e8028357e2589fc248c4edc0226181faa027f5affac577b")
    add_versions("v3.10.11", "6782c5563203f82f34fc9aaeaad3785145bb73e93426a128d92d00f239f019eb")
    add_versions("v3.10.10", "7d6098f660395e0b49f4b4a48f41d12a3067981f2cead52aee626bf40912f253")
    add_versions("v3.10.9", "4ad0bf97628176f689aa87030a696ff0e8e20db0b8909b0b1688b06303886342")
    add_versions("v3.10.8", "cafa29d22866e4c7242aee4a00efa41748c10d872c6eda3ae96ad118ccf63377")
    add_versions("v3.10.7", "e9f9081d796718763c06a65bb3a5dabe102b757ad0dff18bd7ac8c08217d7e4c")
    add_versions("v3.10.6", "041d122d4defc79b0d007ceb136ac3c72c9eb8797b28487b446e9710bd836e78")
    add_versions("v3.10.5", "25c85e6e5cc72a359e022e3c732dc930f190e735e2ca81782f32edffa8a4a860")
    add_versions("v3.10.0", "69729a1403c4609256f861a0221e5331f836b4945f6848472e81183726e436e6")
    add_versions("v3.9.8", "2efaf2eb9b10287efa51fffa4b1e05cf7b426e3404c3c4fd3c141291846c733c")
    add_versions("v3.9.6", "21577e967d79155f5bcbe9bfd885dd817a79666f384fb2a955c0ac5dbf0657a3")
    add_versions("v3.9.5", "2132ffc56ded5951a00f3c7046328f2cfb0c59121252f7303cd33fbe93bc8e97")
    add_versions("v3.8.4", "4132957633d28ce2651e587f2ab736cdf174e61b8ab1bcef453b21d40a2d872e")
    add_versions("v3.8.3", "17c4527012495b66028236f62223a7c84c32c14dce91821f2ebb36a67bce489b")
    add_versions("v3.8.2", "1f1e940c6c74aecc06964aa650fe23d0b64570b5d4d83a820d2d11428050d853")
    add_versions("v3.8.1", "6ed752ed72024c66468800d92861cf8e213dab8ee153c04f7d4e23e537686e5f")
    add_versions("v3.8.0", "ccfe9ccbdc34f72f8fb76bdab2ace37e29453dd6bcd16837e8e4a9e7b22c74bb")
    add_versions("v3.7.3", "85bc8c990c0a6d6a924d062cf1166b0ce120e48e9f398518930cd8d493e0d593")
    add_versions("v3.7.2", "ff84205286a2d8454a17f000013c634e1620df27c088eddea55fa83ce40274de")
    add_versions("v3.7.1", "60cc703b8e8ad317db4d114edc355c8b57c2c5a927d546aea800b810e676e9b7")
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
    add_versions("v3.4.1", "062587d0ec08b62bba888b1ec0dcb42a68a53043af7ae6b4d0185381543c1297")
    add_versions("v3.4.0", "b9f15c00079844b7eb82e613bab59a89204bdb9b1bacd1ef485fa74c8ef7ec77")
    add_versions("v3.3.1", "3f6bcf9ce10089628cdb9fdb55bc94026440f07961473a0eb140ae969889aeae")
    add_versions("v3.3.0", "15924a562e3166840a5385959dcc190eb40b49cec82900fde319774963c5d85a")
    add_versions("v3.2.0", "12789c5f81d63e569e7a1221933aa371274fa3f22f8143f7bd65b5248c66a7d9")
    add_versions("v3.1.2", "aa25438112551eab9eec9a532749e430fe26b6562adae517c56ce0fe762af2b6")
    add_versions("v3.1.1", "6f7905ee481fda0230a55075f9f4704284f2c18bd53d9e1c6ef78e3eaf29cea9")
    add_versions("v3.1.0", "32580513dbc054cc23941d36e19741bce1fa106c3031670065719eb4b95afde8")
    add_versions("v3.0.0", "50bc3544d97c6c1d82022a78af4ab062010a1d35096330cb84d952b0cf7d54fb")
    add_versions("v2.0.4", "440d3d586f8cfe96bc7648f01f2d3c514c4e2dc22446caeb50599383d1970ed2")
    add_versions("v2.0.3", "6b52a7b4eb8383cbcf83608eaa08e5ba588a378449439b73584713a16d8920e3")
    add_versions("v1.2.2", "2e17c49965841647a1c371247f53b2f576e5fb32fe4b84a080d425b12f17703c")

    add_patches("v4.0.0", path.join(os.scriptdir(), "patches", "4.0.0", "fix_odr_violation_for_raise.patch"), "f8add457114b63ed846ee9ca7568d623eb70af5461a7b62a6f2c6a9c62488dc8")

    on_install("android|!armeabi-v7a or (!android and !cross)", function (package)
        if package:version():ge("4.0.0") then
            os.cp("include/stringzilla/*.h", package:installdir("include/stringzilla"))
            if package:config("cpp") then
                os.cp("include/stringzilla/*.hpp", package:installdir("include/stringzilla"))
                os.cp("include/stringzilla/module.modulemap", package:installdir("include/stringzilla"))
            end
            if not package:is_plat("android", "iphoneos", "wasm") and package:config("stringzillas") then
                os.cp("include/stringzillas", package:installdir("include/stringzillas"))
            end
            return
        end

        if package:version():gt("3.0.0") then
            if package:version():gt("3.9.0") then
                os.cp("include/stringzilla/drafts.h", package:installdir("include/stringzilla"))
            else
                os.cp("include/stringzilla/experimental.h", package:installdir("include/stringzilla"))
            end
            if package:config("cpp") then
                os.cp("include/stringzilla/stringzilla.hpp", package:installdir("include/stringzilla"))
            end
        end

        if package:version():gt("2.0.4") then
            os.cp("include/stringzilla/stringzilla.h", package:installdir("include/stringzilla"))
        else
            os.cp("stringzilla/stringzilla.h", package:installdir("include/stringzilla"))
        end
    end)

    on_test(function (package)
        if package:version():gt("3.0.0") then
            if package:config("cpp") then
                assert(package:check_cxxsnippets({test = [[
                    #include <stringzilla/stringzilla.hpp>
                    static void test() {
                        ashvardanian::stringzilla::string s = "hello";
                        assert(s == "hello");
                    }
                ]]}, {configs = {languages = "c++11"}, includes = "stringzilla/stringzilla.hpp"}))
                if package:version():ge("4.0.0") then
                    assert(package:has_cfuncs("sz_sequence_argsort", {includes = "stringzilla/sort.h"}))
                else
                    assert(package:has_cfuncs("sz_sort", {includes = "stringzilla/stringzilla.h"}))
                end
            end
        elseif package:version():gt("2.0.0") then
            assert(package:has_cfuncs("sz_sort", {includes = "stringzilla/stringzilla.h"}))
        else
            assert(package:has_cxxfuncs("strzl_sort", {includes = "stringzilla/stringzilla.h", configs = {languages = "c++17"}}))
        end
    end)
