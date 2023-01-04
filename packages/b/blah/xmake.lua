package("blah")
    set_homepage("https://github.com/NoelFB/blah")
    set_description("A small 2d c++ game framework")
    set_license("MIT")

    add_urls("https://github.com/NoelFB/blah.git")
    add_versions("2023.01.03", "a0cccca457cfb91213fae6e4e994d1c181c358fe")

    add_deps("cmake")
    add_deps("libsdl >=2.26")

    if is_plat("macosx") then
        add_frameworks("ForceFeedback", "CoreVideo", "CoreGraphics", "CoreFoundation", "Foundation", "AppKit", "IOKit")
    elseif is_plat("windows") then
        add_syslinks("d3d11", "d3dcompiler", "dxguid")
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    on_install("windows", "macosx", "linux", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        io.replace("CMakeLists.txt", "if (NOT DEFINED BLAH_SDL2_LIBS)", "IF(FALSE)", {plain = true})
        import("package.tools.cmake").build(package, configs, {buildir = "build", packagedeps = "libsdl"})
        os.cp("include", package:installdir())
        os.trycp("build/*.a", package:installdir("lib"))
        os.trycp("build/*.so", package:installdir("lib"))
        os.trycp("build/*.dylib", package:installdir("lib"))
        os.trycp("build/*/*.lib", package:installdir("lib"))
        os.trycp("build/*/*.dll", package:installdir("bin"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            using namespace Blah;
            Batch batch;
            int test() {
                Config config;
                config.name = "blah app";
                config.on_render = []() {
                    auto target = App::backbuffer();
                    target->clear(Color::black);

                    auto center = Vec2f(target->width(), target->height()) / 2;
                    auto rotation = Time::seconds * Calc::TAU;
                    auto transform = Mat3x2f::create_transform(center, Vec2f::zero, Vec2f::one, rotation);

                    batch.push_matrix(transform);
                    batch.rect(Rectf(-32, -32, 64, 64), Color::red);
                    batch.pop_matrix();

                    batch.render(target);
                    batch.clear();
                };

                return App::run(&config);
            }
        ]]}, {configs = {languages = "c++17"}, includes = {"blah.h"}}))
    end)
