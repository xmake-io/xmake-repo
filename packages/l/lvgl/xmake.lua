package("lvgl")

    set_homepage("https://lvgl.io")
    set_description("Light and Versatile Graphics Library")
    set_license("MIT")

    add_urls("https://github.com/lvgl/lvgl/archive/refs/tags/$(version).tar.gz",
             "https://github.com/lvgl/lvgl.git")
    add_versions("v9.1.0", "6930f1605d305fcd43f31d5f470ecf4a013c4ce0980e78ee4c33b96a589bf433")
    add_versions("v9.0.0", "73ae6ef7b44b434b41f25755ce4f6f5d23c49c1c254c4b7774b5a9cf83a46b7f")
    add_versions("v8.0.2", "7136edd6c968b60f0554130c6903f16870fa26cda11a2290bc86d09d7138a6b4")
    add_versions("v8.2.0", "dd1cb1955ded3789c99e2dee7ac367393e87b5870cbce6b88930e378c3e91829")

    add_configs("shared",      {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    add_configs("color_depth", {description = "Set color depth.", default = "32", type = "string", values = {"1", "8", "16", "32"}})
    add_configs("use_log",     {description = "Enable the log module.", default = false, type = "boolean"})
    
    -- 新增配置项
    add_configs("tick_custom", {description = "Use custom tick.", default = false, type = "boolean"})
    add_configs("mem_custom", {description = "Use custom memory management.", default = false, type = "boolean"})
    add_configs("color_16_swap", {description = "Swap 16-bit color.", default = false, type = "boolean"})
    add_configs("use_fs_stdio", {description = "Enable FS stdio support.", default = false, type = "boolean"})
    add_configs("use_freetype", {description = "Enable FreeType font support.", default = false, type = "boolean"})
    add_configs("use_gpu_stm32_dma2d", {description = "Use STM32's DMA2D GPU.", default = false, type = "boolean"})
    add_configs("sprintf_custom", {description = "Use custom snprintf functions.", default = false, type = "boolean"})
    add_configs("sprintf_use_float", {description = "Use float in snprintf.", default = false, type = "boolean"})

    add_deps("cmake")
    on_install(function (package)
        os.mv("lv_conf_template.h", "src/lv_conf.h")
        io.replace("src/lv_conf.h", "#if 0", "#if 1")
        io.replace("src/lv_conf.h", "#define LV_BUILD_EXAMPLES -1", "#define LV_BUILD_EXAMPLES 0")
        io.replace("src/lv_conf.h", "#define LV_COLOR_DEPTH -16", "#define LV_COLOR_DEPTH " .. package:config("color_depth"))
        io.replace("src/lv_conf.h", "#define LV_USE_LOG -0", "#define LV_USE_LOG " .. (package:config("use_log") and "1" or "0"))

        -- 处理新配置项
        io.replace("src/lv_conf.h", "#define LV_TICK_CUSTOM -0", "#define LV_TICK_CUSTOM " .. (package:config("tick_custom") and "1" or "0"))
        io.replace("src/lv_conf.h", "#define LV_MEM_CUSTOM -0", "#define LV_MEM_CUSTOM " .. (package:config("mem_custom") and "1" or "0"))
        io.replace("src/lv_conf.h", "#define LV_COLOR_16_SWAP -0", "#define LV_COLOR_16_SWAP " .. (package:config("color_16_swap") and "1" or "0"))
        io.replace("src/lv_conf.h", "#define LV_USE_FS_STDIO -0", "#define LV_USE_FS_STDIO " .. (package:config("use_fs_stdio") and "1" or "0"))
        io.replace("src/lv_conf.h", "#define LV_USE_FREETYPE -0", "#define LV_USE_FREETYPE " .. (package:config("use_freetype") and "1" or "0"))
        
        io.replace("src/lv_conf.h", "#define LV_USE_GPU_STM32_DMA2D -0", "#define LV_USE_GPU_STM32_DMA2D " .. (package:config("use_gpu_stm32_dma2d") and "1" or "0"))
        if package:config("use_gpu_stm32_dma2d") then
            io.replace("src/lv_conf.h", "// #define LV_GPU_DMA2D_CMSIS_INCLUDE", "#define LV_GPU_DMA2D_CMSIS_INCLUDE")
        end

        io.replace("src/lv_conf.h", "#define LV_SPRINTF_CUSTOM -0", "#define LV_SPRINTF_CUSTOM " .. (package:config("sprintf_custom") and "1" or "0"))
        if package:config("sprintf_custom") then
            io.replace("src/lv_conf.h", "#define LV_SPRINTF_USE_FLOAT -0", "#define LV_SPRINTF_USE_FLOAT " .. (package:config("sprintf_use_float") and "1" or "0"))
            io.replace("src/lv_conf.h", "#define LV_SPRINTF_INCLUDE <stdio.h>", "#define LV_SPRINTF_INCLUDE <stdio.h>")
            io.replace("src/lv_conf.h", "#define lv_snprintf  snprintf", "#define lv_snprintf  snprintf")
            io.replace("src/lv_conf.h", "#define lv_vsnprintf vsnprintf", "#define lv_vsnprintf vsnprintf")
        else
            io.replace("src/lv_conf.h", "#define LV_SPRINTF_USE_FLOAT -0", "#define LV_SPRINTF_USE_FLOAT 0")
        end

        if package:version():le("8.1.0") then
            io.replace("CMakeLists.txt", "add_library(lvgl STATIC ${SOURCES})", "add_library(lvgl STATIC ${SOURCES})\ninstall(TARGETS lvgl)\ninstall(FILES lvgl.h DESTINATION include/lvgl)\ninstall(DIRECTORY src DESTINATION include/lvgl FILES_MATCHING PATTERN \"*.h\")", {plain = true})
            io.replace("CMakeLists.txt", "if(ESP_PLATFORM)", "cmake_minimum_required(VERSION 3.15)\nif(ESP_PLATFORM)", {plain = true})
        end

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("lv_version_info", {includes = "lvgl/lvgl.h"}))
    end)
