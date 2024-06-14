package("godotcpp4")
    set_homepage("https://godotengine.org/")
    set_description("C++ bindings for the Godot 4 script API")
    set_license("MIT")

    set_urls("https://github.com/godotengine/godot-cpp.git")
    add_versions("4.2", "2b6eb6832e1dba2816229917dd2a6d54184e1bf4")
    add_versions("4.1", "32becf6a13681119ad63b6d7cc4e816c9a0cc86b")
    add_versions("4.0", "9d1c396c54fc3bdfcc7da4f3abcb52b14f6cce8f")

    add_deps("scons")
    add_includedirs("gen/include", "include")

    on_check("android", function (package)
        if package:version():ge("4.1") then
            raise("package(godotcpp4 >=4.1): only support ndk version 23.2.8568313")
        end
    end)

    on_load(function(package)
        assert(not package:is_arch(
                "mips",
                "mip64",
                "mips64",
                "mipsel",
                "mips64el",
                "s390x",
                "sh4"),
                "architecture " .. package:arch() .. " is not supported")

        if package:is_plat("windows") then
            package:add("defines", "TYPED_METHOD_BIND", "NOMINMAX")
        end
        if package:is_debug() then
            package:add("defines", "DEBUG_ENABLED", "DEBUG_METHODS_ENABLED")
        end
    end)

    on_install("linux", "windows|x64", "windows|x86", "macosx", "iphoneos", "android", function(package)
        if package:is_plat("windows") and package:version():eq("4.0.0") then
            io.replace("tools/targets.py", "/MD", "/" .. package:config("vs_runtime"), {plain = true})
        end

        local platform = package:plat()
        if package:is_plat("mingw") then
            platform = "windows"
        elseif package:is_plat("macosx") then
            platform = "macos"
        elseif package:is_plat("iphoneos") then
            platform = "ios"
        end

        local arch = package:arch()
        if package:is_arch("x86", "i386") then
            arch = "x86_32"
        elseif package:is_arch("arm64-v8a") then
            arch = "arm64"
        elseif package:is_arch("arm", "armeabi", "armeabi-v7a", "armv7s", "armv7k") then
            arch = "arm32"
        end

        local configs = {
            "target=" .. (package:is_debug() and "template_debug" or "template_release"),
            "platform=" .. platform,
            "arch=" .. arch,
            "debug_symbols=" .. (package:is_debug() and "yes" or "no")
        }

        if package:is_plat("windows") then
            table.insert(configs, "use_static_cpp=" .. (package:has_runtime("MT") and "yes" or "no"))
        end

        import("package.tools.scons").build(package, configs)
        os.vcp("bin/*." .. (package:is_plat("windows") and "lib" or "a"), package:installdir("lib"))
        os.vcp("include/godot_cpp", package:installdir("include"))
        os.vcp("gen/include/godot_cpp", path.join(package:installdir("gen"), "include", "godot_cpp"))
        os.vcp("gdextension/gdextension_interface.h", package:installdir("include"))
    end)

    on_test(function (package)
        local file = (package:version():eq("4.0") and "4.0.cpp" or "4.x.cpp")
        local code = io.readfile(path.join(os.scriptdir(), "test", file))
        assert(package:check_cxxsnippets({test = code}, {configs = {languages = "cxx17"}}))
    end)
