package("cmsis")
    set_homepage("https://arm-software.github.io/CMSIS_6/latest/General/index.html")
    set_description("CMSIS (Cortex Microcontroller Software Interface Standard) is a vendor - neutral hardware abstraction layer for ARM processors.")
    set_license("Apache-2.0")

    add_urls("https://github.com/ARM-software/CMSIS_6/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ARM-software/CMSIS_6.git")

    add_versions("v6.1.0", "d8a044e4b50b7112476d6855a12c729ae2b70b3f77a2a038c23890e9a3515973")

    add_configs("rtos2",    {description = "Use the RTOS2", default = true, type = "boolean"})
    add_configs("driver",   {description = "Use the Driver", default = true, type = "boolean"})

    add_includedirs("include", "include/CMSIS/Core", 
                    "include/CMSIS/Core/a-profile", "include/CMSIS/Core/m-profile", "include/CMSIS/Core/r-profile",
                    "include/CMSIS/RTOS2", "include/CMSIS/Driver")

    on_install(function (package)
        for _, file in ipairs(os.files("**")) do
            io.replace(file, [[#include "RTE_Components.h"]], [[#include <RTE_Components.h>]], {plain = true})
        end
        os.cp("CMSIS/Core/Include/**", package:installdir("include/CMSIS/Core"))
        if package:config("rtos2") then
            io.writefile("xmake.lua", [[
                add_rules("mode.release", "mode.debug")
                target("CMSIS_RTOS2")
                    set_kind("$(kind)")
                    add_files("CMSIS/RTOS2/Source/*.c")
                    add_includedirs("CMSIS/RTOS2/Include", "CMSIS/Core/Include", "include/CMSIS/Core/a-profile", "include/CMSIS/Core/m-profile", "include/CMSIS/Core/r-profile")
            ]])
            import("package.tools.xmake").install(package)
            os.cp("CMSIS/RTOS2/Include/**", package:installdir("include/CMSIS/RTOS2"))
        end
        if package:config("driver") then
            os.cp("CMSIS/Driver/Include/**", package:installdir("include/CMSIS/Driver"))
        end
    end)

    on_test(function (package)
        assert(package:has_cincludes("cmsis_gcc.h"))
        if package:config("rtos2") then
            assert(package:has_cfuncs("osKernelInitialize", {includes = "cmsis_os2.h"}))
        end
    end)
