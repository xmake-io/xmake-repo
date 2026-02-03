package("sheenbidi")
    set_homepage("https://github.com/Tehreer/SheenBidi")
    set_description("A sophisticated implementation of Unicode Bidirectional Algorithm")
    set_license("Apache-2.0")

    add_urls("https://github.com/Tehreer/SheenBidi/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Tehreer/SheenBidi.git")

    add_versions("v3.0.0", "86c56014034739ba39a24c23eb00323b0bf6f737354f665786015fca842af786")
    add_versions("v2.9.0", "e90ae142c6fc8b94366f3526f84b349a2c10137f87093db402fe51f6eace6d13")
    add_versions("v2.8", "6f27d5f347447f593bde573e4cb477925f7ed96afa4f936e7852803e1ddf3fea")
    add_versions("v2.7", "620f732141fd62354361f921a67ba932c44d94e73f127379a0c73ad40c7fa6e0")
    add_versions("v2.6", "f538f51a7861dd95fb9e3f4ad885f39204b5c670867019b5adb7c4b410c8e0d9")

    add_configs("cmake", {description = "Use cmake build system", default = false, type = "boolean"})

    on_load(function (package)
        if package:version() and package:version():ge("3.0.0") then
            if package:config("cmake") then
                package:add("deps", "cmake")
            end
        end

        if package:config("shared") and package:is_plat("windows") then
            package:add("defines", "SB_CONFIG_DLL_IMPORT")
        end
    end)

    on_install(function (package)
        if package:config("cmake") then
            local configs = {"-DBUILD_TESTING=OFF"}
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
            table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
            import("package.tools.cmake").install(package, configs)
        else
            local dll_code = [[
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end
            ]]
            if package:version() and package:version():ge("2.9.0") then
                dll_code = [[
                    if is_plat("windows") then
                        if is_kind("shared") then
                            add_defines("SB_CONFIG_DLL_EXPORT")
                            add_defines("SB_CONFIG_DLL_IMPORT", {interface = true})
                        end
                    end
                ]]
            end
            io.writefile("xmake.lua", [[
                add_rules("mode.debug", "mode.release", "utils.install.cmake_importfiles")
                set_languages("c11")
                set_encodings("utf-8")

                target("sheenbidi")
                    set_kind("$(kind)")
                    add_files("Source/SheenBidi.c")
                    add_defines("SB_CONFIG_UNITY")
                    add_includedirs("Headers", "Source")
                    add_headerfiles("Headers/*.h", "Headers/SheenBidi/*.h", {prefixdir = "SheenBidi"})
                ]] .. dll_code)
            import("package.tools.xmake").install(package)
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("SBAlgorithmCreate", {includes = "SheenBidi/SheenBidi.h", {configs = {languages = "c11"}}}))
    end)
