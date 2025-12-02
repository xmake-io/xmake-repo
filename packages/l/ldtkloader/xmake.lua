package("ldtkloader")
    set_homepage("https://github.com/Madour/LDtkLoader")
    set_description("A C++11 loader for levels and tile maps created with LDtk (Level Designer ToolKit)")
    set_license("zlib")

    add_urls("https://github.com/Madour/LDtkLoader.git", {alias = "git"})
    add_urls("https://github.com/Madour/LDtkLoader/archive/refs/tags/$(version).tar.gz", {
        version = function (version)
            return version:gsub("+", ".")
        end
    })

    add_versions("1.5.3+1", "22c736c7045522cc659f83d1a4288c1d5a1bbd620c425f9fec6dd3219d2f950a")

    add_versions("git:1.5.3+1", "1.5.3.1")

    add_configs("no_throw", {description = "Disable exceptions and replace throws with exit()", default = false, type = "boolean"})
    add_configs("field_optional", {description = "Enable std::optional accessors", default = false, type = "boolean"})

    add_deps("cmake")

    on_load(function (package)
        if package:config("no_throw") then
            package:add("defines", "LDTK_NO_THROW", "JSON_NOEXCEPTION")
        end
    end)

    on_install(function (package)
        -- Support shared build
        io.replace("CMakeLists.txt", "STATIC", "", {plain = true})
        io.replace("CMakeLists.txt", "ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}", "RUNTIME DESTINATION bin LIBRARY DESTINATION lib ARCHIVE DESTINATION lib", {plain = true})

        local configs = {
            "-DLDTK_BUILD_SFML_EXAMPLE=OFF",
            "-DLDTK_BUILD_SDL_EXAMPLE=OFF",
            "-DLDTK_BUILD_RAYLIB_EXAMPLE=OFF",
            "-DLDTK_BUILD_API_TEST=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:config("shared") and package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end

        table.insert(configs, "-DLDTK_NO_THROW=" .. (package:config("no_throw") and "ON" or "OFF"))
        table.insert(configs, "-DLDTK_FIELD_PUBLIC_OPTIONAL=" .. (package:config("field_optional") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <LDtkLoader/Project.hpp>
            void test(){
                ldtk::Project ldtk_project;
                ldtk_project.loadFromFile("my_project.ldtk");
            }
        ]]}, {configs = {languages = package:config("field_optional") and "c++17" or "c++11"}}))
    end)
