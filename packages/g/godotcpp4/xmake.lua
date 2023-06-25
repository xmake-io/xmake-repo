package("godotcpp4")

    set_homepage("https://godotengine.org/")
    set_description("C++ bindings for the Godot 4 script API")

    set_urls("https://github.com/godotengine/godot-cpp.git")
    add_versions("4.0", "9d1c396c54fc3bdfcc7da4f3abcb52b14f6cce8f")

    add_deps("scons")
    add_includedirs("gen/include", "include")

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
        if package:is_plat("windows") then
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

        import("package.tools.scons").build(package, configs)
        os.cp("bin/*." .. (package:is_plat("windows") and "lib" or "a"), package:installdir("lib"))
        os.cp("include/godot_cpp", package:installdir("include"))
        os.cp("gen/include/godot_cpp", path.join(package:installdir("gen"), "include", "godot_cpp"))
        os.cp("gdextension/gdextension_interface.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
          #include <godot_cpp/classes/global_constants.hpp>
          #include <godot_cpp/classes/ref_counted.hpp>
          #include <godot_cpp/core/binder_common.hpp>
          using namespace godot;

          class ExampleRef : public RefCounted {
            GDCLASS(ExampleRef, RefCounted);

          protected:
            static void _bind_methods() {
              ClassDB::bind_method(D_METHOD("get_id"), &ExampleRef::get_id);
            }

          public:
            int get_id() { return 5; }
          };

          extern "C" {
          GDExtensionBool GDE_EXPORT
          example_library_init(const GDExtensionInterface *p_interface,
                              GDExtensionClassLibraryPtr p_library,
                              GDExtensionInitialization *r_initialization) {
            ClassDB::register_class<ExampleRef>();
            return true;
          }
          }
        ]]}, {configs = {languages = "cxx17"}}))
    end)
