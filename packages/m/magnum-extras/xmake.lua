package("magnum-extras")

    set_homepage("https://magnum.graphics/")
    set_description("Extras for magnum, Lightweight and modular C++11/C++14 graphics middleware for games and data visualization.")
    set_license("MIT")

    add_urls("https://github.com/mosra/magnum-extras/archive/refs/tags/$(version).zip",
             "https://github.com/mosra/magnum-extras.git")
    add_versions("v2020.06", "9a53b503b45580dbaa54f852f65755330f5ace81be9d2a4c4605091d5f58d9bb")

    add_configs("ui",         {description = "Build the ui library.", default = false, type = "boolean"})
    add_configs("player",     {description = "Build the magnum-player executable.", default = false, type = "boolean"})
    add_configs("ui_gallery", {description = "Build the magnum-ui-gallery executable.", default = false, type = "boolean"})

    add_deps("cmake", "magnum")

    on_install("windows", "linux", "macosx", function (package)
        local configs = {"-DBUILD_TESTS=OFF", "-DLIB_SUFFIX="}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DWITH_UI=" .. (package:config("ui") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_PLAYER=" .. (package:config("player") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_UI_GALLERY=" .. (package:config("ui_gallery") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                auto year = MAGNUMEXTRAS_VERSION_YEAR;
                auto month = MAGNUMEXTRAS_VERSION_MONTH;
            }
        ]]}, {configs = {languages = "c++14"}, includes = "Magnum/versionExtras.h"}))
    end)
