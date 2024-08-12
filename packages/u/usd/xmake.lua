package("usd")
    set_homepage("http://www.openusd.org")
    set_description("Universal Scene Description")
    set_license("Apache-2.0")

    add_urls("https://github.com/PixarAnimationStudios/USD/archive/refs/tags/$(version).tar.gz",
             "https://github.com/PixarAnimationStudios/USD.git")

    add_versions("v24.08", "6640bb184bf602c6df14fa4a83af6ac5ae1ab8d1d38cf7bb7decfaa9a7ad5d06")
    add_versions("v24.05", "0352619895588efc8f9d4aa7004c92be4e4fa70e1ccce77e474ce23941c05828")
    add_versions("v24.03", "0724421cff8ae04d0a7108ffa7c104e6ec3f7295418d4d50caaae767e59795ef")
    add_versions("v23.02", "a8eefff722db0964ce5b11b90bcdc957f3569f1cf1d44c46026ecd229ce7535d")
    add_versions("v22.11", "f34826475bb9385a9e94e2fe272cc713f517b987cbea15ee6bbc6b21db19aaae")

    add_configs("shared", {description = "Build shared binaries.", default = true, type = "boolean", readonly = true})
    add_configs("monolithic", {description = "Build single shared library", default = false, type = "boolean"})

    add_deps("cmake", "boost")
    -- usd only support tbb 2022 now https://github.com/PixarAnimationStudios/USD/issues/1471
    add_deps("tbb 2020.3")

    if is_plat("windows") then
        add_defines("NOMINMAX")
    end

    on_install("linux", "macosx|x86_64", "windows|x64", function (package)
        local configs = {
            "-DTBB_USE_DEBUG_BUILD=OFF",
            "-DPXR_BUILD_ALEMBIC_PLUGIN=OFF",
            "-DBoost_NO_BOOST_CMAKE=OFF",
            "-DPXR_BUILD_EMBREE_PLUGIN=OFF",
            "-DPXR_BUILD_IMAGING=OFF",
            "-DPXR_BUILD_MONOLITHIC=OFF",
            "-DPXR_BUILD_TESTS=OFF",
            "-DPXR_BUILD_USD_IMAGING=OFF",
            "-DPXR_ENABLE_PYTHON_SUPPORT=OFF",
            "-DPXR_BUILD_EXAMPLES=OFF",
            "-DPXR_BUILD_TUTORIALS=OFF",
            "-DPXR_BUILD_USD_TOOLS=OFF",
            "-DPXR_BUILD_MONOLITHIC=" .. (package:config("monolithic") and "ON" or "OFF")
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test () {
                auto stage = pxr::UsdStage::CreateInMemory();
            }
        ]]}, {configs = {languages = "c++17"}, includes = "pxr/usd/usd/stage.h"}))
    end)
