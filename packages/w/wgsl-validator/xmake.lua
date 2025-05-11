package("wgsl-validator")
    set_homepage("https://github.com/NazaraEngine/wgsl-validator")
    set_description("WGSL validator in Rust with C bindings.")
    set_license("MIT")

    add_urls("https://github.com/NazaraEngine/wgsl-validator/archive/refs/tags/$(version).tar.gz",
             "https://github.com/NazaraEngine/wgsl-validator.git")

    add_versions("v1.0.0", "1ea4c13cc548bc785920d5b80ff94ccb97587ca69389c6b7d41f734e9f6b056b")

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})

    if is_plat("windows", "mingw") then
        add_syslinks("Advapi32", "User32", "Userenv", "WS2_32", "RuntimeObject", "NtDll")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    on_load(function (package)
        package:add("deps", "rust", {configs = {target_plat = package:plat(), target_arch = package:arch()}})
    end)

    on_check("mingw|i386", function (package)
        -- MinGW 32bits exception model must match rustc LLVM exception model (dwarf2)
        local mingw = package:toolchain("mingw")
        if not mingw then
            print("toolchain not found")
            return
        end

        local compiler, toolname = mingw:tool("cc")
        if toolname ~= "gcc" then
            print("toolname not gcc (" .. toolname .. ")")
            return
        end

        local output, errdata = os.iorunv(compiler, {"-v"})
        print("stdout", output)
        print("stderr", errdata)
        -- for some reason the output is in stderr
        if #output:trim() == 0 then
            output = errdata
        end
        print("gcc -v", output)
        assert(output:find("--with-dwarf2", 1, true), "rustc is only compatible with dwarf2 exception model in 32bits mode, please use dwarf2 MinGW")
    end)

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_requires("rust", {configs = {target_plat = get_config("plat"), target_arch = get_config("arch")}})
            add_requires("cargo::naga latest", {configs = {features = "wgsl-in"}})

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
