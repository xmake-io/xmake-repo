package("dobby")
    set_homepage("https://github.com/jmpews/Dobby")
    set_description("a lightweight, multi-platform, multi-architecture hook framework.")
    set_license("Apache-2.0")

    add_urls("https://github.com/jmpews/Dobby.git")

    add_versions("2023.4.14", "0932d69c320e786672361ab53825ba8f4245e9d3")
    
    add_patches("2023.4.14", path.join(os.scriptdir(), "patches", "fix-compile-on-lower-version-of-gcc.patch"), "632aad7d79e2afd9587089a39c3eb2b64a3750ab3c8954f04672c13abcddbbae")

    add_configs("symbol_resolver", {description = "Enable symbol resolver plugin.", default = true,  type = "boolean"})
    add_configs("import_table_replacer", {description = "Enable import table replacer plugin.", default = false, type = "boolean", readonly = not is_plat("macosx", "iphoneos")})
    add_configs("android_bionic_linker_utils", {description = "Enable android bionic linker utils.",  default = false, type = "boolean", readonly = not is_plat("android")})

    add_configs("near_branch", {description = "Enable near branch trampoline.", default = true,  type = "boolean"})
    add_configs("full_floating_point_register_pack", {description = "Enables saving and packing of all floating-point registers.", default = false, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")
    on_install("linux", "macosx", "android", "iphoneos", function (package)
        local configs = {"-DDOBBY_BUILD_EXAMPLE=OFF", "-DDOBBY_BUILD_TEST=OFF"}
        table.insert(configs, "-DDOBBY_DEBUG=" .. (package:is_debug() and "ON" or "OFF"))
        table.insert(configs, "-DPlugin.SymbolResolver=" .. (package:config("symbol_resolver") and "ON" or "OFF"))
        table.insert(configs, "-DPlugin.ImportTableReplace=" .. (package:config("import_table_replacer") and "ON" or "OFF"))
        table.insert(configs, "-DPlugin.Android.BionicLinkerUtil=" .. (package:config("android_bionic_linker_utils") and "ON" or "OFF"))
        table.insert(configs, "-DNearBranch=" .. (package:config("near_branch") and "ON" or "OFF"))
        table.insert(configs, "-DFullFloatingPointRegisterPack=" .. (package:config("full_floating_point_register_pack") and "ON" or "OFF"))

        if package:is_plat("android") then
            local ndk = package:toolchain("ndk")
            table.insert(configs, "-DCMAKE_ANDROID_NDK=" .. ndk:config("ndk"))
            table.insert(configs, "-DCMAKE_ANDROID_ARCH_ABI=" .. package:arch())
            local sdkver = "21"
            if package:is_arch("armeabi-v7a", "x86") then
                sdkver = "19"
            end
            table.insert(configs, "-DCMAKE_SYSTEM_VERSION=" .. sdkver)
        elseif package:is_plat("iphoneos") then
            table.insert(configs, "-DCMAKE_SYSTEM_PROCESSOR=" .. package:arch())
            table.insert(configs, "-DCMAKE_OSX_DEPLOYMENT_TARGET=9.3") -- from scripts/platform_builder.py:158
        end

        local cxflags = {}
        if not package:is_debug() then
            io.replace("CMakeLists.txt", "add_subdirectory(external/logging)", "", {plain = true})
            io.replace("CMakeLists.txt", "get_target_property(logging.SOURCE_FILE_LIST logging SOURCES)", "", {plain = true})
            io.replace("CMakeLists.txt", "${logging.SOURCE_FILE_LIST}", "", {plain = true})
            table.insert(cxflags, "-DDOBBY_LOGGING_DISABLE")
        end

        import("package.tools.cmake").build(package, configs, {buildir = "build", cxflags = cxflags})
        os.cp("include/dobby.h", package:installdir("include"))
        if package:config("android_bionic_linker_utils") then
            os.cp("builtin-plugin/BionicLinkerUtil/bionic_linker_util.h", package:installdir("include"))
        end
        local so_extname = "so"
        if package:is_plat("macosx", "iphoneos") then
            so_extname = "dylib"
        end
        os.cp(package:config("shared") and "build/libdobby." .. so_extname or "build/libdobby.a", package:installdir("lib"))
    end)

    on_test(function (package)
        local check_funcs = {"DobbyGetVersion"}
        if package:config("symbol_resolver") then
            table.insert(check_funcs, "DobbySymbolResolver")
        end
        if package:config("import_table_replacer") then
            table.insert(check_funcs, "DobbyImportTableReplace")
        end
        if package:config("android_bionic_linker_utils") then
            table.insert(check_funcs, "linker_dlopen")
        end
        for _, func in ipairs(check_funcs) do
            assert(package:has_cxxfuncs(func, {configs = {languages = "c++11"}, includes = "dobby.h"}))
        end
    end)
