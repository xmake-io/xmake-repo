package("usd")
    set_homepage("http://www.openusd.org")
    set_description("Universal Scene Description")

    add_urls("https://github.com/PixarAnimationStudios/USD/archive/refs/tags/$(version).tar.gz",
             "https://github.com/PixarAnimationStudios/USD.git")
    add_versions("v22.11", "f34826475bb9385a9e94e2fe272cc713f517b987cbea15ee6bbc6b21db19aaae")

    add_deps("cmake", "boost")
    -- usd only support tbb 2022 now https://github.com/PixarAnimationStudios/USD/issues/1471
    add_deps("tbb 2020.3")

    on_load("windows", function (package)
        package:add("defines", "NOMINMAX")
    end)

    on_install("linux", "macosx", "windows", function (package)
        local configs = {
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
        }
        if is_plat("windows") then
            table.insert(configs, "PXR_USD_WINDOWS_DLL_PATH")
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test () {
                auto stage = pxr::UsdStage::CreateInMemory();
            }
        ]]}, {configs = {languages = "c++17"}, includes="pxr/usd/usd/stage.h"}))
    end)