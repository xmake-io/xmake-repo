package("cglm")
    set_homepage("https://github.com/recp/cglm")
    set_description("📽 Highly Optimized Graphics Math (glm) for C")
    set_license("MIT")

    add_urls("https://github.com/recp/cglm/archive/refs/tags/$(version).tar.gz",
             "https://github.com/recp/cglm.git")

    add_versions("v0.9.6", "be5e7d384561eb0fca59724a92b7fb44bf03e588a7eae5123a7d796002928184")
    add_versions("v0.9.4", "101376d9f5db7139a54db35ccc439e40b679bc2efb756d3469d39ee38e69c41b")
    add_versions("v0.9.3", "4eda95e34f116c36203777f4fe770d64a3158b1450ea40364abb111cf4ba4773")
    add_versions("v0.9.2", "5c0639fe125c00ffaa73be5eeecd6be999839401e76cf4ee05ac2883447a5b4d")
    add_versions("v0.9.0", "9b688bc52915cdd4ad8b7d4080ef59cc92674d526856d8f16bb3a114db1dd794")

    add_deps("cmake")

    if on_check then
        on_check("windows", function (package)
            import("core.tool.toolchain")
            import("core.base.semver")

            local msvc = toolchain.load("msvc", {plat = package:plat(), arch = package:arch()})
            if msvc then
                local vs_sdkver = msvc:config("vs_sdkver")
                assert(vs_sdkver and semver.match(vs_sdkver):gt("10.0.19041"), "package(cglm): need vs_sdkver > 10.0.19041.0")
            end
        end)
    end

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DCGLM_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
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
