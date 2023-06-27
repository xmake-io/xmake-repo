package("glm")

    set_homepage("https://glm.g-truc.net/")
    set_description("OpenGL Mathematics (GLM)")

    set_urls("https://github.com/g-truc/glm/archive/$(version).tar.gz", 
             {version = function(version) return version:gsub("%+", ".") end})
    add_urls("https://github.com/g-truc/glm.git")
    add_versions("0.9.9+8", "7d508ab72cb5d43227a3711420f06ff99b0a0cb63ee2f93631b162bfe1fe9592")

    on_install(function (package)
        os.cp("glm", package:installdir("include"))
        os.cp("cmake", package:installdir("lib"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                glm::mat4 proj = glm::perspective(glm::radians(45.f), 1.33f, 0.1f, 10.f);
            }
        ]]}, {configs = {languages = "c++14"}, includes = {"glm/mat4x4.hpp", "glm/ext/matrix_clip_space.hpp"}}))
    end)
