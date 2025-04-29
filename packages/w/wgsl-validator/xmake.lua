package("wgsl-validator")
    set_homepage("https://github.com/NazaraEngine/wgsl-validator")
    set_description("WGSL validator in Rust with C bindings.")
    set_license("MIT")

    add_urls("https://github.com/NazaraEngine/wgsl-validator.git")

    add_urls("https://github.com/NazaraEngine/wgsl-validator/archive/refs/tags/$(version).tar.gz",
             "https://github.com/NazaraEngine/wgsl-validator.git")

    add_versions("v1.0.0", "1ea4c13cc548bc785920d5b80ff94ccb97587ca69389c6b7d41f734e9f6b056b")

    add_deps("rust")

    on_load("windows", function (package)
        if not package:config("shared") then
            package:add("Advapi32", "User32", "Userenv", "WS2_32", "RuntimeObject", "NtDll")
        end
    end)

    on_install("windows|x64", "windows|x86", "windows|arm64", "linux|arm64", "linux|x86_64", "macosx|x86_64", "macosx|arm64", function (package)
        io.writefile("xmake.lua", [[
            add_requires("rust")
            add_requires("cargo::naga latest", { configs = { features = "wgsl-in" } })

            target("wgsl-validator")
                set_kind("static")
                set_toolchains("rust@rust")
                add_files("src/lib.rs")
                add_headerfiles("ffi/*.h")
                set_values("rust.cratetype", "staticlib")
                add_packages("cargo::naga")
        ]])
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            #include <wgsl_validator.h>
            #define WGSL_SOURCE(...) #__VA_ARGS__
            const char* wgsl_source = WGSL_SOURCE(
                @fragment
                fn main_fs() -> @location(0) vec4<f32> {
                    return vec4<f32>(1.0, 1.0, 1.0, 1.0);
                }
            );

            void test() {
                char* error;
                wgsl_validator_t* validator = wgsl_validator_create();
                if(wgsl_validator_validate(validator, wgsl_source, &error))
                    wgsl_validator_free_error(error);
                wgsl_validator_destroy(validator);
            }
        ]]}, { configs = { languages = "c17" } }))
    end)
