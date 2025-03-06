package("llama.cpp")
    set_homepage("https://github.com/ggerganov/llama.cpp")
    set_description("Port of Facebook's LLaMA model in C/C++")
    set_license("MIT")

    add_urls("https://github.com/ggerganov/llama.cpp/archive/refs/tags/b$(version).tar.gz",
             "https://github.com/ggerganov/llama.cpp.git")

    add_versions("3775", "405bae9d550cb3fbf36d6583377b951a346b548f5850987238fe024a16f45cad")

    add_configs("curl", {description = "llama: use libcurl to download model from an URL", default = false, type = "boolean"})
    add_configs("openmp", {description = "ggml: use OpenMP", default = false, type = "boolean"})
    add_configs("cuda", {description = "ggml: use CUDA", default = false, type = "boolean"})
    add_configs("vulkan", {description = "ggml: use Vulkan", default = false, type = "boolean"})
    add_configs("blas", {description = "ggml: use BLAS", default = nil, type = "string", values = {"mkl", "openblas"}})

    if is_plat("macosx", "iphoneos") then
        add_frameworks("Accelerate", "Foundation", "Metal", "MetalKit")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_links("llama", "ggml")

    add_deps("cmake")

    if on_check then
        on_check("android", function (package)
            local ndk = package:toolchain("ndk")
            local ndkver = ndk:config("ndkver")
            local ndk_sdkver = ndk:config("ndk_sdkver")
            assert(ndkver and tonumber(ndkver) > 22, "package(llama.cpp) require ndkver > 22")
            assert(ndk_sdkver and tonumber(ndk_sdkver) >= 24, "package(llama.cpp) require ndk api >= 24")
        end)

        on_check("windows", function (package)
            if package:is_arch("arm.*") then
                local vs_toolset = package:toolchain("msvc"):config("vs_toolset")
                if vs_toolset then
                    local vs_toolset_ver = import("core.base.semver").new(vs_toolset)
                    local minor = vs_toolset_ver:minor()
                    assert(minor and minor >= 30, "package(llama.cpp/arm64) require vs_toolset >= 14.3")
                end
            end
        end)
    end

    on_load(function (package)
        if package:config("shared") then
            package:add("defines", "GGML_SHARED", "LLAMA_SHARED")
        end

        if package:config("curl") then
            package:add("deps", "libcurl")
        end
        if package:config("openmp") then
            package:add("deps", "openmp")
        end
        if package:config("cuda") then
            package:add("deps", "cuda")
        end
        if package:config("vulkan") then
            -- requires vulkan-1 and glslc
            package:add("deps", "vulkansdk")
            package:add("deps", "shaderc", {configs = {binaryonly = true}})
        end
        if package:config("blas") then
            if is_subhost("windows") then
                package:add("deps", "pkgconf")
            else
                package:add("deps", "pkg-config")
            end
        end
    end)

    on_install(function (package)
        local configs = {
            "-DLLAMA_ALL_WARNINGS=OFF",
            "-DLLAMA_BUILD_TESTS=OFF",
            "-DLLAMA_BUILD_EXAMPLES=OFF",
            "-DLLAMA_BUILD_SERVER=OFF",
            "-DGGML_ALL_WARNINGS=OFF",
            "-DGGML_BUILD_TESTS=OFF",
            "-DGGML_BUILD_EXAMPLES=OFF",
            "-DGGML_CCACHE=OFF",
        }
        table.insert(configs, "-DCMAKE_CROSSCOMPILING=" .. (package:is_cross() and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DLLAMA_SANITIZE_ADDRESS=" .. (package:config("asan") and "ON" or "OFF"))
        table.insert(configs, "-DGGML_LTO=" .. (package:config("lto") and "ON" or "OFF"))
        table.insert(configs, "-DGGML_SANITIZE_ADDRESS=" .. (package:config("asan") and "ON" or "OFF"))

        table.insert(configs, "-DLLAMA_CURL=" .. (package:config("curl") and "ON" or "OFF"))
        table.insert(configs, "-DGGML_OPENMP=" .. (package:config("openmp") and "ON" or "OFF"))
        table.insert(configs, "-DGGML_CUDA=" .. (package:config("cuda") and "ON" or "OFF"))
        table.insert(configs, "-DGGML_VULKAN=" .. (package:config("vulkan") and "ON" or "OFF"))
        table.insert(configs, "-DGGML_OPENBLAS=" .. (package:config("blas") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ggml_time_us", {includes = "ggml.h"}))
        assert(package:has_cfuncs("llama_backend_init", {includes = "llama.h"}))
    end)
