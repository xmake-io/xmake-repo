package("mimalloc")

    set_homepage("https://github.com/microsoft/mimalloc")
    set_description("mimalloc (pronounced 'me-malloc') is a general purpose allocator with excellent performance characteristics.")
    set_license("MIT")

    set_urls("https://github.com/microsoft/mimalloc/archive/v$(version).zip")
    add_versions("1.6.7", "5a12aac020650876615a2ce3dd8adc8b208cdcee4d9e6bcfc33b3fbe307f0dbf")

    add_configs("secure", {description = "Use a secured version of mimalloc", default = false, type = "boolean"})

    add_deps("cmake")

    if is_plat("windows") then
        add_syslinks("advapi32", "bcrypt")
    elseif is_plat("linux") then
        add_syslinks("pthread")
    elseif is_plat("android") then
        add_syslinks("atomic")
    end

    on_install("macosx", "windows", "linux", "android", function (package)
        local configs = {"-DMI_OVERRIDE=OFF"}
        table.insert(configs, "-DMI_BUILD_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DMI_BUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DMI_SECURE=" .. (package:config("secure") and "ON" or "OFF"))
        table.insert(configs, "-DMI_BUILD_TESTS=OFF")
        table.insert(configs, "-DMI_BUILD_OBJECT=OFF")
        --x64:mimalloc-redirect.lib/dll x86:mimalloc-redirect32.lib/dll
        if package:config("shared") and package:is_plat("windows") and package:is_arch("x86") then
            io.gsub("CMakeLists.txt", "-redirect", "-redirect32")
        end
        import("package.tools.cmake").install(package, configs, {buildir = "build"})

        os.rm(path.join(package:installdir("lib"), "mimalloc-*"))
        os.cp(path.join("build", package:debug() and "Debug" or "Release", "*"), package:installdir("lib"))
        os.cp(path.join("build", "*.a"), package:installdir("lib"))
        if package:config("shared") then
            os.cp("build/*.so", package:installdir("lib"))
            os.cp("build/*.dll", package:installdir("lib"))
        end
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mi_malloc", {includes = "mimalloc.h"}))
    end)