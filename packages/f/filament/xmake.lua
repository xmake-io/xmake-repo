package("filament")

    set_homepage("https://google.github.io/filament/")
    set_description("Filament is a real-time physically-based renderer written in C++.")
    set_license("Apache-2.0")

    if is_plat("windows") and is_arch("x64") then
        add_urls("https://github.com/google/filament/releases/download/v$(version)/filament-v$(version)-windows.tgz")
        add_versions("1.9.23", "8f5728dd944c052f991bfb15d18cd6fc8f678d0cbd37bb066d76bf682ab789c8")
        add_versions("1.20.3", "0a3fdd5fe8662a02117f3de51dcbea3b260cff716a7cffa407ca939727d7b634")
        add_versions("1.32.0", "6372895cd7729df722bb0529a1ceb086aee3e532268d541db88aba4a252cde4e")
    elseif is_plat("macosx") and is_arch("x86_64") then
        add_urls("https://github.com/google/filament/releases/download/v$(version)/filament-v$(version)-mac.tgz")
        add_versions("1.9.23", "0adbf2359338e28a80b2ef84c70d8914b56ed1c97ef0135603fcd330ec4c34a1")
        add_versions("1.20.3", "820f2c7b5360021b9ff361f0868b45613726d6704f9112e8c8cf92d07c7c95b7")
        add_versions("1.32.0", "f8bd877227f10a9dc10513bfc6a396a5bb0c65b15d2fd771e2e5de4d39267395")
    elseif is_plat("linux") and is_arch("x86_64") then
        add_urls("https://github.com/google/filament/releases/download/v$(version)/filament-v$(version)-linux.tgz")
        add_versions("1.9.23", "016473371753ff6beb430900eb6550f73acc71c1092cbb654f272ed0666f6210")
        add_versions("1.20.3", "f57e1c967e09fe73ef69b0db8a48a09b3dab6f9ecb21b906b3f1fbe1d3a2ce3d")
        add_versions("1.32.0", "9c3fba4ed307aeeaa412f1846774c7a1c30afff3404d7f9822a7e77338f70fe9")
    end

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    if is_plat("windows") then
        add_syslinks("user32", "gdi32", "opengl32")
    elseif is_plat("macosx") then
        add_frameworks("Cocoa", "Metal", "CoreVideo")
    elseif is_plat("linux") then
        add_deps("libc++")
        add_syslinks("pthread", "dl")
    end
    add_links("filament", "backend", "bluegl", "bluevk", "filabridge", "filaflat", "utils", "geometry", "smol-v", "vkshaders", "ibl")

    on_install("windows|x64", "macosx|x86_64", "linux|x86_64", function (package)
        os.cp("*", package:installdir())
        if package:is_plat("windows") then
            package:add("linkdirs", path.join("lib", "x86_64", package:config("vs_runtime"):lower()))
        else
            package:add("linkdirs", path.join("lib", "x86_64"))
        end
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets([[
            #include <filament/FilamentAPI.h>
            #include <filament/Engine.h>
            void test() {
                filament::Engine* engine = filament::Engine::create();
                engine->destroy(&engine);
            }
        ]], {configs = {languages = "c++20"}}))
    end)
