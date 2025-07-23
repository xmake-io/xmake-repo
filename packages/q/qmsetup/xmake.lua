package("qmsetup")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/stdware/qmsetup")
    set_description("CMake Modules and Basic Libraries for C/C++ projects.")
    set_license("MIT")

    add_urls("https://github.com/stdware/qmsetup.git", {submodules = false})
    add_versions("2024.09.02", "1331bf738dc6864f9ff927096f4dec8adc1c209f")

    add_deps("cmake")
    if is_plat("linux", "bsd", "macosx") then
        add_deps("patchelf")
    end
    add_deps("syscmdline")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DQMSETUP_STATIC_RUNTIME=" .. (package:has_runtime("MT", "MTd") and "ON" or "OFF"))

        os.mkdir(path.join(package:buildir(), "src/corecmd/pdb"))
        import("package.tools.cmake").install(package, configs)
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        assert(package:has_cxxincludes("qmsetup/qmsetup_global.h"))
    end)
