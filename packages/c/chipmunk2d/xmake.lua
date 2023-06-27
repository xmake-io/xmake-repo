package("chipmunk2d")

    set_homepage("https://chipmunk-physics.net/")
    set_description("A fast and lightweight 2D game physics library.")
    set_license("MIT")

    add_urls("https://github.com/slembcke/Chipmunk2D/archive/Chipmunk-$(version).tar.gz", {alias = "archive"})
    add_urls("https://github.com/slembcke/Chipmunk2D.git", {alias = "github"})

    add_versions("archive:7.0.3", "1e6f093812d6130e45bdf4cb80280cb3c93d1e1833d8cf989d554d7963b7899a")
    add_versions("github:7.0.3", "87340c216bf97554dc552371bbdecf283f7c540e")
    add_patches("7.0.3", path.join(os.scriptdir(), "patches", "7.0.3", "android.patch"), "08e80020880e9bf3c61b48d41537d953e7bf6a63797eb8bcd6b78ba038b79d8f")

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::chipmunk")
    elseif is_plat("linux") then
        add_extsources("pacman::chipmunk", "apt::libchipmunk-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::chipmunk")
    end

    add_deps("cmake")

    if is_plat("linux") then
        add_syslinks("pthread", "m")
    end

    on_install("windows", "linux", "macosx", "iphoneos", "mingw", "android", "wasm", function (package)
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
