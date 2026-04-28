package("ogre-next")

    set_homepage("https://www.ogre3d.org/")
    set_description("scene-oriented, flexible 3D engine written in C++")
    set_license("MIT")

    add_urls("https://github.com/OGRECave/ogre-next/archive/refs/tags/$(version).tar.gz",
             "https://github.com/OGRECave/ogre-next.git")
    add_versions("v3.0.0", "7818085243018178730bdbe85a84d358e49b3b19e3ff65e02d33b008e778210d")
    add_versions("v2.2.5", "b3b555386aa7ebf164a41451ad896bb3774521410944568ecec58f780d0725c4")

    add_patches("v2.2.5", path.join(os.scriptdir(), "patches", "2.2.5", "macosx.patch"), "a20f32d8847dd4c93fe2b824d2b793862b8e3126ae7fda4450ad22e76bb00c32")

    add_deps("cmake", "zziplib", "freetype", "zlib", "assimp")
    add_deps("boost", {configs = {thread = true, date_time = true}})
    if is_plat("linux") then
        add_deps("libx11", "libxt", "libxaw", "libxrandr", "libsm", "libice", "xtrans")
        add_syslinks("pthread")
    end
    add_includedirs("include/OGRE")
    on_load("windows", function (package)
        if not package:config("shared") then
            package:add("defines", "OGRE_STATIC_LIB")
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        io.replace("Components/Hlms/Pbs/src/IrradianceField/OgreIrradianceField.cpp", "2ᵃ * 2ᵇ = 2ⁿ", "", {plain = true})
        local configs = {"-DOGRE_BUILD_SAMPLES2=OFF", "-DOGRE_BUILD_TESTS=OFF", "-DCMAKE_CXX_STANDARD=17"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DOGRE_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        if package:is_plat("macosx") then
            table.insert(configs, "-DOGRE_BUILD_RENDERSYSTEM_GL3PLUS=OFF")
        end
        if package:is_plat("linux") then
            import("package.tools.cmake").install(package, configs, {packagedeps = {"libx11", "libxt", "libxaw", "libxrandr", "libsm", "libice", "xtrans"}})
        else
            import("package.tools.cmake").install(package, configs)
        end
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("Ogre::Root", {configs = {languages = "c++17"}, includes = "OgreRoot.h"}))
    end)
