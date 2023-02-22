package("stb")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/nothings/stb")
    set_description("single-file public domain (or MIT licensed) libraries for C/C++")

    add_urls("https://github.com/nothings/stb.git")
    add_versions("2019.02.07", "756166e853a1d16a14fbc132384b98512cfce117")
    add_versions("2021.07.13", "3a1174060a7dd4eb652d4e6854bc4cd98c159200")
    add_versions("2021.09.10", "af1a5bc352164740c1cc1354942b1c6b72eacb8a")
    add_versions("2023.01.30", "5736b15f7ea0ffb08dd38af21067c314d6a3aae9")
    
    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::stb")
    elseif is_plat("linux") then
        add_extsources("pacman::stb", "apt::libstb-dev")
    end

    add_includedirs("include", "include/stb")

    on_install(function (package)
        os.cp("*.h", package:installdir("include/stb"))
        os.cp("*.c", package:installdir("include/stb"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("stbi_load_from_memory", {includes = "stb/stb_image.h"}))
        if package:version():gt("2019.02.07") then
            assert(package:has_cfuncs("stb_include_string", {includes = "stb/stb_include.h"}))
        end
    end)
