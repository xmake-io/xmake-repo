package("glshaderpp")
    set_kind("library", {headeronly = true})
    set_homepage("https://gitlab-lepuy.iut.uca.fr/opengl/glshaderpp")
    set_description("A lightweight header-only library to compile and link OpenGL GLSL shaders.")
    set_license("LGPL-3.0-or-later")

    add_urls("https://gitlab-lepuy.iut.uca.fr/opengl/glshaderpp/-/archive/$(version)/glshaderpp-$(version).tar.bz2",
             "https://gitlab-lepuy.iut.uca.fr/opengl/glshaderpp.git")

    add_versions("v1.0.0", "81b47b90e90d8be19d0421d67f4fc735d74d285a5f516b99ee7dc49d7933ecf6")

    add_deps("glew")

    on_install("linux", "macosx", "mingw", "windows", function (package)
        os.cp("GLShaderPP/public/GLShaderPP", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <GL/glew.h>
            #include <GLShaderPP/Shader.h>
            #include <GLShaderPP/ShaderException.h>
            #include <GLShaderPP/ShaderProgram.h>

            void test() {
                GLShaderPP::CShaderException e("If you read this, GLShaderPP is happy :)",
                                            GLShaderPP::CShaderException::ExceptionType::LinkError);
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
