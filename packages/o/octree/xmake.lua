package("octree")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/attcs/Octree")
    set_description("Octree/Quadtree/N-dimensional linear tree")
    set_license("MIT")

    set_urls("https://github.com/attcs/Octree/archive/refs/tags/$(version).tar.gz",
             "https://github.com/attcs/Octree.git", {submodules = false})

    add_versions("v2.5", "86088cd000254aeddf4f9d75c0600b7f799e062340394124d69760829ed317fe")

    on_check(function (package)
        if not package:is_arch("x64", "x86", "x86_64") then
            raise("package(octree) only support x86 arch")
        end
    end)

    on_install(function (package)
        os.cp("*.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cxxincludes("octree.h", {configs = {languages = "c++20"}}))
    end)
