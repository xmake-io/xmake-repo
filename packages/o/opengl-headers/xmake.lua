package("opengl-headers")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/KhronosGroup/OpenGL-Registry/")
    set_description("OpenGL, OpenGL ES, and OpenGL ES-SC API and Extension Registry")
    set_license("MIT")
                    
    add_urls("https://github.com/KhronosGroup/OpenGL-Registry.git")

    add_versions("2024.01.04", "ca491a0576d5c026f06ebe29bfac7cbbcf1e8332")

    add_deps("egl-headers")

    on_install(function (package)
        os.vcp("api/*", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test() {
                int version = GL_VERSION;
            }
        ]]}, {includes = "GLES3/gl3.h"}))
    end)
