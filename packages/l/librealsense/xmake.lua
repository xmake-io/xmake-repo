package("librealsense")
    set_homepage("https://www.intelrealsense.com/")
    set_description("Intel® RealSense™ SDK")
    set_license("Apache-2.0")

    add_urls("https://github.com/IntelRealSense/librealsense/archive/refs/tags/$(version).tar.gz",
             "https://github.com/IntelRealSense/librealsense.git", {submodules = false})

    add_versions("v2.57.5", "6fe337090becb668289178b20dfce07d553d4a71fd54ffbfee18b45847bcdee4")
    add_versions("v2.57.4", "3e82f9b545d9345fd544bb65f8bf7943969fb40bcfc73d983e7c2ffcdc05eaeb")

    add_patches(">=2.57.3", "patches/2.57.3/missing-headers.patch", "13834e38528e5009cdffc653515602f32a72e042497457c424de684ff5c69723")

    add_configs("cuda", {description = "Enable CUDA", default = false, type = "boolean"})
    add_configs("openmp", {description = "Use OpenMP", default = false, type = "boolean"})
    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})
    add_configs("check_for_updates", {description = "Checks for versions updates", default = false, type = "boolean"})

    add_links("realsense2", "realsense-file", "rsutils")

    if is_plat("windows", "mingw") then
        add_syslinks("advapi32", "shell32")
    elseif is_plat("macosx") then
        add_frameworks("Security")
    end

    add_deps("cmake")
    add_deps("libusb", "lz4")
    add_deps("nlohmann_json", {configs = {cmake = true}})

    on_check("iphoneos", "bsd", function (package)
        raise("package(librealsense) dep(libusb) unsupported platform!")
    end)

    on_load(function (package)
        if package:config("cuda") then
            package:add("deps", "cuda")
        end
        if package:config("openmp") then
            package:add("deps", "openmp")
        end
        if package:config("tools") and package:config("check_for_updates") then
            package:add("deps", "libcurl")
        end
    end)

    on_install("!cross and !wasm and !mingw and (!windows or windows|!arm*)", function (package)
        -- nlohmann_json
        io.replace("third-party/CMakeLists.txt", "include(CMake/external_json.cmake)", "", {plain = true})
        io.replace("third-party/rsutils/CMakeLists.txt", "$<BUILD_INTERFACE:${CMAKE_BINARY_DIR}/third-party/json/include>", "", {plain = true})
        local file = io.open("third-party/rsutils/CMakeLists.txt", "a")
        if file then
            file:print("find_package(nlohmann_json CONFIG REQUIRED)")
            file:print("target_link_libraries(${PROJECT_NAME} PUBLIC $<BUILD_LOCAL_INTERFACE:nlohmann_json::nlohmann_json>)")
            file:close()
        end
        -- libusb
        if package:is_plat("linux") then
            io.replace("src/linux/CMakeLists.txt", "target_link_libraries(${LRS_TARGET} PRIVATE udev)", "target_link_libraries(${LRS_TARGET} PRIVATE ${UDEV_LIBRARIES})", {plain = true})
        elseif package:is_plat("macosx") then
            io.replace("CMake/libusb_config.cmake", "${LIBUSB_LIB}", [[${LIBUSB_LIB} "-framework CoreFoundation" "-framework IOKit" "-framework Security"]], {plain = true})
        end
        -- libcurl
        if package:config("tools") and package:config("check_for_updates") then
            io.replace("CMake/global_config.cmake", "include(CMake/external_libcurl.cmake)", "find_package(CURL REQUIRED)", {plain = true})
            io.replace("tools/depth-quality/CMakeLists.txt", "add_dependencies(${PROJECT_NAME} libcurl)", "", {plain = true})
            io.replace("tools/depth-quality/CMakeLists.txt", "target_link_libraries(${PROJECT_NAME} curl)", "target_link_libraries(${PROJECT_NAME} CURL::libcurl)", {plain = true})
            io.replace("tools/realsense-viewer/CMakeLists.txt", "add_dependencies(${PROJECT_NAME} libcurl)", "", {plain = true})
            io.replace("tools/realsense-viewer/CMakeLists.txt", "set(RS_VIEWER_LIBS ${RS_VIEWER_LIBS} curl)", "set(RS_VIEWER_LIBS ${RS_VIEWER_LIBS} CURL::libcurl)", {plain = true})
        end
        -- fix links
        io.replace("CMake/windows_config.cmake", [[set(CMAKE_DEBUG_POSTFIX "d")]], "", {plain = true})

        local configs = {
            "-DENABLE_CCACHE=OFF",
            "-DBUILD_EXAMPLES=OFF",
            "-DBUILD_WITH_STATIC_CRT=OFF",
            "-DBUILD_EASYLOGGINGPP=OFF",
            "-DIMPORT_DEPTH_CAM_FW=OFF", -- TODO: unbundle download file
            "-DUSE_EXTERNAL_LZ4=ON",
            -- Do not merge static library all in one, it will run `CREATE /librealsense2-all.a` and fail with Permission denied
            -- We can use policy `package.merge_staticlibs`
            "-DBUILD_RS2_ALL=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_ASAN=" .. (package:config("asan") and "ON" or "OFF"))

        table.insert(configs, "-DBUILD_WITH_CUDA=" .. (package:config("cuda") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_WITH_OPENMP=" .. (package:config("openmp") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_TOOLS=" .. (package:config("tools") and "ON" or "OFF"))
        table.insert(configs, "-DCHECK_FOR_UPDATES=" .. (package:config("check_for_updates") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <librealsense2/rs.hpp>
            void test() {
                rs2::pipeline p;
                auto r = rs2_create_pipeline(nullptr, nullptr);
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
