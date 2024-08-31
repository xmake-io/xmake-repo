package("box2d")

    set_homepage("https://box2d.org")
    set_description("A 2D Physics Engine for Games")
    set_license("MIT")

    set_urls("https://github.com/erincatto/box2d/archive/v$(version).zip")
    add_versions("2.4.0", "6aebbc54c93e367c97e382a57ba12546731dcde51526964c2ab97dec2050f8b9")
    add_versions("2.4.1", "0cb512dfa5be79ca227cd881b279adee61249c85c8b51caf5aa036b71e943002")
    add_versions("2.4.2", "593f165015fdd07ea521a851105f1c86ae313c5af0a15968ed95f864417fa8a7")
    if is_arch("x64", "x86_64", "arm64.*") then
        add_versions("3.0.0", "c2983a30a95037c46c19e42f398de6bc375d6ae87f30e0d0bbabb059ec60f8c0")
    end

    if is_arch("x64", "x86_64") then
        add_configs("avx2", {description = "Enable AVX2.", default = false, type = "boolean"})
    end

    add_deps("cmake")

    if on_check then
        on_check("windows", function (package)
            if package:version():ge("3.0.0") then
                assert(not package:is_arch("arm64.*"), "package(box2d =>3.0.0) Unsupported architecture.")

                local configs = {languages = "c11"}
                if package:has_tool("cc", "cl") then
                    configs.cflags = "/experimental:c11atomics"
                end
                assert(package:has_cincludes("stdatomic.h", {configs = configs}),
                "package(box2d >=3.0.0) Requires at least C11 and stdatomic.h")
            end
        end)
    end

    on_install("windows", "linux", "macosx", "mingw", function (package)
        local configs = {}
        if package:version():ge("3.0.0") then
            table.insert(configs, "--compile-no-warning-as-error")
            table.insert(configs, "-DBOX2D_SANITIZE=OFF")
            table.insert(configs, "-DBOX2D_SAMPLES=OFF")
            table.insert(configs, "-DBOX2D_BENCHMARKS=OFF")
            table.insert(configs, "-DBOX2D_DOCS=OFF")
            table.insert(configs, "-DBOX2D_PROFILE=OFF")
            table.insert(configs, "-DBOX2D_VALIDATE=OFF")
            table.insert(configs, "-DBOX2D_UNIT_TESTS=OFF")
            table.insert(configs, "-DBOX2D_AVX2=" .. (package:config("avx2") and "ON" or "OFF"))
        else
            table.insert(configs, "-DBOX2D_BUILD_UNIT_TESTS=OFF")
            table.insert(configs, "-DBOX2D_BUILD_TESTBED=OFF")
            table.insert(configs, "-DBOX2D_BUILD_DOCS=OFF")
        end
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
        if package:version():ge("3.0.0") then
            assert(package:check_csnippets({test = [[
                void test(int argc, char** argv) {
                    b2WorldDef worldDef = b2DefaultWorldDef();
                    b2WorldId worldId = b2CreateWorld(&worldDef);
                    b2BodyDef bodyDef = b2DefaultBodyDef();
                    b2BodyId bodyId = b2CreateBody(worldId, &bodyDef);
                    b2Polygon box = b2MakeBox(1.0f, 1.0f);
                    b2ShapeDef shapeDef = b2DefaultShapeDef();
                    b2CreatePolygonShape(bodyId, &shapeDef, &box);
                    float timeStep = 1.0f / 60.0f;
                    int subStepCount = 4;
                    b2World_Step(worldId, timeStep, subStepCount);
                    b2Vec2 position = b2Body_GetPosition(bodyId);
                    b2Rot rotation = b2Body_GetRotation(bodyId);
                    b2DestroyWorld(worldId);
                }
            ]]}, {configs = {languages = "c11"}, includes = "box2d/box2d.h"}))
        else
            assert(package:check_cxxsnippets({test = [[
                void test(int argc, char** argv) {
                    b2World world(b2Vec2(0.0f, -10.0f));
                    b2BodyDef bodyDef;
                    b2Body* body = world.CreateBody(&bodyDef);
                    b2PolygonShape box;
                    box.SetAsBox(1.0f, 1.0f);
                    b2FixtureDef fixtureDef;
                    fixtureDef.shape = &box;
                    body->CreateFixture(&fixtureDef);
                    float timeStep = 1.0f / 60.0f;
                    int32 velocityIterations = 6;
                    int32 positionIterations = 2;
                    world.Step(timeStep, velocityIterations, positionIterations);
                    b2Vec2 position = body->GetPosition();
                    float angle = body->GetAngle();
                }
            ]]}, {configs = {languages = "c++11"}, includes = "box2d/box2d.h"}))
        end
    end)
