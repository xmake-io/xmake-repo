package("openimagedenoise")
    set_homepage("https://www.openimagedenoise.org")
    set_description("Intel® Open Image Denoise library")
    set_license("Apache-2.0")

    set_urls("https://github.com/RenderKit/oidn/archive/refs/tags/$(version).tar.gz",
             "https://github.com/RenderKit/oidn.git", {submodules = false})

    add_versions("v2.4.1", "bab9197187a8754cdc0293475a00b7be6a0e967a0da73d6cc86697969cfb0a7e")
    add_versions("v2.3.3", "2b32bd506b819ec0bd0137858af15186d83b760d457b0ac12bd02e0a8544381a")

    add_configs("cpu", {description = "Enable CPU device.", default = false, type = "boolean"})
    add_configs("sycl", {description = "Enable SYCL device.", default = false, type = "boolean"})
    add_configs("cuda", {description = "Enable CUDA device.", default = false, type = "boolean"})
    add_configs("hip", {description = "Enable HIP device.", default = false, type = "boolean"})

    add_configs("filter_rt", {description = "Include trained weights of the RT filter.", default = false, type = "boolean"})
    add_configs("filter_rtlightmap", {description = "Include trained weights of the RTLightmap filter.", default = false, type = "boolean"})
    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::openimagedenoise")
    elseif is_plat("linux") then
        add_extsources("pacman::openimagedenoise")
    elseif is_plat("macosx") then
        add_extsources("brew::open-image-denoise")
    end

    add_links(
        "OpenImageDenoise_device_cpu",
        "OpenImageDenoise_device_cuda",
        "OpenImageDenoise_device_hip",
        "OpenImageDenoise_device_sycl",
        "OpenImageDenoise", "OpenImageDenoise_core"
    )
    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake", "python 3.x", {kind = "binary"})

    if on_check then
        on_check(function (package)
            if package:check_sizeof("void*") == "4" then
                raise("package(openimagedenoise) unsupported 32-bit")
            end
        end)
    end

    on_load(function (package)
        if package:config("cpu") then
            package:add("deps", "ispc", "tbb >=2017")
        end
        if package:config("cuda") then
            package:add("deps", "cuda")
        end
        if package:config("filter_rt") or package:config("filter_rtlightmap") then
            local ok = try { function()
                os.vrun("git lfs version")
                return true
            end }
            if not ok then
                raise("package(openimagedenoise) filter_rt or filter_rtlightmap config require git lfs to donwload weights")
            end
            package:add("resources", "*", "weights", "https://github.com/RenderKit/oidn-weights.git", "28883d1769d5930e13cf7f1676dd852bd81ed9e7")
        end

        if not package:config("shared") then
            package:add("defines", "OIDN_STATIC_LIB")
        end
    end)

    on_install("!android and !wasm", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DOIDN_STATIC_LIB=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DOIDN_DEVICE_CPU=" .. (package:config("cpu") and "ON" or "OFF"))
        table.insert(configs, "-DOIDN_DEVICE_SYCL=" .. (package:config("sycl") and "ON" or "OFF"))
        table.insert(configs, "-DOIDN_DEVICE_CUDA=" .. (package:config("cuda") and "ON" or "OFF"))
        table.insert(configs, "-DOIDN_DEVICE_HIP=" .. (package:config("hip") and "ON" or "OFF"))

        table.insert(configs, "-DOIDN_FILTER_RT=" .. (package:config("filter_rt") and "ON" or "OFF"))
        table.insert(configs, "-DOIDN_FILTER_RTLIGHTMAP=" .. (package:config("filter_rtlightmap") and "ON" or "OFF"))
        table.insert(configs, "-DOIDN_APPS=" .. (package:config("tools") and "ON" or "OFF"))

        local cuda = package:dep("cuda")
        if not is_plat("windows") and package:config("cuda") and cuda then
            local fetch = cuda:fetch()
            if fetch and fetch.includedirs and #fetch.includedirs ~= 0 then
                -- /usr/local/cuda/include -> /usr/local/cuda/bin
                table.insert(configs, "-DCUDAToolkit_ROOT=" .. path.join(path.directory(fetch.includedirs[1]), "bin"))
            end
        end

        if package:config("filter_rt") or package:config("filter_rtlightmap") then
            local weights = package:resourcedir("weights")
            if os.isdir(weights) then
                os.vcp(weights, "weights")
            else
                os.vcp(path.join(path.directory(weights), "**.tza"), "weights/")
            end
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("oidnGetNumPhysicalDevices", {includes = "OpenImageDenoise/oidn.h"}))
    end)
