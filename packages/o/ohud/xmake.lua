package("ohud")
    set_homepage("https://github.com/orange-cpp/ohud")
    set_description("Cross-platform modern hud library for cheat development written in C++23 ")
    set_license("zlib")

    add_urls("https://github.com/orange-cpp/ohud.git")
    add_versions("2025.07.31", "361caed885b153d2e0a210219d22dd3397902f2b")

    add_deps("cmake")
    add_deps("imgui")

    on_install(function (package)
        os.mkdir("cmake")
        io.writefile("cmake/ohudConfig.cmake.in", [[
        @PACKAGE_INIT@
        include(CMakeFindDependencyMacro)
        find_dependency(imgui CONFIG)
        include("${CMAKE_CURRENT_LIST_DIR}/ohudTargets.cmake")
        check_required_components(ohud)
        ]])
        local CMakeLists_content = io.readfile("CMakeLists.txt")
        io.writefile("CMakeLists.txt", CMakeLists_content .. [[

        install(TARGETS ${PROJECT_NAME}
                EXPORT ${PROJECT_NAME}Targets
                ARCHIVE DESTINATION lib COMPONENT ${PROJECT_NAME}
                LIBRARY DESTINATION lib COMPONENT ${PROJECT_NAME}
                RUNTIME DESTINATION bin COMPONENT ${PROJECT_NAME}
        )
        install(DIRECTORY include/ DESTINATION include COMPONENT ${PROJECT_NAME})
        install(EXPORT ${PROJECT_NAME}Targets
                FILE ${PROJECT_NAME}Targets.cmake
                NAMESPACE ${PROJECT_NAME}::
                DESTINATION lib/cmake/${PROJECT_NAME} COMPONENT ${PROJECT_NAME}
        )
        include(CMakePackageConfigHelpers)
        write_basic_package_version_file(
                "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
                VERSION ${PROJECT_VERSION}
                COMPATIBILITY AnyNewerVersion
        )
        configure_package_config_file(
                "${CMAKE_CURRENT_SOURCE_DIR}/cmake/${PROJECT_NAME}Config.cmake.in"
                "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
                INSTALL_DESTINATION lib/cmake/${PROJECT_NAME}
        )
        install(FILES
                "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
                "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
                DESTINATION lib/cmake/${PROJECT_NAME}
        )
        ]])
        local configs = {"-DOHUD_BUILD_EXAMPLES=OFF"}
        if package:config("shared") then
            io.replace("CMakeLists.txt", "STATIC", "", {plain = true})
            if package:is_plat("windows") then
                table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
            end
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                ohud::EntityOverlayRender ent({350.f, 100.f}, {350.f, 350.f});
            }
        ]]}, {configs = {languages = "c++23"}, includes = "ohud/entity_overlay_render.hpp"}))
    end)
