package("box3d")
    set_homepage("https://github.com/erincatto/box3d")
    set_description("Box3D is a 3D physics engine for games")
    set_license("MIT")

    add_urls(
        "https://github.com/erincatto/box3d/archive/refs/tags/$(version).tar.gz",
        "https://github.com/erincatto/box3d.git"
    )

    add_versions("v0.1.0", "df232c7618c0d0d3927b798044559ee56eabadeb9d8ff9dc526d4b384d7b415d")

    add_patches("v0.1.0", path.join(os.scriptdir(), "patches/fix-msvc.patch"), "a1f376ab4bb154e6ae78236dce1ef0af58ba3d93dda2ff73ab9a23440081f147")

    add_deps("cmake")

    add_configs("simd", { description = "Enable SIMD math (slower)", default = false, type = "boolean" })
    add_configs("double_precision", { description = "Enable double precision for large worlds", default = false, type = "boolean" })

    if is_plat("linux", "bsd") then
        add_syslinks("pthread", "m")
    end

    on_install(function(package)
        local configs = {
            "-DBOX3D_SAMPLES=OFF",
            "-DBOX3D_UNIT_TESTS=OFF",
            "-DBOX3D_BENCHMARKS=OFF",
            "-DBOX3D_DOCS=OFF"
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBOX3D_DISABLE_SIMD=" .. (package:config("simd") and "OFF" or "ON"))
        table.insert(configs, "-DBOX3D_DOUBLE_PRECISION=" .. (package:config("double_precision") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function(package)
        assert(package:check_csnippets({ test = [[
            void test(int argc, char** argv) {
                b3WorldDef worldDef = b3DefaultWorldDef();
                b3WorldId worldId = b3CreateWorld(&worldDef);
                b3BodyDef groundBodyDef = b3DefaultBodyDef();
                groundBodyDef.position = (b3Vec3){ 0.0f, -10.0f, 0.0f };
                b3BodyId groundId = b3CreateBody(worldId, &groundBodyDef);
                b3BoxHull groundBox = b3MakeBoxHull(50.0f, 10.0f, 50.0f);
                b3ShapeDef groundShapeDef = b3DefaultShapeDef();
                b3CreateHullShape(groundId, &groundShapeDef, &groundBox.base);
                b3BodyDef bodyDef = b3DefaultBodyDef();
                bodyDef.type = b3_dynamicBody;
                bodyDef.position = (b3Vec3){ 0.0f, 4.0f, 0.0f };
                b3BodyId bodyId = b3CreateBody(worldId, &bodyDef);
                b3BoxHull dynamicBox = b3MakeCubeHull(1.0f);
                b3ShapeDef shapeDef = b3DefaultShapeDef();
                shapeDef.density = 1.0f;
                shapeDef.baseMaterial.friction = 0.3f;
                b3CreateHullShape(bodyId, &shapeDef, &dynamicBox.base);
                b3World_Step(worldId, 1.0f / 60.0f, 4);
                b3Vec3 position = b3Body_GetPosition(bodyId);
                b3Quat rotation = b3Body_GetRotation(bodyId);
                b3DestroyWorld(worldId);
            }
        ]]}, {configs = {languages = "c17"}, includes = "box3d/box3d.h" }))
    end)
