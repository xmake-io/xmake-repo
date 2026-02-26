package("usd")
    set_homepage("http://www.openusd.org")
    set_description("Universal Scene Description")
    set_license("Apache-2.0")

    add_urls("https://github.com/PixarAnimationStudios/USD/archive/refs/tags/$(version).tar.gz",
             "https://github.com/PixarAnimationStudios/USD.git")

    add_versions("v25.11", "c37c633b5037a4552f61574670ecca8836229b78326bd62622f3422671188667")
    add_versions("v25.08", "2a93c2390ae35a3e312f3fb66e6f403a0e046893e3f0d706be82963345a08cb3")
    add_versions("v25.05.01", "f424e8db26e063a1b005423ee52142e75c38185bbd4b8126ef64173e906dd50f")
    add_versions("v25.05", "231faca9ab71fa63d6c1e0da18bda0c365f82d9bef1cfd4b3d3d6784c8d5fb96")
    add_versions("v24.08", "6640bb184bf602c6df14fa4a83af6ac5ae1ab8d1d38cf7bb7decfaa9a7ad5d06")
    add_versions("v24.05", "0352619895588efc8f9d4aa7004c92be4e4fa70e1ccce77e474ce23941c05828")
    add_versions("v24.03", "0724421cff8ae04d0a7108ffa7c104e6ec3f7295418d4d50caaae767e59795ef")
    add_versions("v23.02", "a8eefff722db0964ce5b11b90bcdc957f3569f1cf1d44c46026ecd229ce7535d")
    add_versions("v22.11", "f34826475bb9385a9e94e2fe272cc713f517b987cbea15ee6bbc6b21db19aaae")

    add_configs("shared", {description = "Build shared binaries.", default = true, type = "boolean", readonly = true})
    add_configs("monolithic", {description = "Build single shared library", default = false, type = "boolean"})

    add_configs("image", {description = "Build imaging components", default = false, type = "boolean"})
    add_configs("openimageio", {description = "Build OpenImageIO plugin", default = false, type = "boolean"})
    add_configs("opencolorio", {description = "Build OpenColorIO plugin", default = false, type = "boolean"})
    add_configs("materialx", {description = "Enable MaterialX support", default = false, type = "boolean"})

    add_configs("vulkan", {description = "Enable Vulkan based components", default = false, type = "boolean"})
    add_configs("python", {description = "Enable Python based components for USD", default = false, type = "boolean"})
    add_configs("usdview", {description = "Build usdview", default = false, type = "boolean"})
    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})

    add_deps("cmake")

    if is_plat("windows") then
        add_defines("NOMINMAX")
    end

    if on_check then
        on_check(function (package)
            if not package:is_plat("macosx") then
                assert(package:is_arch("x64", "x86_64"), "package(usd) only support x86")
            end
            if package:version() and package:version():ge("25.08") and
                package:is_plat("linux") and package:has_tool("cxx", "clang") then

                raise("package(usd >=v25.08) unsupported clang toolchain")
            end
        end)
    end

    on_load(function (package)
        if package:version() and package:version():ge("v25.05") then
            package:add("deps", "tbb")
        else
            -- usd only support tbb 2022 now https://github.com/PixarAnimationStudios/USD/issues/1471
            package:add("deps", "tbb 2020.3")
            package:add("deps", "boost")
        end

        if package:config("image") then
            package:add("deps", "opensubdiv", {configs = {glfw = false, ptex = false}})
            if package:config("vulkan") then
                package:add("deps", "vulkansdk")
            end
        end
        if package:config("openimageio") then
            -- TODO: fix openimageio deps when link
            package:add("deps", "openimageio", {configs = {shared = true}})
        end
        if package:config("opencolorio") then
            package:add("deps", "opencolorio")
        end
        if package:config("materialx") then
            package:add("deps", "materialx")
        end

        if package:config("python") then
            package:add("deps", "python >=3.9")
            package:addenv("PYTHONPATH", "lib/python")
            if package:config("usdview") then
                -- TODO: require pyside2/pyside6 for usdview
            end
        end
        if package:config("tools") then
            package:addenv("PATH", "bin")
        end
        package:addenv("PATH", "lib")
        package:mark_as_pathenv("PXR_PLUGINPATH_NAME")
        package:addenv("PXR_PLUGINPATH_NAME", "lib/usd")
    end)

    on_install("linux", "macosx", "windows", function (package)
        local configs = {
            "-DPXR_BUILD_TESTS=OFF",
            "-DPXR_BUILD_EXAMPLES=OFF",
            "-DPXR_BUILD_TUTORIALS=OFF",
            "-DTBB_USE_DEBUG_BUILD=OFF",
            "-DBoost_NO_BOOST_CMAKE=OFF",
            "-DPXR_BUILD_ALEMBIC_PLUGIN=OFF",
            "-DPXR_BUILD_EMBREE_PLUGIN=OFF",
            "-DPXR_ENABLE_PRECOMPILED_HEADERS=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DPXR_BUILD_MONOLITHIC=" .. (package:config("monolithic") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_COMPILE_PDB_OUTPUT_DIRECTORY=")
        end

        table.insert(configs, "-DPXR_BUILD_IMAGING=" .. (package:config("image") and "ON" or "OFF"))
        table.insert(configs, "-DPXR_BUILD_USD_IMAGING=" .. (package:config("image") and "ON" or "OFF"))
        table.insert(configs, "-DPXR_BUILD_OPENIMAGEIO_PLUGIN=" .. (package:config("openimageio") and "ON" or "OFF"))
        table.insert(configs, "-DPXR_BUILD_OPENCOLORIO_PLUGIN=" .. (package:config("opencolorio") and "ON" or "OFF"))
        table.insert(configs, "-DPXR_ENABLE_MATERIALX_SUPPORT=" .. (package:config("materialx") and "ON" or "OFF"))

        table.insert(configs, "-DPXR_ENABLE_VULKAN_SUPPORT=" .. (package:config("vulkan") and "ON" or "OFF"))
        table.insert(configs, "-DPXR_ENABLE_PYTHON_SUPPORT=" .. (package:config("python") and "ON" or "OFF"))
        table.insert(configs, "-DPXR_BUILD_USDVIEW=" .. (package:config("usdview") and "ON" or "OFF"))
        table.insert(configs, "-DPXR_BUILD_USD_TOOLS=" .. (package:config("tools") and "ON" or "OFF"))

        local opt = {}
        if package:is_plat("windows") then
            opt.cxflags = "-D__TBB_NO_IMPLICIT_LINKAGE"
        end
        import("package.tools.cmake").install(package, configs, opt)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test () {
                auto stage = pxr::UsdStage::CreateInMemory();
            }
        ]]}, {configs = {languages = "c++17"}, includes = "pxr/usd/usd/stage.h"}))
    end)
