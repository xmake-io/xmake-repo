package("glbinding")
    set_homepage("https://glbinding.org")
    set_description("A C++ binding for the OpenGL API, generated using the gl.xml specification. ")
    set_license("MIT")

    add_urls("https://github.com/cginternals/glbinding/archive/refs/tags/$(version).tar.gz",
             "https://github.com/cginternals/glbinding.git")

    add_versions("v3.3.0", "a0aa5e67b538649979a71705313fc2b2c3aa49cf9af62a97f7ee9a665fd30564")
    add_versions("v3.1.0", "6729b260787108462ec6d8954f32a3f11f959ada7eebf1a2a33173b68762849e")
    add_versions("v3.0.2", "23a383f3ed31af742a4952b6c26faa9c346dd982ba9112c68293a578a6e542ad")

    add_versions("v2.1.4", "cb5971b086c0d217b2304d31368803fd2b8c12ee0d41c280d40d7c23588f8be2")
    add_versions("v2.1.3", "21e219a5613c7de3668bea3f9577dc925790aaacfa597d9eb523fee2e6fda85c")
    add_versions("v2.1.2", "e1303f017242c19993ba3d90581a7b1d9c108f0fb36db2be877d0554e1e9ed6f")
    add_versions("v2.1.1", "cf5f32aa09c3427b0f5c9626fe83aa1473da037d55b6f14f8753b2d9159cc91d")
    add_versions("v2.0.0", "fd09a469b9bd84e44cd0a33e76fb62413678a926601934b3eb0d8956ba11ec3a")

    if is_plat("linux") then
        add_extsources("apt::libglbinding-dev", "pacman::glbinding")
    elseif is_plat("macosx") then
        add_extsources("brew::glbinding")
    end

    add_deps("cmake", "khrplatform")

    on_load(function (package)
        if package:version():major() < 3 then
            if is_plat("linux") then
                package:add("deps", "glx")
            elseif is_plat("windows", "mingw") then
                package:add("deps", "opengl")
            end
        end
    end)

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DOPTION_BUILD_TESTS=OFF")
        table.insert(configs, "-DOPTION_BUILD_OWN_KHR_HEADERS=ON")

        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        -- Breaking changes since v3.x.x
        if package:version():major() >= 3 then
            assert(package:check_cxxsnippets({test = [[
                #include <glbinding/glbinding.h>
                #include <glbinding/gl/gl.h>
                using namespace gl;

                void test(int argc, char** argv) {
                    glbinding::initialize(nullptr);

                    glBegin(GL_TRIANGLES);
                    glEnd();
                }
            ]]}, {configs = {languages = "cxx11"}}))
        else
            assert(package:check_cxxsnippets({test = [[
                #include <glbinding/Binding.h>
                #include <glbinding/gl/gl.h>
                using namespace gl;

                void test(int argc, char** argv) {
                    glbinding::Binding::initialize();

                    glBegin(GL_TRIANGLES);
                    glEnd();
                }
            ]]}, {configs = {languages = "cxx11"}}))
        end
    end)
