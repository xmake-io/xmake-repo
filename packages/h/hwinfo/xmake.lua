package("hwinfo")
    set_homepage("https://github.com/lfreist/hwinfo")
    set_description("Cross platform C++ library for hardware information (CPU, RAM, GPU, ...)")
    set_license("MIT")

    add_urls("https://github.com/lfreist/hwinfo.git")

    add_configs("shared", {description = "Build shared library", default = true, type = "boolean"})
    local comps = {"os", "mainboard", "cpu", "disk", "ram", "gpu", "battery", "network"}
    for _, c in ipairs(comps) do
        add_configs(c, {description = "Enable "..c.." information", default = true, type = "boolean"})
    end
    add_configs("gpu_opencl", {description = "Enable OpenCL support", default = false, type = "boolean"})

    if is_plat("windows") then
        add_syslinks("setupapi", "powrprof", "cfgmgr32", "dxgi")
    else
        add_syslinks("pthread", "dl")
    end

    add_deps("cmake")

    on_install(function (package)
        local configs = {
            "-DHWINFO_SHARED=" .. (package:config("shared") and "ON" or "OFF"),
            "-DHWINFO_STATIC=" .. (package:config("shared") and "OFF" or "ON"),
            "-DHWINFO_GPU_OPENCL=" .. (package:config("gpu_opencl") and "ON" or "OFF"),
            "-DBUILD_EXAMPLES=OFF",
            "-DBUILD_TESTING=OFF"
        }
        local comps = {"OS","MAINBOARD","CPU","DISK","RAM","GPU","BATTERY","NETWORK"}
        for _, c in ipairs(comps) do
            table.insert(configs, "-DHWINFO_"..c.."=" .. (package:config(c:lower()) and "ON" or "OFF"))
        end

        import("package.tools.cmake").install(package, configs)

        os.cp("include/**", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("hwinfo::CPU", {
            includes = {"hwinfo/hwinfo.h"},
            configs  = {languages = "c++20"}
        }))
    end)

