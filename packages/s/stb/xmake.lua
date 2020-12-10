package("stb")

    set_homepage("https://github.com/nothings/stb")
    set_description("single-file public domain (or MIT licensed) libraries for C/C++")

    add_urls("https://github.com/nothings/stb.git")
    add_versions("0.0", "b42009b3b9d4ca35bc703f5310eedc74f584be58")

    on_install(function (package)
        os.cp("*.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("stbi_load_from_memory", {includes = "stb_image.h"}))
        assert(package:has_cfuncs("stb_include_string", {includes = "stb_include.h"}))
    end)