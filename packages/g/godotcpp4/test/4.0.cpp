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
