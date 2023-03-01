package("gdextension")

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
        "riscv",
        "riscv64",
        "s390x",
        "sh4"),
        "architecture " .. package:arch() .. " is not supported")
  end)
 
  on_install("linux", "windows", "macosx", "mingw", "iphoneos", "android", function(package)
    import("core.base.option")
    import("lib.detect.find_tool")
  
    local platform = package:plat()
    if package:is_plat("mingw") then
        platform = "windows"
    elseif package:is_plat("macosx") then
        platform = "macos"
    elseif package:is_plat("iphoneos") then
        platform = "ios"
    end
    
    local arch = package:arch()
    if package:is_arch("x64") then
        arch = "x86_64"
    elseif package:is_arch("x86", "i386") then
        arch = "x86_32"
    elseif package:is_arch("arm64-v8a") then
        arch = "arm64"
    elseif package:is_arch("arm", "armeabi", "armeabi-v7a", "armv7", "armv7s", "armv7k") then
        arch = "arm32"
    elseif package:is_arch("ppc") then
        arch = "ppc32"
    end
    
    local configs = {
      "-j " .. (option.get("jobs") or tostring(os.default_njob())),
      "use_mingw=" .. (package:is_plat("mingw") and "yes" or "no"),
      "target=" .. (package:debug() and "template_debug" or "template_release"),
      "platform=" .. platform,
      "arch=" .. arch,
      "debug_symbols=" .. (package:debug() and "yes" or "no")
    }
    
    local scons = assert(find_tool("scons"), "scons not found")
    
    os.execv(scons.program, configs)
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
      #include <godot_cpp/variant/utility_functions.hpp>
      
      using namespace godot;
      
      class ExampleRef : public RefCounted {
	     GDCLASS(ExampleRef, RefCounted);
      
      private:
	     static int instance_count;
	     static int last_id;
      
	     int id;
      
      protected:
	     static void _bind_methods() {
		      ClassDB::bind_method(D_METHOD("get_id"), &ExampleRef::get_id);
	     }
      
      public:
	     ExampleRef() {
		      id = ++last_id;
		      instance_count++;
      
		      UtilityFunctions::print("ExampleRef ", itos(id), " created, current instance count: ", itos(instance_count));
	     }
	     ~ExampleRef() {
		      instance_count--;
		      UtilityFunctions::print("ExampleRef ", itos(id), " destroyed, current instance count: ", itos(instance_count));
	     }
      
	     int get_id() const {
		      return id;
	     }
      };
      
      int ExampleRef::instance_count = 0;
      int ExampleRef::last_id = 1;
      
      void initialize_example_module(ModuleInitializationLevel p_level) {
	     if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
		      return;
	     }
      
	     ClassDB::register_class<ExampleRef>();
      }
      
      void uninitialize_example_module(ModuleInitializationLevel p_level) {
	     if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
		      return;
	     }
      }
      
      extern "C" {
      // Initialization.
      GDExtensionBool GDE_EXPORT example_library_init(const GDExtensionInterface *p_interface, GDExtensionClassLibraryPtr p_library, GDExtensionInitialization *r_initialization) {
	     godot::GDExtensionBinding::InitObject init_obj(p_interface, p_library, r_initialization);
      
	     init_obj.register_initializer(initialize_example_module);
	     init_obj.register_terminator(uninitialize_example_module);
	     init_obj.set_minimum_library_initialization_level(MODULE_INITIALIZATION_LEVEL_SCENE);
      
	     return init_obj.init();
      }
      }
    ]]}, {configs = {languages = "cxx17"}}))
  end)
