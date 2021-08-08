package("entt")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/skypjack/entt")
    set_description("Gaming meets modern C++ - a fast and reliable entity component system (ECS) and much more.")

    set_urls("https://github.com/skypjack/entt/archive/$(version).tar.gz",
             "https://github.com/skypjack/entt.git")
    add_versions("v3.8.1", "a2b767f06bca67a73a4d71fb9ebb6ed823bb5146faad3c282b9dbbbdae1aa01b")
    add_versions("v3.7.1", "fe3ce773c17797c0c57ffa97f73902854fcc8e7afc7e09bea373e0c64fa24a23")
    add_versions("v3.7.0", "39ad5c42acf3434f8c37e0baa18a8cb562c0845383a6b4da17fdbacc9f0a7695")
    add_versions("v3.6.0", "94b7dc874acd0961cfc28cf6b0342eeb0b7c58250ddde8bdc6c101e84b74c190")

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DENTT_BUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <entt/entt.hpp>
            void test() {
                entt::registry r;
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
