package("box3d")
    set_homepage("https://github.com/erincatto/box3d")
    set_description("Box3D is a 3D physics engine for games")
    set_license("MIT")

    add_urls(
        "https://github.com/erincatto/box3d/archive/refs/tags/$(version).tar.gz",
        "https://github.com/erincatto/box3d.git"
    )

    add_versions("v0.1.0", "df232c7618c0d0d3927b798044559ee56eabadeb9d8ff9dc526d4b384d7b415d")

    add_patches("v0.1.0", "patches/fix-msvc.patch", "a1f376ab4bb154e6ae78236dce1ef0af58ba3d93dda2ff73ab9a23440081f147")

    add_deps("cmake")

    add_configs("simd", { description = "Enable SIMD math (faster, but not supported on every platform)", default = false, type = "boolean" })
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
                b3DestroyWorld(worldId);
            }
        ]]}, {configs = {languages = "c17"}, includes = "box3d/box3d.h" }))
    end)
