package("godotcpp")

    set_homepage("https://godotengine.org/")
    set_description("C++ bindings for the Godot script API")

    set_urls("https://github.com/godotengine/godot-cpp.git")
    add_versions("3.2",   "77d41fa179e40560f1e264ed483638bf51713779")
    add_versions("3.3",   "dfee6f0ca41863eacdd47bd3c1c4afa46cc97fa4")
    add_versions("3.4.0", "4efceefe138b2494e3c691e1dead1c60efb621b1")
    add_versions("3.4.3", "ced274fbe62c07dd9bb6791a77392f4bdc625152")
    add_versions("3.4.4", "f4f6fac4c784da8c973ade0dbc64a9d8400ee247")
    add_versions("3.4.5", "a2b2e101f840e11359821d17b027d0b4aa1d9ddc")
    add_versions("3.5", "867374da404887337909e8b7b9de5a8acbc47569")
    add_versions("3.5.1", "316b91c5f5d89d82ae935513c28df78f9e238e8b")
    add_versions("3.5.2", "76d6ad5d8db23b086b175d785812744d2bacf62a")

    add_deps("scons")

    add_includedirs("include", "include/core", "include/gen")

    on_install("linux", "windows", "macosx", "mingw", "cygwin", "iphoneos", "android", "msys", function (package)
        local configs = {"generate_bindings=yes"}
        table.insert(configs, "bits=" .. ((package:is_arch("x64") or package:is_arch("x86_64")) and "64" or "32"))
        if package:is_plat("windows") then
            io.replace("SConstruct", "/MD", "/" .. package:config("vs_runtime"), {plain = true})
        end

        -- this fixes an error on ios and osx (https://godotengine.org/qa/65616/problems-compiling-gdnative-c-example-on-osx)
        if package:is_plat("macosx", "iphoneos") then
            io.replace("SConstruct", "-std=c++14", "-std=c++17", {plain = true})
        end

        -- fix to use correct ranlib, @see https://github.com/godotengine/godot-cpp/issues/510
        if package:is_plat("android") then
            io.replace("SConstruct",
                [[env['AR'] = toolchain + "/bin/" + arch_info['tool_path'] + "-ar"]],
                [[env['AR'] = toolchain + "/bin/" + arch_info['tool_path'] + "-ar"
    env['RANLIB'] = toolchain + "/bin/" + arch_info['tool_path'] + "-ranlib"]], {plain = true})
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
        ]]}, {configs = {languages = "cxx17"}}))
    end)
