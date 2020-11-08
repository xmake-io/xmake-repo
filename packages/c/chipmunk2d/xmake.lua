package("chipmunk2d")

    set_homepage("https://chipmunk-physics.net/")
    set_description(" A fast and lightweight 2D game physics library.")

    set_urls("https://github.com/slembcke/Chipmunk2D/archive/Chipmunk-$(version).tar.gz",
             "https://github.com/slembcke/Chipmunk2D.git")

    add_versions("7.0.3", "1e6f093812d6130e45bdf4cb80280cb3c93d1e1833d8cf989d554d7963b7899a")
    add_patches("7.0.3", path.join(os.scriptdir(), "patches", "7.0.3", "android.patch"), "8ef7789559f3153f9851022a4c54bbd9864a0554b6edaa8e34f761a5064f395a")

    add_deps("cmake")

    if is_plat("linux") then
        add_syslinks("pthread", "m")
    end

    on_install("windows", "linux", "macosx", "iphoneos", "mingw", "android", function (package)
        local configs = {"-DBUILD_DEMOS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        if package:config("shared") then
            table.insert(configs, "-DBUILD_SHARED=ON")
            table.insert(configs, "-DBUILD_STATIC=OFF")
            table.insert(configs, "-DINSTALL_STATIC=OFF")
        else
            table.insert(configs, "-DBUILD_SHARED=OFF")
            table.insert(configs, "-DBUILD_STATIC=ON")
        end
        import("package.tools.cmake").install(package, configs)
        os.vcp("include/chipmunk", package:installdir("include"))
   end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                cpSpace* space = cpSpaceNew();
                cpSpaceFree(space);
            }
        ]]}, {includes = {"chipmunk/chipmunk.h"}}))
    end)
