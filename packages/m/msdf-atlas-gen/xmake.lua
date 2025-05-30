package("msdf-atlas-gen")
    set_homepage("https://github.com/Chlumsky/msdf-atlas-gen")
    set_description("Multi-channel signed distance field atlas generator")
    set_license("MIT")

    add_urls("https://github.com/Chlumsky/msdf-atlas-gen/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Chlumsky/msdf-atlas-gen.git")

    add_versions("v1.3", "5d3d58e8bc92836baf23ce3a80ef79cc4c2d022fb86b7f160b11cc06cd62fe78")

    add_configs("skia", {description = "Build with the Skia library", default = false, type = "boolean"})
    add_configs("standalone", {description = "Build standalone executable", default = false, type = "boolean"})

    add_deps("cmake")
    add_deps("zlib")
    add_deps("msdfgen", {configs = {extensions = true}})

    on_load(function (package)
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "MSDF_ATLAS_PUBLIC=__declspec(dllimport)")
        else
            package:add("defines", "MSDF_ATLAS_PUBLIC=")
        end
    end)

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DMSDF_ATLAS_USE_VCPKG=OFF")
        table.insert(configs, "-DMSDF_ATLAS_INSTALL=ON")
        table.insert(configs, "-DMSDF_ATLAS_DYNAMIC_RUNTIME=OFF")
        table.insert(configs, "-DMSDF_ATLAS_MSDFGEN_EXTERNAL=ON")
        table.insert(configs, "-DMSDF_ATLAS_NO_ARTERY_FONT=ON")
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DMSDF_ATLAS_BUILD_STANDALONE=" .. (package:config("standalone") and "ON" or "OFF"))
        table.insert(configs, "-DMSDF_ATLAS_USE_SKIA=" .. (package:config("skia") and "ON" or "OFF"))

        if package:is_plat("windows") then
            io.replace("CMakeLists.txt", [[set(MSDF_ATLAS_MSVC_RUNTIME "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")]], "", {plain = true})
            io.replace("CMakeLists.txt", [[set(MSDF_ATLAS_MSVC_RUNTIME "MultiThreaded$<$<CONFIG:Debug>:Debug>")]], "", {plain = true})
        end
        
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <msdf-atlas-gen/msdf-atlas-gen.h>

            static void test() {
                msdf_atlas::TightAtlasPacker packer;
            }
        ]]}, {configs = {languages = "c++11"}}))

        if package:config("standalone") and (not package:is_cross()) then
            os.vrun("msdf-atlas-gen -help")
        end
    end)
