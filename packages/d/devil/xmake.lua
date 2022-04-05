package("devil")

    set_homepage("https://sourceforge.net/projects/openil/")
    set_description("Developer's Image Library (DevIL) is a cross-platform image library utilizing a simple syntax to load, save, convert, manipulate, filter and display a variety of images with ease.")
    set_license("LGPL-2.1")

    add_urls("https://sourceforge.net/projects/openil/files/DevIL/$(version)/DevIL-$(version).zip")
    add_versions("1.8.0", "451337f392c65bfb83698a781370534dc63d7bafca21e9b37178df0518f7e895")

    add_patches("1.8.0", path.join(os.scriptdir(), "patches", "1.8.0", "jp2.patch"), "cbee7e2a42b1a687fe7a2e6397611088fc2c16f897076e39db4a2be87fba5c51")
    add_patches("1.8.0", path.join(os.scriptdir(), "patches", "1.8.0", "static.patch"), "28a4fc42e9cc735a3291d87a1cb818ea9ed07f27afa2b52353d5a1d15fc8a6f5")

    add_deps("cmake")
    local configdepopts = {png     = {"libpng", "PNG"},
                           tiff    = {"libtiff", "TIFF"},
                           jpeg    = {"libjpeg-turbo", "JPEG"},
                           jasper  = {"jasper", "Jasper"},
                           squish  = {"libsquish", "libSquish"},
                           openexr = {"openexr", "OpenEXR"},
                           lcms    = {"lcms", "LCMS2"},
                           mng     = {"libmng", "MNG"}}
    for config, depopt in pairs(configdepopts) do
        add_configs(config, {description = "Build with " .. depopt[2] .. " support.", default = (config == "png"), type = "boolean"})
    end

    on_load("windows", "macosx", "linux", function (package)
        if package:is_plat("windows") and not package:config("shared") then
            package:add("defines", "IL_STATIC_LIB")
        end
        for config, depopt in pairs(configdepopts) do
            if package:config(config) then
                package:add("deps", depopt[1])
            end
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        os.cd("DevIL")
        local configs = {"-DIL_USE_DXTC_NVIDIA=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        for config, depopt in pairs(configdepopts) do
            table.insert(configs, "-DCMAKE_DISABLE_FIND_PACKAGE_" .. depopt[2] .. "=" .. (package:config(config) and "OFF" or "ON"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ilInit", {includes = "IL/il.h"}))
    end)
