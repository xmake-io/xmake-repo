package("magnum-plugins")

    set_homepage("https://magnum.graphics/")
    set_description("Plugins for magnum, C++11/C++14 graphics middleware for games and data visualization.")
    set_license("MIT")

    add_urls("https://github.com/mosra/magnum-plugins/archive/refs/tags/$(version).zip",
             "https://github.com/mosra/magnum-plugins.git")
    add_versions("v2020.06", "8e1e98674ef3f0276f68abbdfecef1d72ae95b5a812b78c1ff45dba10fc72e3f")

    add_configs("plugin_static", {description = "Build plugins as static libraries.", default = false, type = "boolean"})
    add_configs("openddl",       {description = "Build the OpenDdl library.", default = false, type = "boolean"})

    local plugins = {"assimpimporter", "basisimageconverter", "basisimporter", "ddsimporter", "devilimageimporter", "drflacaudioimporter", "drmp3audioimporter", "drwavimporter", "faad2audioimporter", "freetypefont", "glslangshaderconverter", "harfbuzzfont", "icoimporter", "jpegimageconverter", "jpegimporter", "meshoptimizersceneconverter", "miniexrimageconverter", "openexrimageconverter", "openexrimporter", "opengeximporter", "pngimageconverter", "pngimporter", "primitiveimporter", "spirvtoolsshaderconverter", "stanfordimporter", "stanfordsceneconverter", "stbdxtimageconverter", "stbimageconverter", "stbimageimporter", "stbtruetypefont", "stbvorbisaudioimporter", "tinygltfimporter"}
    for _, plugin in ipairs(plugins) do
        add_configs(plugin, {description = "Build the " .. plugin .. " plugin.", default = false, type = "boolean"})
    end

    add_deps("cmake", "magnum")
    on_load("windows", "linux", "macosx", function (package)
        local configdeps = {assimpimporter = "assimp",
                            devilimageimporter = "devil",
                            faad2audioimporter = "faad2",
                            freetypefont = "freetype",
                            glslangshaderconverter = "vulkansdk",
                            harfbuzzfont = "harfbuzz",
                            jpegimporter = "libjpeg-turbo",
                            openexrimageconverter = "openexr",
                            openexrimporter = "openexr",
                            pngimageconverter = "libpng",
                            pngimporter = "libpng",
                            spirvtoolsshaderconverter = "vulkansdk"}
        for config, dep in pairs(configdeps) do
            if package:config(config) then
                package:add("deps", dep)
            end
        end
    end)

    on_install("windows", "linux", "macosx", function (package)
        local configs = {"-DBUILD_TESTS=OFF", "-DLIB_SUFFIX="}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DBUILD_PLUGIN_STATIC=" .. (package:config("plugin_static") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_OPENDDL=" .. (package:config("openddl") and "ON" or "OFF"))
        for _, plugin in ipairs(plugins) do
            table.insert(configs, "-DWITH_" .. plugin:upper() .. "=" .. (package:config(plugin) and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                auto year = MAGNUMPLUGINS_VERSION_YEAR;
                auto month = MAGNUMPLUGINS_VERSION_MONTH;
            }
        ]]}, {configs = {languages = "c++14"}, includes = "Magnum/versionPlugins.h"}))
    end)
