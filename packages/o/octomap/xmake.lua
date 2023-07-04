package("octomap")

    set_homepage("https://octomap.github.io/")
    set_description("An Efficient Probabilistic 3D Mapping Framework Based on Octrees")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/OctoMap/octomap/archive/refs/tags/$(version).tar.gz",
             "https://github.com/OctoMap/octomap.git")
    add_versions("v1.9.7", "3e9ac020686ceb4e17e161bffc5a0dafd9cccab33adeb9adee59a61c418ea1c1")
    add_versions("v1.9.8", "417af6da4e855e9a83b93458aa98b01a2c88f880088baad2b59d323ce162586e")

    add_patches("1.9.x", path.join(os.scriptdir(), "patches", "1.9.7", "build.patch"), "396b7b28c754f876c8552da93abf463f31bd65e327f454e75b8a5c10bb62ded4")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")
    on_install("windows", "macosx", "linux", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
        package:addenv("PATH", "bin")
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
