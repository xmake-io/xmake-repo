package("egl-headers")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/KhronosGroup/EGL-Registry")
    set_description("EGL API and Extension Registry")
    set_license("MIT")
 
    add_urls("https://github.com/KhronosGroup/EGL-Registry.git")

    add_versions("2023.12.16", "a03692eea13514d9aef01822b2bc6575fcabfac2")

    on_install(function (package)
        os.vcp("api/EGL", package:installdir("include"))
        os.vcp("api/KHR", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test() {
                int version = EGL_VERSION;
            }
        ]]}, {includes = "EGL/egl.h"}))
    end)
