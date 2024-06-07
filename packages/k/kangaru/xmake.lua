package("kangaru")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/gracicot/kangaru")
    set_description("🦘 A dependency injection container for C++11, C++14 and later")
    set_license("MIT")

    add_urls("https://github.com/gracicot/kangaru/archive/refs/tags/$(version).tar.gz",
             "https://github.com/gracicot/kangaru.git")

    add_versions("v4.3.2", "ed2dec53087fe4c5fbfc7f7ffcb0e963b3e0a7f27699338c4bc5a116193113b8")
    add_versions("v4.3.1", "3896ea2a13cc1c220b4d83bf598e27e77004170b4a212af8f14264f8a6fb0e45")

    add_deps("cmake")

    on_install(function (package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <kangaru/kangaru.hpp>
            struct Camera {};
            struct Scene {
                Camera& camera;
            };
            struct CameraService : kgr::single_service<Camera> {};
            struct SceneService : kgr::service<Scene, kgr::dependency<CameraService>> {};
            void test() {
                kgr::container container;
                Scene scene = container.service<SceneService>();
                Camera& camera = container.service<CameraService>();
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
