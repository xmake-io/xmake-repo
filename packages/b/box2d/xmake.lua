package("box2d")
    set_homepage("https://box2d.org")
    set_description("A 2D Physics Engine for Games")
    set_license("MIT")

    set_urls("https://github.com/erincatto/box2d/archive/refs/tags/$(version).tar.gz",
             "https://github.com/erincatto/box2d.git")

    add_versions("v3.0.0", "64ad759006cd2377c99367f51fb36942b57f0e9ad690ed41548dd620e6f6c8b1")
    add_versions("v2.4.2", "85b9b104d256c985e6e244b4227d447897fac429071cc114e5cc819dae848852")

    add_configs("avx2", {description = "Enable AVX2.", default = false, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")

    if on_check then
        on_check(function (package)
            if package:gitref() or package:version():ge("3.0.0") then
                if package:check_sizeof("void*") == "4" then
                    raise("package(box2d >=3.0.0) unsupported 32-bit")
                end

                if package:is_plat("windows") then
                    assert(not package:is_arch("arm64.*"), "package(box2d/arm >=3.0.0) Unsupported architecture.")
                end

                if package:is_plat("android") then
                    local ndk = package:toolchain("ndk")
                    local ndk_sdkver = ndk:config("ndk_sdkver")
                    assert(ndk_sdkver and tonumber(ndk_sdkver) >= 28, "package(box2d >=3.0.0) requires ndk api level >= 28")
                end

                local configs = {languages = "c11"}
                if package:has_tool("cc", "cl") then
                    configs.cflags = "/experimental:c11atomics"
                end
                assert(package:has_cincludes("stdatomic.h", {configs = configs}),
                "package(box2d >=3.0.0) Requires at least C11 and stdatomic.h")
            end
        end)
    end

    on_install("!bsd", function (package)
        if package:config("shared") then
            package:add("defines", "B2_SHARED")
        end
        if package:is_plat("windows") and package:is_debug() then
            package:add("defines", "B2_ENABLE_ASSERT")
        end

        io.replace("CMakeLists.txt", [[set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")]], "", {plain = true})

        local configs = {
            "-DBOX2D_BUILD_UNIT_TESTS=OFF",
            "-DBOX2D_BUILD_TESTBED=OFF",

            "-DBOX2D_SAMPLES=OFF",
            "-DBOX2D_UNIT_TESTS=OFF",
            "-DBOX2D_VALIDATE=OFF",
            "--compile-no-warning-as-error",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBOX2D_SANITIZE=" .. (package:config("asan") and "ON" or "OFF"))
        table.insert(configs, "-DBOX2D_AVX2=" .. (package:config("avx2") and "ON" or "OFF"))

        os.mkdir(path.join(package:buildir(), "src/pdb"))
        import("package.tools.cmake").install(package, configs)

        if package:gitref() or package:version():ge("3.0.0") then
            os.cp("include", package:installdir())
        end
        if package:config("shared") then
            os.trycp(path.join(package:buildir(), "bin/box2d.pdb"), package:installdir("bin"))
        else
            os.trycp(path.join(package:buildir(), "bin/box2d.pdb"), package:installdir("lib"))
        end
    end)

    on_test(function (package)
        if package:gitref() or package:version():ge("3.0.0") then
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
