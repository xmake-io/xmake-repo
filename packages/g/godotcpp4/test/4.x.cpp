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
    GDExtensionBool GDE_EXPORT example_library_init(GDExtensionInterfaceGetProcAddress p_get_proc_address, GDExtensionClassLibraryPtr p_library, GDExtensionInitialization *r_initialization) {
        godot::GDExtensionBinding::InitObject init_obj(p_get_proc_address, p_library, r_initialization);
        return init_obj.init();
    }
}
