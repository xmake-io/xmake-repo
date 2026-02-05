package("lvgl")

    set_homepage("https://lvgl.io")
    set_description("Light and Versatile Graphics Library")
    set_license("MIT")

    add_urls("https://github.com/lvgl/lvgl/archive/refs/tags/$(version).tar.gz",
             "https://github.com/lvgl/lvgl.git")
    add_versions("v9.4.0", "932c864de98431b38c5758a87f1de12bbee7b76943b8312bcf13d2f29ac14627")
    add_versions("v9.1.0", "6930f1605d305fcd43f31d5f470ecf4a013c4ce0980e78ee4c33b96a589bf433")
    add_versions("v9.0.0", "73ae6ef7b44b434b41f25755ce4f6f5d23c49c1c254c4b7774b5a9cf83a46b7f")
    add_versions("v8.0.2", "7136edd6c968b60f0554130c6903f16870fa26cda11a2290bc86d09d7138a6b4")
    add_versions("v8.2.0", "dd1cb1955ded3789c99e2dee7ac367393e87b5870cbce6b88930e378c3e91829")

    add_configs("shared",           {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    add_configs("color_depth",      {description = "Set color depth.", default = "32", type = "string", values = {"1", "8", "16", "32"}})
    add_configs("use_log",          {description = "Enable the log module.", default = false, type = "boolean"})
    add_configs("use_linux_drm",    {description = "Enable the linux drm module.", default = false, type = "boolean"})

    add_deps("cmake")

    on_load(function (package)
        if package:config("use_linux_drm") then
            package:add("syslinks", "drm")
        end
        package:add("links", "lvgl")
    end)

    on_install(function (package)
        io.replace("lv_conf_template.h", "#if 0", "#if 1")
        io.replace("lv_conf_template.h", "#define LV_BUILD_EXAMPLES -1", "#define LV_BUILD_EXAMPLES 0")
        io.replace("lv_conf_template.h", "#define LV_COLOR_DEPTH -16", "#define LV_COLOR_DEPTH " .. package:config("color_depth"))
        io.replace("lv_conf_template.h", "#define LV_USE_LOG -0", "#define LV_USE_LOG " .. (package:config("use_log") and "1" or "0"))
        if package:version():le("8.1.0") then
            io.replace("CMakeLists.txt", "add_library(lvgl STATIC ${SOURCES})", "add_library(lvgl STATIC ${SOURCES})\ninstall(TARGETS lvgl)\ninstall(FILES lvgl.h DESTINATION include/lvgl)\ninstall(DIRECTORY src DESTINATION include/lvgl FILES_MATCHING PATTERN \"*.h\")", {plain = true})
            io.replace("CMakeLists.txt", "if(ESP_PLATFORM)", "cmake_minimum_required(VERSION 3.15)\nif(ESP_PLATFORM)", {plain = true})
        end
        if package:config("use_linux_drm") then
            io.replace("lv_conf_template.h", "#define LV_USE_LINUX_DRM        0", "#define LV_USE_LINUX_DRM        1")
        end

        os.cp("lv_conf_template.h", "src/lv_conf.h")
        os.cp("lv_conf_template.h", "lv_conf.h")

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("lv_version_info", {includes = "lvgl/lvgl.h"}))
    end)
