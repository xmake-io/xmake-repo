package("ndicapi")
    set_homepage("https://github.com/PlusToolkit/ndicapi")
    set_description("A common C API for communicating with NDI Polaris and Aurora devices.")
    set_license("MIT")

    add_urls("https://github.com/PlusToolkit/ndicapi.git")
    add_versions("2026.09.06", "615ee27d06ddbc167745411946628bc5a5e246d5")

    add_configs("python", {description = "Build python.", default = false, type = "boolean"})
    add_deps("cmake")

    if is_plat("windows", "mingw") then
        add_syslinks("wsock32", "ws2_32")
    end

    on_install(function (package)    
        local configs = {
            "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"),
            "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"),
            "-DBUILD_PYTHON=" .. (package:config("python") and "ON" or "OFF"),
            "-Dndicapi_BUILD_APPLICATIONS=OFF",
        }
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("ndiOpenSerial", {includes = "ndicapi.h"}))
    end)
