package("assimp")

    set_homepage("https://assimp.org")
    set_description("Portable Open-Source library to import various well-known 3D model formats in a uniform manner")
    set_license("BSD-3-Clause")

    set_urls("https://github.com/assimp/assimp/archive/$(version).zip",
             "https://github.com/assimp/assimp.git")
    add_versions("v5.2.5", "5384877d53be7b5bbf50c26ab3f054bec91b3df8614372dcd7240f44f61c509b")
    add_versions("v5.2.4", "713e9aa035ae019e5f3f0de1605de308d63538897249a2ba3a2d7d40036ad2b1")
    add_versions("v5.2.3", "9667cfc8ddabd5dd5e83f3aebb99dbf232fce99f17b9fe59540dccbb5e347393")
    add_versions("v5.2.2", "7b833182b89917b3c6e8aee6432b74870fb71f432cc34aec5f5411bd6b56c1b5")
    add_versions("v5.2.1", "636fe5c2cfe925b559b5d89e53a42412a2d2ab49a0712b7d655d1b84c51ed504")
    add_versions("v5.1.4", "59a00cf72fa5ceff960460677e2b37be5cd1041e85bae9c02828c27ade7e4160")
    add_versions("v5.0.1", "d10542c95e3e05dece4d97bb273eba2dfeeedb37a78fb3417fd4d5e94d879192")

    add_patches("v5.0.1", path.join(os.scriptdir(), "patches", "5.0.1", "fix-mingw.patch"), "a3375489e2bbb2dd97f59be7dd84e005e7e9c628b4395d7022a6187ca66b5abb")
    add_patches("v5.2.1", path.join(os.scriptdir(), "patches", "5.2.1", "fix_zlib_filefunc_def.patch"), "a9f8a9aa1975888ea751b80c8268296dee901288011eeb1addf518eac40b71b1")
    add_patches("v5.2.2", path.join(os.scriptdir(), "patches", "5.2.1", "fix_zlib_filefunc_def.patch"), "a9f8a9aa1975888ea751b80c8268296dee901288011eeb1addf518eac40b71b1")
    add_patches("v5.2.3", path.join(os.scriptdir(), "patches", "5.2.1", "fix_zlib_filefunc_def.patch"), "a9f8a9aa1975888ea751b80c8268296dee901288011eeb1addf518eac40b71b1")
    add_patches("v5.2.3", path.join(os.scriptdir(), "patches", "5.2.3", "cmake_static_crt.patch"), "3872a69976055bed9e40814e89a24a3420692885b50e9f9438036e8d809aafb4")
    add_patches("v5.2.4", path.join(os.scriptdir(), "patches", "5.2.4", "fix_x86_windows_build.patch"), "becb4039c220678cf1e888e3479f8e68d1964c49d58f14c5d247c86b4a5c3293")

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

    add_deps("cmake", "minizip", "zlib")

    if is_plat("windows") then
        add_syslinks("advapi32")
    end

    on_load(function (package)
        if not package:gitref() and package:version():le("5.1.0") then
            package:add("deps", "irrxml")
        end
        if package:is_plat("linux", "macosx") and package:config("shared") then
            package:add("links", "assimp" .. (package:is_debug() and "d" or ""))
        end
    end)

    on_install(function (package)
        local configs = {"-DASSIMP_BUILD_SAMPLES=OFF",
                         "-DASSIMP_BUILD_TESTS=OFF",
                         "-DASSIMP_BUILD_DOCS=OFF",
                         "-DASSIMP_BUILD_FRAMEWORK=OFF",
                         "-DASSIMP_INSTALL_PDB=ON",
                         "-DASSIMP_INJECT_DEBUG_POSTFIX=ON",
                         "-DASSIMP_BUILD_ZLIB=OFF",
                         "-DSYSTEM_IRRXML=ON",
                         "-DASSIMP_WARNINGS_AS_ERRORS=OFF"}
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

        if not package:gitref() and package:version():lt("v5.2.4") then
            -- ASSIMP_WARNINGS_AS_ERRORS is not supported before v5.2.4
            if package:is_plat("windows") then
                io.replace("code/CMakeLists.txt", "TARGET_COMPILE_OPTIONS(assimp PRIVATE /W4 /WX)", "", {plain = true})
            else
                io.replace("code/CMakeLists.txt", "TARGET_COMPILE_OPTIONS(assimp PRIVATE -Werror)", "", {plain = true})
            end
        end
        if package:is_plat("mingw") and package:version():lt("v5.1.5") then
            -- CMAKE_COMPILER_IS_MINGW has been removed: https://github.com/assimp/assimp/pull/4311
            io.replace("CMakeLists.txt", "CMAKE_COMPILER_IS_MINGW", "MINGW", {plain = true})
        end

        -- Assimp CMakeLists doesn't find minizip on Windows
        local ldflags
        if package:is_plat("windows") then
            local minizip = package:dep("minizip")
            if minizip and not minizip:is_system() then
                local fetchinfo = minizip:fetch({external = false})
                if fetchinfo then
                    ldflags = {}
                    for _, linkdir in ipairs(fetchinfo.linkdirs) do
                        table.insert(ldflags, "/LIBPATH:" .. linkdir:gsub("\\", "/"))
                    end
                end
            end
        end

        import("package.tools.cmake").install(package, configs, {ldflags = ldflags, shflags = ldflags})

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
        assert(package:check_cxxsnippets({test = [[
            #include <cassert>
            void test() {
                Assimp::Importer importer;
            }
        ]]}, {configs = {languages = "c++11"}, includes = "assimp/Importer.hpp"}))
    end)
