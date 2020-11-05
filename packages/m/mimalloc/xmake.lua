package("mimalloc")

    set_homepage("https://github.com/microsoft/mimalloc")
    set_description("mimalloc (pronounced 'me-malloc') is a general purpose allocator with excellent performance characteristics.")

    set_urls("https://github.com/microsoft/mimalloc/archive/v$(version).zip")

    add_versions("1.6.7", "5a12aac020650876615a2ce3dd8adc8b208cdcee4d9e6bcfc33b3fbe307f0dbf")

    add_configs("secure", {description = "Use a secured version of mimalloc", default = false, type = "boolean"})

    add_deps("cmake")

    if is_plat("windows") then
        add_syslinks("advapi32")
    elseif is_plat("linux") then
        add_syslinks("pthread")
    end

    on_install("windows", "linux", function (package)
        local configs = {}
        table.insert(configs, "-DMI_OVERRIDE=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DMI_BUILD_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DMI_BUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DMI_SECURE=" .. (package:config("secure") and "ON" or "OFF"))
        table.insert(configs, "-DMI_BUILD_TESTS=OFF")
        table.insert(configs, "-DMI_BUILD_OBJECT=OFF")

        import("package.tools.cmake").install(package, configs, {buildir = "build"})

        os.cp(path.join("build", package:debug() and "Debug" or "Release", "*"), package:installdir("lib"))
        os.cp(path.join("build", "*.a"), package:installdir("lib"))
        os.cp("include/mimalloc.h", package:installdir("include"), {rootdir = "include"})
        os.cp("include/mimalloc-new-delete.h", package:installdir("include"), {rootdir = "include"})
        os.cp("include/mimalloc-override.h", package:installdir("include"), {rootdir = "include"})
    end)
