package("bloom")
    set_homepage("https://github.com/wirespider87/bloom")
    set_description("Immediate-mode GUI library for Windows overlays, tools, and internal apps")
    set_license("0BSD")

    add_urls("https://github.com/wirespider87/bloom/archive/refs/tags/v$(version).tar.gz",
             "https://github.com/wirespider87/bloom.git")

    add_versions("1.0.1", "72f446e270816bfa91a874f7c5dc6acc5bc24654da45752cf1e4509a9b82d1d2")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean"})
    add_configs("opengl", {description = "Build OpenGL backend.", default = true, type = "boolean"})
    add_configs("d3d11", {description = "Build Direct3D 11 backend.", default = false, type = "boolean"})

    on_load("windows", function (package)
        package:add("syslinks", "opengl32", "user32", "gdi32", "dwmapi", "shell32")
        if package:config("d3d11") then
            package:add("syslinks", "d3d11", "dxgi", "d3dcompiler")
        end
        if package:config("opengl") then
            package:add("defines", "BLOOM_OPENGL_BACKEND")
        end
        if package:config("d3d11") then
            package:add("defines", "BLOOM_D3D11_BACKEND")
        end
    end)

    on_install("windows", function (package)
        local configs = {
            shared = package:config("shared") and "y" or "n",
            opengl = package:config("opengl") and "y" or "n",
            d3d11 = package:config("d3d11") and "y" or "n",
            examples = "n"
        }
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            #include <bloom.h>
            void test(void) {
                const bloom_api *api = bloom;
                bloom_context *ctx = api->create_context();
                api->destroy_context(ctx);
            }
        ]]}, {configs = {languages = "c11"}}))
    end)
