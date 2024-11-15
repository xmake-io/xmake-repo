package("soil2")
    set_homepage("https://github.com/SpartanJ/SOIL2")
    set_description("SOIL2 is a tiny C library used primarily for uploading textures into OpenGL.")
    set_license("MIT-0")

    add_urls("https://github.com/SpartanJ/SOIL2.git")
    add_versions("2024.10.14", "1ecaa772fdc67a49f9737452d628730384806f9b")

    if is_plat("macosx") then
        add_frameworks("CoreFoundation")
    end

    add_deps("cmake")
    add_deps("opengl", {optional = true})

    if on_check then
        on_check("windows", function (package)
            if package:is_arch("arm.*") then
                local vs_toolset = package:toolchain("msvc"):config("vs_toolset")
                if vs_toolset then
                    local vs_toolset_ver = import("core.base.semver").new(vs_toolset)
                    local minor = vs_toolset_ver:minor()
                    assert(minor and minor >= 30, "package(soil2) require vs_toolset >= 14.3")
                end
            end
        end)
    end

    -- TODO: fix glXGetProcAddress on linux
    on_install("windows", "macosx", "mingw", "msys", function (package)
        io.replace("CMakeLists.txt", "$<$<CXX_COMPILER_ID:Clang>:-fPIC>", "", {plain = true})
        io.replace("CMakeLists.txt", "$<$<CXX_COMPILER_ID:GNU>:-fPIC>", "", {plain = true})

        local configs = {"-DSOIL2_BUILD_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") and package:config("shared") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end

        local opt = {packagedeps = "opengl"}
        if package:is_plat("macosx") then
            opt.shflags = {"-framework", "CoreFoundation"}
        end
        import("package.tools.cmake").install(package, configs, opt)

        if package:is_plat("windows") and package:is_debug() then
            local dir = package:installdir(package:config("shared") and "bin" or "lib")
            os.trycp(path.join(package:buildir(), "soil2.pdb"), dir)
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("SOIL_load_OGL_texture", {includes = "soil2/SOIL2.h"}))
    end)
