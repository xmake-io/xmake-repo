package("godotcpp")

    set_homepage("https://godotengine.org/")
    set_description("C++ bindings for the Godot script API")

    set_urls("https://github.com/godotengine/godot-cpp.git")
    add_versions("3.2", "77d41fa179e40560f1e264ed483638bf51713779")

    add_includedirs("include", "include/core", "include/gen")

    on_install(function (package)
        import("package.tools.scons").build(package, {"platform=" .. package:plat(), "generate_bindings=yes", "target=" .. (package:debug() and "debug" or "release")})
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

            /** `_init` must exist as it is called by Godot. */
            void _init() { }

            void test_void_method() {
                Godot::print("This is test");
            }

            Variant method(Variant arg) {
                Variant ret;
                ret = arg;

                return ret;
            }

            static void _register_methods() {
                register_method("method", &SimpleClass::method);

                /**
                * The line below is equivalent to the following GDScript export:
                *     export var _name = "SimpleClass"
                **/
                register_property<SimpleClass, String>("base/name", &SimpleClass::_name, String("SimpleClass"));

                /** Alternatively, with getter and setter methods: */
                register_property<SimpleClass, int>("base/value", &SimpleClass::set_value, &SimpleClass::get_value, 0);

                /** Registering a signal: **/
                // register_signal<SimpleClass>("signal_name");
                // register_signal<SimpleClass>("signal_name", "string_argument", GODOT_VARIANT_TYPE_STRING)
            }

            String _name;
            int _value;

            void set_value(int p_value) {
                _value = p_value;
            }

            int get_value() const {
                return _value;
            }
        };

        /** GDNative Initialize **/
        extern "C" void GDN_EXPORT godot_gdnative_init(godot_gdnative_init_options *o) {
            godot::Godot::gdnative_init(o);
        }

        /** GDNative Terminate **/
        extern "C" void GDN_EXPORT godot_gdnative_terminate(godot_gdnative_terminate_options *o) {
            godot::Godot::gdnative_terminate(o);
        }

        /** NativeScript Initialize **/
        extern "C" void GDN_EXPORT godot_nativescript_init(void *handle) {
            godot::Godot::nativescript_init(handle);

            godot::register_class<SimpleClass>();
        }
        ]]}))
    end)
