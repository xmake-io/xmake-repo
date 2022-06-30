package("mango")
    set_description("mango fun framework ")

    add_urls("https://github.com/adamo-in-motion/mango.git")

    add_deps("cmake", "opengl")
    if is_plat("linux") then
        add_deps("libx11", "xorgproto", "glx")
    end

    on_install("macosx", "linux", "windows", function (package)
        os.cd("build")
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("mango::math::sRGB", {configs = {languages = "c++17"}, includes = { "mango/mango.hpp" }}))
    end)
package_end()