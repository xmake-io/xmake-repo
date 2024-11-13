package("soil2")
    set_homepage("https://github.com/SpartanJ/SOIL2")
    set_description("SOIL2 is a tiny C library used primarily for uploading textures into OpenGL.")
    set_license("MIT-0")

    add_urls("https://github.com/SpartanJ/SOIL2.git")
    add_versions("2024.10.14", "1ecaa772fdc67a49f9737452d628730384806f9b")

    add_deps("cmake")
    add_deps("opengl")

    on_install("!android and !wasm", function (package)
        io.replace("CMakeLists.txt", "$<$<CXX_COMPILER_ID:Clang>:-fPIC>", "", {plain = true})
        io.replace("CMakeLists.txt", "$<$<CXX_COMPILER_ID:GNU>:-fPIC>", "", {plain = true})

        local configs = {"-DSOIL2_BUILD_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") and package:config("shared") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end
        import("package.tools.cmake").install(package, configs)

        if package:is_plat("windows") and package:is_debug() then
            local dir = package:installdir(package:config("shared") and "bin" or "lib")
            os.trycp(path.join(package:buildir(), "soil2.pdb"), dir)
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("SOIL_load_OGL_texture", {includes = "SOIL2/SOIL2.h"}))
    end)
