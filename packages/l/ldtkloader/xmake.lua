package("ldtkloader")
    set_homepage("https://github.com/Madour/LDtkLoader")
    set_description("A C++11 loader for levels and tile maps created with LDtk (Level Designer ToolKit)")
    set_license("zlib")

    add_urls("https://github.com/Madour/LDtkLoader/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Madour/LDtkLoader.git")

    add_versions("1.5.3.1", "22c736c7045522cc659f83d1a4288c1d5a1bbd620c425f9fec6dd3219d2f950a")

    add_configs("no_throw", {description = "Disable exceptions and replace throws with exit()", default = false, type = "boolean"})
    add_configs("field_optional", {description = "Enable std::optional accessors", default = false, type = "boolean"})

    on_install("windows", "linux", "macosx", function (package)
        import("package.tools.cmake").install(package, {
            configs = {
                "-DLDTK_BUILD_SFML_EXAMPLE=OFF",
                "-DLDTK_BUILD_SDL_EXAMPLE=OFF",
                "-DLDTK_BUILD_RAYLIB_EXAMPLE=OFF",
                "-DLDTK_BUILD_API_TEST=OFF",
                "-DLDTK_NO_THROW=" .. (package:config("no_throw") and "ON" or "OFF"),
                "-DLDTK_FIELD_PUBLIC_OPTIONAL=" .. (package:config("field_optional") and "ON" or "OFF")
            }
        })
    end)

    on_test(function (package)
        assert(package:has_cxxincludes("LDtkLoader/Project.hpp", {configs = {languages = "c++17"}}))
    end)
