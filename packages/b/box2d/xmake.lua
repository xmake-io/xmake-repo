package("box2d")

    set_homepage("https://box2d.org")
    set_description("A 2D Physics Engine for Games")

    set_urls("https://github.com/erincatto/box2d/archive/v$(version).zip")
    add_versions("2.4.0", "6aebbc54c93e367c97e382a57ba12546731dcde51526964c2ab97dec2050f8b9")

    add_deps("cmake")

    on_install("windows", "linux", "macosx", "mingw", function (package)
        local configs = {}
        table.insert(configs, "-DBOX2D_BUILD_UNIT_TESTS=OFF")
        table.insert(configs, "-DBOX2D_BUILD_TESTBED=OFF")
        table.insert(configs, "-DBOX2D_BUILD_DOCS=OFF")
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        import("package.tools.cmake").build(package, configs, {buildir = "build"})
        if package:is_plat("windows") then
            os.trycp(path.join("build", "src", "*", "*.lib"), package:installdir("lib"))
        else
            os.trycp("build/src/*.a", package:installdir("lib"))
        end
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test(int argc, char** argv) {
                b2World world(b2Vec2(0.0f, -10.0f));
            }
        ]]}, {configss = {languages = "c++11"}, includes = "box2d/box2d.h"}))
    end)
