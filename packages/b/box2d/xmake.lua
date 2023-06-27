package("box2d")

    set_homepage("https://box2d.org")
    set_description("A 2D Physics Engine for Games")

    set_urls("https://github.com/erincatto/box2d/archive/v$(version).zip")
    add_versions("2.4.0", "6aebbc54c93e367c97e382a57ba12546731dcde51526964c2ab97dec2050f8b9")
    add_versions("2.4.1", "0cb512dfa5be79ca227cd881b279adee61249c85c8b51caf5aa036b71e943002")

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
            os.trycp(path.join("build", "bin", "*", "*.lib"), package:installdir("lib"))
        else
            os.trycp("build/src/*.a", package:installdir("lib"))
            os.trycp("build/bin/*.a", package:installdir("lib"))
        end
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test(int argc, char** argv) {
                b2World world(b2Vec2(0.0f, -10.0f));
                b2BodyDef bodyDef;
                bodyDef.type = b2_dynamicBody;
                bodyDef.position.Set(0.0f, 4.0f);
                b2Body* body = world.CreateBody(&bodyDef);
                b2PolygonShape dynamicBox;
                dynamicBox.SetAsBox(1.0f, 1.0f);
                b2FixtureDef fixtureDef;
                fixtureDef.shape = &dynamicBox;
                fixtureDef.density = 1.0f;
                fixtureDef.friction = 0.3f;
                body->CreateFixture(&fixtureDef);
                float timeStep = 1.0f / 60.0f;
                int32 velocityIterations = 6;
                int32 positionIterations = 2;
                for (int32 i = 0; i < 60; ++i)
                {
                    world.Step(timeStep, velocityIterations, positionIterations);
                    b2Vec2 position = body->GetPosition();
                    float angle = body->GetAngle();
                }
            }
        ]]}, {configs = {languages = "c++11"}, includes = "box2d/box2d.h"}))
    end)
