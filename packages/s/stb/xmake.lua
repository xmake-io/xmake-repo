package("stb")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/nothings/stb")
    set_description("single-file public domain (or MIT licensed) libraries for C/C++")

    add_urls("https://github.com/nothings/stb.git")
    add_versions("0.0", "3a1174060a7dd4eb652d4e6854bc4cd98c159200")
    
    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::stb")
    elseif is_plat("linux") then
        add_extsources("pacman::stb", "apt::libstb-dev")
    end

    on_install(function (package)
        os.cp("*.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("stbi_load_from_memory", {includes = "stb_image.h"}))
        assert(package:has_cfuncs("stb_include_string", {includes = "stb_include.h"}))
    end)
