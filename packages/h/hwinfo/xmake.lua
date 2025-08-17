package("hwinfo")
    set_homepage("https://github.com/lfreist/hwinfo")
    set_description("Cross platform C++ library for hardware information (CPU, RAM, GPU, ...)")
    set_license("MIT")

    add_urls("https://github.com/lfreist/hwinfo.git")
    add_versions("2025.05.09", "64bc6ea98518d2964443bb1104cde90e9e031820")

    local comps = {"os", "mainboard", "cpu", "disk", "ram", "gpu", "battery", "network"}
    for _, c in ipairs(comps) do
        add_configs(c, {description = "Enable " .. c .. " information", default = true, type = "boolean"})
    end
    add_configs("gpu_opencl", {description = "Enable OpenCL support", default = false, type = "boolean"})

    if is_plat("linux") then
        add_syslinks("pthread", "dl")
    end

    add_deps("cmake")

    on_install("windows", "linux", "macosx", function (package)
        local configs = {"-DBUILD_TESTING=OFF", "-DBUILD_EXAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DHWINFO_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DHWINFO_STATIC=" .. (package:config("shared") and "OFF" or "ON"))

        table.insert(configs, "-DHWINFO_GPU_OPENCL=" .. (package:config("gpu_opencl") and "ON" or "OFF"))
        local comps = {"OS","MAINBOARD","CPU","DISK","RAM","GPU","BATTERY","NETWORK"}
        for _, c in ipairs(comps) do
            table.insert(configs, "-DHWINFO_" .. c .. "=" .. (package:config(c:lower()) and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)

        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            void test(){
                const auto cpus = hwinfo::getAllCPUs();
                for(const auto& cpu : cpus){
                    std::cout << cpu.vendor();
                }
            }
        ]]}, {configs = {languages = "cxx20"}, includes = "hwinfo/hwinfo.h"}))
    end)
