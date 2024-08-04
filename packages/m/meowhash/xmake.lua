package("meowhash")

    set_kind("library", {headeronly = true})
    set_homepage("https://mollyrocket.com/meowhash")
    set_description("Official version of the Meow hash, an extremely fast level 1 hash")
    set_license("zlib")

    add_urls("https://github.com/cmuratori/meow_hash.git")

    add_versions("1.0.0", "b080caa7e51576fe3151c8976110df7966fa6a38")

    if is_plat("linux", "macosx", "bsd") then
        add_cxflags("-maes", "-mpclmul", "-mssse3")
    end

    on_install("macosx", "windows", "linux", "bsd", function (package)
        os.cp("meow_hash_x64_aesni.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("MeowHash", {includes = "meow_hash_x64_aesni.h"}))
    end)
