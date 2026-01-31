package("octomap")
    set_homepage("https://octomap.github.io/")
    set_description("An Efficient Probabilistic 3D Mapping Framework Based on Octrees")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/OctoMap/octomap/archive/refs/tags/$(version).tar.gz",
             "https://github.com/OctoMap/octomap.git")

    add_versions("v1.10.0", "8da2576ec6a0993e8900db7f91083be8682d8397a7be0752c85d1b7dd1b8e992")
    add_versions("v1.9.7", "3e9ac020686ceb4e17e161bffc5a0dafd9cccab33adeb9adee59a61c418ea1c1")
    add_versions("v1.9.8", "417af6da4e855e9a83b93458aa98b01a2c88f880088baad2b59d323ce162586e")

    add_patches("1.10.0", path.join(os.scriptdir(), "patches", "1.10.0", "cmake.patch"), "5ad89543331054698ee9ca409e4b6745c7f5a386adb957398686a2dc14092477")
    add_patches("1.9.x", path.join(os.scriptdir(), "patches", "1.9.7", "build.patch"), "396b7b28c754f876c8552da93abf463f31bd65e327f454e75b8a5c10bb62ded4")

    add_configs("octovis", {description = "Build octovis", default = false, type = "boolean", readonly = true})
    add_configs("dynamicedt3d", {description = "Build dynamicEDT3D", default = false, type = "boolean"})

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_links("octomap", "octomath")

    add_deps("cmake")

    on_install("windows", "macosx", "linux", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_OCTOVIS_SUBPROJECT=" .. (package:config("octovis") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_DYNAMICETD3D_SUBPROJECT=" .. (package:config("dynamicedt3d") and "ON" or "OFF"))

        if package:is_plat("windows") and package:version():eq("1.10.0") then
            io.replace("octomap/src/compare_octrees.cpp",
            "#ifdef _MSC_VER // fix missing isnan for VC++",
            "#if defined(_MSVC_LANG) && _MSVC_LANG < 201103L", {plain = true})
        end
        import("package.tools.cmake").install(package, configs)

        if is_host("windows") then
            package:addenv("PATH", "bin")
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                octomap::OcTree tree(0.1);
                octomap::point3d endpoint(0.05f, 0.05f, 0.05f);
                tree.updateNode(endpoint, true);
            }
        ]]}, {configs = {languages = "c++11"}, includes = "octomap/octomap.h"}))
    end)
