package("qmsetup")
    set_homepage("https://github.com/stdware/qmsetup")
    set_description("CMake Modules and Basic Libraries for C/C++ projects.")
    set_license("MIT")

    add_urls("https://github.com/stdware/qmsetup.git")
    add_versions("2024.04.23", "0b95afa778b99d9e9de772006555309b74ed32f4")

    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        assert(package:has_cxxincludes("qmsetup/qmsetup_global.h"))
    end)
