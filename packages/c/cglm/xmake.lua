package("cglm")
    set_homepage("https://github.com/recp/cglm")
    set_description("📽 Highly Optimized Graphics Math (glm) for C")
    set_license("MIT")

    add_urls("https://github.com/recp/cglm/archive/refs/tags/$(version).tar.gz",
             "https://github.com/recp/cglm.git")
    add_versions("v0.9.0", "9b688bc52915cdd4ad8b7d4080ef59cc92674d526856d8f16bb3a114db1dd794")

    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test() {
                mat4 projection;
                glm_ortho(0.0f, 800, 600, 0.0f, -1.0f, 1.0f, projection);
            }
        ]]}, {includes = {"cglm/cglm.h"}}))
    end)
