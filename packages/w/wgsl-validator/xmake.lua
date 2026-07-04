package("wgsl-validator")
    set_base("rustlib")
    set_kind("library")
    set_homepage("https://github.com/NazaraEngine/wgsl-validator")
    set_description("WGSL validator in Rust with C bindings.")
    set_license("MIT")

    add_urls("https://github.com/NazaraEngine/wgsl-validator/archive/refs/tags/$(version).tar.gz",
             "https://github.com/NazaraEngine/wgsl-validator.git")

    add_versions("v1.0.0", "1ea4c13cc548bc785920d5b80ff94ccb97587ca69389c6b7d41f734e9f6b056b")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    if is_plat("windows", "mingw") then
        add_syslinks("kernel32", "ntdll", "userenv", "ws2_32", "dbghelp")
    elseif is_plat("linux", "bsd") then
        add_syslinks("dl", "m", "pthread", "rt", "util")
    end

    on_install(function (package)
        package:base():script("install")(package)
        local envs = package:data("xmake_envs")

        io.writefile("xmake.lua", [[
            add_requires("cargo::naga latest", {configs = {features = "wgsl-in"}})

            target("wgsl-validator")
                set_kind("static")
                set_toolchains("rust@rust")
                add_files("src/lib.rs")
                add_headerfiles("ffi/*.h")
                set_values("rust.cratetype", "staticlib")
                add_packages("cargo::naga")
        ]])
        if is_host("windows") and package:is_plat("mingw", "msys") then
            local mingw_root = os.programdir():match("^(.-[/\\]mingw%d+)[/\\]")
            if mingw_root then
                envs = table.clone(envs or {})
                envs.PATH = path.join(mingw_root, "bin") .. path.envsep() .. (os.getenv("PATH") or "")
            end
        end
        import("package.tools.xmake").install(package, nil, {envs = envs})
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
