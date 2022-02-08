package("assimp")

    set_homepage("https://assimp.org")
    set_description("Portable Open-Source library to import various well-known 3D model formats in a uniform manner")
    set_license("BSD-3-Clause")

    set_urls("https://github.com/assimp/assimp/archive/$(version).zip",
             "https://github.com/assimp/assimp.git")
    add_versions("v5.2.1", "636fe5c2cfe925b559b5d89e53a42412a2d2ab49a0712b7d655d1b84c51ed504")
    add_versions("v5.1.4", "59a00cf72fa5ceff960460677e2b37be5cd1041e85bae9c02828c27ade7e4160")
    add_versions("v5.0.1", "d10542c95e3e05dece4d97bb273eba2dfeeedb37a78fb3417fd4d5e94d879192")
    add_patches("v5.0.1", path.join(os.scriptdir(), "patches", "5.0.1", "fix-mingw.patch"), "a3375489e2bbb2dd97f59be7dd84e005e7e9c628b4395d7022a6187ca66b5abb")

    if not is_host("windows") then
        add_extsources("pkgconfig::assimp")
    end

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::assimp")
    elseif is_plat("linux") then
        add_extsources("pacman::assimp", "apt::libassimp-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::assimp")
    end

    add_configs("build_tools",           {description = "Build the supplementary tools for Assimp.", default = false, type = "boolean"})
    add_configs("double_precision",      {description = "Enable double precision processing.", default = false, type = "boolean"})
    add_configs("no_export",             {description = "Disable Assimp's export functionality (reduces library size).", default = false, type = "boolean"})
    add_configs("android_jniiosysystem", {description = "Enable Android JNI IOSystem support.", default = false, type = "boolean"})
    add_configs("asan",                  {description = "Enable AddressSanitizer.", default = false, type = "boolean"})
    add_configs("ubsan",                 {description = "Enable Undefined Behavior sanitizer.", default = false, type = "boolean"})

    add_deps("cmake", "zlib")

    if is_plat("windows") then
        add_syslinks("advapi32")
    end

    on_load(function (package)
        if package:version():le("5.1.0") then
            package:add("deps", "irrxml")
            if package:is_plat("linux") and package:config("shared") then
                package:add("ldflags", "-Wl,--as-needed," .. package:installdir("lib", "libassimp.so"))
            end
        end
    end)

    on_install("windows", "linux", "macosx", "mingw", function (package)
        io.replace("CMakeLists.txt", "FIND_PACKAGE(ZLIB)", "FIND_PACKAGE(ZLIB REQUIRED)", {plain = true})
        local configs = {"-DASSIMP_BUILD_SAMPLES=OFF",
                         "-DASSIMP_BUILD_TESTS=OFF",
                         "-DASSIMP_BUILD_DOCS=OFF",
                         "-DASSIMP_BUILD_FRAMEWORK=OFF",
                         "-DASSIMP_INSTALL_PDB=ON",
                         "-DASSIMP_INJECT_DEBUG_POSTFIX=ON",
                         "-DASSIMP_BUILD_ZLIB=OFF",
                         "-DSYSTEM_IRRXML=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))

        local function add_config_arg(config_name, cmake_name)
            table.insert(configs, "-D" .. cmake_name .. "=" .. (package:config(config_name) and "ON" or "OFF"))
        end
        add_config_arg("shared",           "BUILD_SHARED_LIBS")
        add_config_arg("double_precision", "ASSIMP_DOUBLE_PRECISION")
        add_config_arg("no_export",        "ASSIMP_NO_EXPORT")
        add_config_arg("asan",             "ASSIMP_ASAN")
        add_config_arg("ubsan",            "ASSIMP_UBSAN")
        if package:is_plat("android") then
            add_config_arg("android_jniiosysystem", "ASSIMP_ANDROID_JNIIOSYSTEM")
        end
        if package:is_plat("windows", "linux", "macosx", "mingw") then
            add_config_arg("build_tools", "ASSIMP_BUILD_ASSIMP_TOOLS")
        else
            table.insert(configs, "-DASSIMP_BUILD_ASSIMP_TOOLS=OFF")
        end

        if package:is_plat("mingw") then
            -- CMAKE_COMPILER_IS_MINGW has been removed: https://github.com/assimp/assimp/pull/4311
            io.replace("CMakeLists.txt", "CMAKE_COMPILER_IS_MINGW", "MINGW", {plain = true})
        end

        -- patch environment variables
        import("package.tools.cmake")
        local envs = cmake.buildenvs(package)
        local zlib = package:dep("zlib")
        if zlib and not zlib:is_system() then
            envs.ZLIB_HOME = zlib:installdir()
        end
        cmake.install(package, configs, {envs = envs})

        -- copy pdb
        if package:is_plat("windows") then
            if package:config("shared") then
                os.trycp(path.join(package:buildir(), "bin", "**.pdb"), package:installdir("bin"))
            else
                os.trycp(path.join(package:buildir(), "lib", "**.pdb"), package:installdir("lib"))
            end
        end
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("Assimp::Importer", {configs = {languages = "c++11"}, includes = "assimp/Importer.hpp"}))
    end)
