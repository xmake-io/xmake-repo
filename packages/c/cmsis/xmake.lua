package("cmsis")
    set_kind("library", {headeronly = true})
    set_homepage("https://arm-software.github.io/CMSIS_6/latest/General/index.html")
    set_description("CMSIS (Cortex Microcontroller Software Interface Standard) is a vendor - neutral hardware abstraction layer for ARM processors.")
    set_license("Apache-2.0")

    add_urls("https://github.com/ARM-software/CMSIS_6/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ARM-software/CMSIS_6.git")

    add_versions("v6.1.0", "d8a044e4b50b7112476d6855a12c729ae2b70b3f77a2a038c23890e9a3515973")

    add_configs("core",     {description = "Use the Core", default = true, type = "boolean"})
    add_configs("rtos2",    {description = "Use the RTOS2", default = true, type = "boolean"})
    add_configs("driver",   {description = "Use the Driver", default = true, type = "boolean"})

    add_includedirs("include", "include/CMSIS/Core", "include/CMSIS/RTOS2", "include/CMSIS/Driver")

    on_install(function (package)
        if package:config("core") then
            os.cp("CMSIS/Core/Include/**", path.join(package:installdir("include"), "CMSIS", "Core"))
        end
        if package:config("rtos2") then
            os.cp("CMSIS/RTOS2/Include/**", path.join(package:installdir("include"), "CMSIS", "RTOS2"))
            os.cp("CMSIS/RTOS2/Source/**", path.join(package:installdir("include"), "CMSIS", "RTOS2"))
        end
        if package:config("driver") then
            os.cp("CMSIS/Driver/Include/**", path.join(package:installdir("include"), "CMSIS", "Driver"))
        end
    end)

    on_test(function (package)
        assert(package:has_cincludes("cmsis_gcc.h"))
    end)
