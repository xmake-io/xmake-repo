package("filament")

    set_homepage("https://google.github.io/filament/")
    set_description("Filament is a real-time physically-based renderer written in C++.")
    set_license("Apache-2.0")

    if is_plat("windows") and is_arch("x64") then
        add_urls("https://github.com/google/filament/releases/download/v$(version)/filament-v$(version)-windows.tgz")
        add_versions("1.20.3", "0a3fdd5fe8662a02117f3de51dcbea3b260cff716a7cffa407ca939727d7b634")
    elseif is_plat("macosx") and is_arch("x86_64") then
        add_urls("https://github.com/google/filament/releases/download/v$(version)/filament-v$(version)-mac.tgz")
        add_versions("1.20.3", "820f2c7b5360021b9ff361f0868b45613726d6704f9112e8c8cf92d07c7c95b7")
    elseif is_plat("linux") and is_arch("x86_64") then
        add_urls("https://github.com/google/filament/releases/download/v$(version)/filament-v$(version)-linux.tgz")
        add_versions("1.20.3", "f57e1c967e09fe73ef69b0db8a48a09b3dab6f9ecb21b906b3f1fbe1d3a2ce3d")
    end

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    if is_plat("windows") then
        add_syslinks("user32", "gdi32", "opengl32")
    elseif is_plat("macosx") then
        add_frameworks("Cocoa", "Metal", "CoreVideo")
    elseif is_plat("linux") then
        add_syslinks("pthread", "dl")
    end
    add_links("backend", "bluegl", "bluevk", "filabridge", "filaflat", "utils", "geometry", "smol-v", "vkshaders", "ibl")

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
        assert(package:has_cxxtypes("filament::Engine", {configs = {languages = "c++17"}, includes = "filament/Engine.h"}))
    end)
