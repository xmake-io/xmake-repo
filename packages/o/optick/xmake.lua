package("optick")

    set_homepage("https://optick.dev")
    set_description("C++ Profiler For Games (API)")

    add_urls("https://github.com/bombomby/optick/archive/refs/tags/$(version).0.tar.gz")
    add_versions("1.3.1", "3670f44219f4d99a6d630c8364c6757d26d7226b0cfd007ee589186397362cc9")
    
    add_configs("vulkan", {description = "Built-in support for Vulkan",     default = false, type = "boolean"})
    add_configs("d3d12",  {description = "Built-in support for DirectX 12", default = false, type = "boolean"})
    
    if is_plat("windows") then
        add_syslinks("Advapi32")
    end
    
    add_deps("cmake")

    on_install("windows", "linux", "android", function (package)
        local configs = {}
        table.insert(configs, "-DOPTICK_INSTALL_TARGETS=OFF")
        table.insert(configs, "-DOPTICK_BUILD_GUI_APP=OFF")
        table.insert(configs, "-DOPTICK_BUILD_CONSOLE_SAMPLE=OFF")
        table.insert(configs, "-DOPTICK_USE_VULKAN=" .. (package:config("vulkan") and "ON" or "OFF"))
        table.insert(configs, "-DOPTICK_USE_D3D12="  .. (package:config("d3d12")  and "ON" or "OFF"))
        
        if not package:config("shared") then
            io.replace("CMakeLists.txt", "SHARED", "STATIC")
        end

        import("package.tools.cmake").install(package, configs, {buildir = "build"})

        os.trycp("build/libOptickCore." .. (package:config("shared") and "so" or "a"), path.join(package:installdir(), "lib"))
        os.trycp("build/OptickCore." .. (package:config("shared") and "dll" or "lib"), path.join(package:installdir(), "lib"))
        os.rm("src/*.cpp")
        os.cp("src", path.join(package:installdir(), "include"), {rootdir = "src"})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test=[[
            void test(int args, char* argv[]) {
                float v = 6.0f;
                for (int i = 0;i < 5; i++) {
                    OPTICK_FRAME("MainThread");
                    v *= v * v + (float)i;
                }
            }
        ]]}, {includes = "optick.h"}))
    end)
