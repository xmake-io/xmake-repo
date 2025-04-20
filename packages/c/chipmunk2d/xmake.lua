package("chipmunk2d")
    set_homepage("https://chipmunk-physics.net/")
    set_description("A fast and lightweight 2D game physics library.")
    set_license("MIT")

    add_urls("https://github.com/slembcke/Chipmunk2D/archive/Chipmunk-$(version).tar.gz", {alias = "archive"})
    add_urls("https://github.com/slembcke/Chipmunk2D.git", {alias = "github"})

    add_versions("archive:7.0.3", "1e6f093812d6130e45bdf4cb80280cb3c93d1e1833d8cf989d554d7963b7899a")
    add_versions("github:7.0.3", "87340c216bf97554dc552371bbdecf283f7c540e")
    add_patches("7.0.3", path.join(os.scriptdir(), "patches", "7.0.3", "android.patch"), "d0bbefe66852cdadb974dce24d4383c356bc3fa88656739ff1d5baf4e3792a96")

    add_configs("precision", {description = "Which precision to use (defaults is double on most platforms except ARM 32bits)", default = "default", type = "string", values = {"default", "single", "double"}})

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::chipmunk")
    elseif is_plat("linux") then
        add_extsources("pacman::chipmunk", "apt::libchipmunk-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::chipmunk")
    end

    add_deps("cmake")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread", "m")
    elseif is_plat("android") then
        add_syslinks("log", "m")
    end

    on_load(function (package)
        if package:config("precision") == "double" then
            package:add("defines", "CP_USE_DOUBLES=1")
            if package:is_plat("macosx", "iphoneos") then
                package:add("defines", "CP_USE_CGTYPES=1")
            end
        elseif package:config("precision") == "single" then
            package:add("defines", "CP_USE_DOUBLES=0")
            if package:is_plat("macosx", "iphoneos") then
                package:add("defines", "CP_USE_CGTYPES=0")
            end
        end
    end)

    on_install("windows", "linux", "macosx", "iphoneos", "mingw", "android", "wasm", "bsd",function (package)
        local configs = {"-DBUILD_DEMOS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        if package:config("shared") then
            table.insert(configs, "-DBUILD_SHARED=ON")
            table.insert(configs, "-DBUILD_STATIC=OFF")
            table.insert(configs, "-DINSTALL_STATIC=OFF")
        else
            table.insert(configs, "-DBUILD_SHARED=OFF")
            table.insert(configs, "-DBUILD_STATIC=ON")
            table.insert(configs, "-DINSTALL_STATIC=ON")
        end
        local opt = {}
        if package:config("precision") == "double" then
            opt.cxflags = {"-DCP_USE_DOUBLES=1"}
            if package:is_plat("macosx", "iphoneos") then
                table.insert(opt.cxflags, "-DCP_USE_CGTYPES=1")
            end
        elseif package:config("precision") == "single" then
            opt.cxflags = {"-DCP_USE_DOUBLES=0"}
            if package:is_plat("macosx", "iphoneos") then
                table.insert(opt.cxflags, "-DCP_USE_CGTYPES=0")
            end
        end
        import("package.tools.cmake").install(package, configs, opt)
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
