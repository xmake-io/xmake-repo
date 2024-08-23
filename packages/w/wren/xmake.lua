package("wren")
    set_homepage("http://wren.io")
    set_description("The Wren Programming Language. Wren is a small, fast, class-based concurrent scripting language.")
    set_license("MIT")

    add_urls("https://github.com/wren-lang/wren/archive/refs/tags/$(version).tar.gz",
             "https://github.com/wren-lang/wren.git")

    add_versions("0.4.0", "23c0ddeb6c67a4ed9285bded49f7c91714922c2e7bb88f42428386bf1cf7b339")

    on_install(function (package)
        local configs = {}
        io.writefile("xmake.lua", format([[
            local kind = "%s"
            add_rules("mode.debug", "mode.release")
            target("wren")
                set_kind(kind)
                add_headerfiles("src/include/*.h", "src/vm/*.h", "src/optional/*.h")
                add_includedirs("src/include", "src/vm", "src/optional")
                add_files("src/vm/*.c", "src/optional/*.c")

                if is_mode("debug") then
                    add_defines("DEBUG")
                elseif is_mode("release") then
                    add_defines("NDEBUG")
                end

        ]], package:config("shared") and "shared" or "static"))
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            int main() {
                WrenConfiguration config;
                wrenInitConfiguration(&config);

                WrenVM* vm = wrenNewVM(&config);

                const char* script = 
                    "class HelloWorld {\n"
                    "  static main() {\n"
                    "    System.print(\"Hello from Wren!\")\n"
                    "  }\n"
                    "}";

                WrenInterpretResult result = wrenInterpret(vm, "main", script);

                if (result == WREN_RESULT_SUCCESS) {
                    wrenEnsureSlots(vm, 1); 
                    wrenGetVariable(vm, "main", "HelloWorld", 0); 
                    WrenHandle* classHandle = wrenGetSlotHandle(vm, 0);

                    wrenEnsureSlots(vm, 1); 
                    wrenSetSlotHandle(vm, 0, classHandle);
                    
                    result = wrenCall(vm, 0); 

                    if (result != WREN_RESULT_SUCCESS) {
                        fprintf(stderr, "Error calling main function.\n");
                        wrenFreeVM(vm);
                        return 1; 
                    }
                } else {
                    fprintf(stderr, "Error interpreting Wren script.\n");
                    wrenFreeVM(vm);
                    return 1; 
                }

                wrenFreeVM(vm);
                return 0; 
            }
        ]]}, {
            includes = {"wren.h", "stdio.h"}
        }))
    end)
