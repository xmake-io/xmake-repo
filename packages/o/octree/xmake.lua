package("octree")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/attcs/Octree")
    set_description("Octree/Quadtree/N-dimensional linear tree")
    set_license("MIT")

    set_urls("https://github.com/attcs/Octree/archive/refs/tags/$(version).tar.gz",
             "https://github.com/attcs/Octree.git", {submodules = false})

    add_versions("v3.2.4", "eaec0b3c1f95e6aff2cb74635c59e676f6201678d9345477e79b23e375ed7b77")
    add_versions("v2.5", "86088cd000254aeddf4f9d75c0600b7f799e062340394124d69760829ed317fe")

    add_patches(">=3.2.4", "patches/v3.2.4/fix-cereal-bridge.patch", "b320138eddba9cd598c38187409a9470f693f5b1b6a863222079f6239a0de233")

    on_check(function (package)
        if not package:is_arch("x64", "x86", "x86_64") then
            raise("package(octree) only support x86 arch")
        end

        local msvc = package:toolchain("msvc")
        if package:is_arch("x64") and msvc then
            local vs_toolset = msvc:config("vs_toolset")
            if vs_toolset then
                local vs_toolset_ver = import("core.base.semver").new(vs_toolset)
                local minor = vs_toolset_ver:minor()
                assert(minor and minor >= 30, "package(octree) require vs_toolset >= 14.3")
            end
        end
    end)

    on_install(function (package)
        if package:version():ge("3.0.0") then
            os.cp("include/orthotree", package:installdir("include"))
        else
            os.cp("*.h", package:installdir("include"))
        end
    end)

    on_test(function (package)
        local include = "octree.h"
        local octree_type = "OctreePointC"
        if package:version():ge("3.0.0") then
            include = "orthotree/octree.h"
            octree_type = "OctreePointM"
        end
        assert(package:check_cxxsnippets({test = ([[
            using namespace OrthoTree;
            void test() {
                auto constexpr points = std::array{ Point3D{0,0,0}, Point3D{1,1,1}, Point3D{2,2,2} };
                auto const octree = %s(points, 3 /*max depth*/);

                auto const searchBox = BoundingBox3D{ {0.5, 0.5, 0.5}, {2.5, 2.5, 2.5} };
                auto const pointIDs = octree.RangeSearch(searchBox); //: { 1, 2 }

                auto neighborNo = 2;
                auto pointIDsByKNN = octree.GetNearestNeighbors(Point3D{ 1.1, 1.1, 1.1 }
                    , neighborNo
                ); //: { 1, 2 }
            }
        ]]):format(octree_type)}, {configs = {languages = "c++20"}, includes = include}))
    end)
