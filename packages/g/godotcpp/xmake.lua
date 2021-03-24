package("godotcpp")

    set_homepage("https://godotengine.org/")
    set_description("C++ bindings for the Godot script API")

    set_urls("https://github.com/godotengine/godot-cpp.git")
    add_versions("3.2", "77d41fa179e40560f1e264ed483638bf51713779")

    add_deps("scons")

    add_includedirs("include", "include/core", "include/gen")

    on_install("linux", "windows", "macosx", "mingw", "cygwin", "iphoneos", "msys", "android", function (package)
        -- configure platform for scons
        local scons_plat = package:plat()
        if package:is_plat("macosx") then
            scons_plat = "osx"
        elseif package:is_plat("iphoneos") then
            scons_plat = "ios"
        elseif package:is_plat("mingw", "cygwin", "msys") then
            scons_plat = "windows"
        elseif package:is_plat("bsd") then
            scons_plat = "freebsd"
        end
        -- configure architecture for scons
        local scons_bits = "64"
        if package:is_arch("x86") then
            scons_bits = "32"
        end
        -- configure architecture for android
        local scons_android_arch = "armv7"
        if package:is_arch("arm64-v8a") then
            scons_android_arch = "arm64v8"
        end
        -- configure architecture for ios
        local scons_ios_arch = package:arch()

        local configs = {
            "platform=" .. scons_plat,
            "bits=" .. scons_bits,
            "generate_bindings=yes",
            "target=" .. (package:debug() and "debug" or "release"),
            "use_mingw=" .. (package:is_plat("mingw", "cygwin", "msys") and "yes" or "no"),
        }

        if package:is_plat("android") then
            table.insert(configs, "android_arch=" .. scons_android_arch)
        elseif package:is_plat("iphoneos") then
            table.insert(configs, "ios_arch=" .. scons_ios_arch)
        elseif package:is_plat("windows") then
            io.gsub("SConstruct", "/MD", "/" .. package:config("vs_runtime"))
        end

        import("package.tools.scons").build(package, configs)
        os.cp("bin/*." .. (package:is_plat("windows") and "lib" or "a"), package:installdir("lib"))
        os.cp("include/core/*.hpp", package:installdir("include/core"))
        os.cp("include/gen/*.hpp",  package:installdir("include/gen"))
        os.cp("godot-headers/android",            package:installdir("include"))
        os.cp("godot-headers/arvr",               package:installdir("include"))
        os.cp("godot-headers/gdnative",           package:installdir("include"))
        os.cp("godot-headers/nativescript",       package:installdir("include"))
        os.cp("godot-headers/net",                package:installdir("include"))
        os.cp("godot-headers/pluginscript",       package:installdir("include"))
        os.cp("godot-headers/videodecoder",       package:installdir("include"))
        os.cp("godot-headers/*.h",                package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
        #include <Godot.hpp>
        #include <Reference.hpp>
        using namespace godot;
        class SimpleClass : public Reference {
            GODOT_CLASS(SimpleClass, Reference);
        public:
            SimpleClass() { }
            void _init() { }
            Variant method(Variant arg) {
                Variant ret; ret = arg; return ret;
            }
            static void _register_methods() {
                register_method("method", &SimpleClass::method);
            }
        };
        extern "C" void GDN_EXPORT godot_gdnative_init(godot_gdnative_init_options *o) { godot::Godot::gdnative_init(o); }
        extern "C" void GDN_EXPORT godot_gdnative_terminate(godot_gdnative_terminate_options *o) { godot::Godot::gdnative_terminate(o); }
        extern "C" void GDN_EXPORT godot_nativescript_init(void *handle) {
            godot::Godot::nativescript_init(handle);
            godot::register_class<SimpleClass>();
        }
        ]]}))
    end)
