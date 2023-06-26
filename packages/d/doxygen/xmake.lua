package("doxygen")
    set_kind("binary")
    set_homepage("https://www.doxygen.nl/")
    set_license("GPL-2.0")

    add_urls("https://doxygen.nl/files/doxygen-$(version).src.tar.gz", {alias = "archive"})
    add_urls("https://github.com/doxygen/doxygen/releases/download/Release_$(version).src.tar.gz", {
        alias = "archive",
        version = function (version) return format("%s/doxygen-%s", version:gsub("%.", "_"), version) end
    })
    add_urls("https://github.com/doxygen/doxygen.git", {alias = "github"})

    add_versions("archive:1.9.6", "297f8ba484265ed3ebd3ff3fe7734eb349a77e4f95c8be52ed9977f51dea49df")
    add_versions("archive:1.9.5", "55b454b35d998229a96f3d5485d57a0a517ce2b78d025efb79d57b5a2e4b2eec")
    add_versions("archive:1.9.3", "f352dbc3221af7012b7b00935f2dfdc9fb67a97d43287d2f6c81c50449d254e0")
    add_versions("github:1.9.6", "Release_1_9_6")
    add_versions("github:1.9.5", "Release_1_9_5")
    add_versions("github:1.9.3", "Release_1_9_3")
    add_versions("github:1.9.2", "Release_1_9_2")
    add_versions("github:1.9.1", "Release_1_9_1")

    if not is_plat("windows") then
        add_deps("cmake", "bison >=2.7", "flex", {private = true})
        add_deps("python 3.x", {kind = "binary", private = true})
    end

    on_load("@windows", function (package)
        if package:is_built() then
            package:add("deps", "cmake", "bison >=2.7", "flex")
            package:add("deps", "python 3.x", {kind = "binary"})
        end
    end)

    on_install("@windows", "@macosx", "@linux", function (package)
        os.rm("templates/*/PaxHeader")
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        os.vrun("doxygen -v")
    end)
