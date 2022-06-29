package("quickjspp")

    set_homepage("https://github.com/ftk/quickjspp")
    set_description("QuickJS C++ wrapper")

    add_urls("https://github.com/ftk/quickjspp.git")
    add_versions("20220630", "e2555831d4e86486cf307d49bda803ffca9f0f43")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    
    add_includedirs("include", "include/quickjs")
    add_linkdirs("lib/quickjs")
    add_links("quickjs")

    add_deps("cmake")

    on_install("linux", "macosx", function (package)
        local configs = {"-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_TYPE=" .. (package:config("shared") and "Shared" or "Static"))
        import("package.tools.cmake").install(package, configs, {})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            void test() {
                using namespace qjs;
                Runtime runtime;
                Context context(runtime);
                auto rt = runtime.rt;
                auto ctx = context.ctx;
                js_std_init_handlers(rt);
                js_init_module_std(ctx, "std");
                js_init_module_os(ctx, "os");
                context.eval(R"xxx(
                    import * as std from 'std';
                    import * as os from 'os';
                    globalThis.std = std;
                    globalThis.os = os;
                )xxx", "<input>", JS_EVAL_TYPE_MODULE);

                js_std_loop(ctx);
                js_std_free_handlers(rt);

            }
        ]]}, {configs = {languages = "c++17"}, includes = {"quickjspp.hpp","quickjs/quickjs-libc.h"}}))
    end)
            