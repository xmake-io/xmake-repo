package("optick")
    set_homepage("https://optick.dev")
    set_description("C++ Profiler For Games (API)")
    set_license("MIT")

    add_urls("https://github.com/bombomby/optick/archive/refs/tags/$(version).0.tar.gz", {alias="archive"})
    add_urls("https://github.com/bombomby/optick.git", {alias="git"})
    add_versions("archive:1.4.0", "8ff386246542654f96a4c1bcc61b7f2f0e498731ed11cd44401baf0c89789b18")
    add_versions("archive:1.3.1", "3670f44219f4d99a6d630c8364c6757d26d7226b0cfd007ee589186397362cc9")
    add_versions("git:1.4.0", "1.4.0.0")
    add_versions("git:1.3.1", "1.3.1.0")
    
    add_configs("vulkan", {description = "Built-in support for Vulkan",     default = false, type = "boolean"})
    add_configs("d3d12",  {description = "Built-in support for DirectX 12", default = false, type = "boolean"})

    if is_plat("windows") then
        add_syslinks("Advapi32")
    end
    
    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DOPTICK_INSTALL_TARGETS=ON")
        table.insert(configs, "-DOPTICK_BUILD_GUI_APP=OFF")
        table.insert(configs, "-DOPTICK_BUILD_CONSOLE_SAMPLE=OFF")
        table.insert(configs, "-DOPTICK_USE_VULKAN=" .. (package:config("vulkan") and "ON" or "OFF"))
        table.insert(configs, "-DOPTICK_USE_D3D12="  .. (package:config("d3d12")  and "ON" or "OFF"))
        
        if not package:config("shared") then
            io.replace("CMakeLists.txt", "SHARED", "STATIC")
        end

        import("package.tools.cmake").install(package, configs)
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
        ]]}, {configs = {languages = "c++11"}, includes = "optick.h"}))
    end)
