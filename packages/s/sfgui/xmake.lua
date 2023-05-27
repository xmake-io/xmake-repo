package("sfgui")
    set_homepage("https://github.com/TankOs/SFGUI")
    set_description("Simple and Fast Graphical User Interface")

    add_deps("sfml")

    if is_plat("windows", "linux") then
        set_urls("https://github.com/TankOs/SFGUI/archive/refs/tags/$(version).zip")
        add_versions("0.4.0", "4B23FC069E322221E5F6B7689EFF767EBC9C50CD88EF52E2165982BF683EC42D")
    elseif is_plat("macosx") then
        set_urls("https://github.com/TankOs/SFGUI/archive/refs/tags/$(version).tar.gz")
        add_versions("0.4.0", "2DFE95A2ECFED12AB2D4C591FBF6B10D16BBDEDEC2530545B4C2140AB01C05DC")
    end
    
    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DSFML_STATIC_LIBRARIES=YES")
        import("package.tools.cmake").install(package, configs)
    end)
package_end()