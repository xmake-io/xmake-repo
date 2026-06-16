package("llama.cpp")
    set_homepage("https://github.com/ggml-org/llama.cpp")
    set_description("Port of Facebook's LLaMA model in C/C++")
    set_license("MIT")

    add_urls("https://github.com/ggml-org/llama.cpp/archive/refs/tags/b$(version).tar.gz",
             "https://github.com/ggml-org/llama.cpp.git")

    add_versions("9647", "b3faee1d784ee12ae492fb9dafec09e099acae38c9b864eab5f072977478e7f7")
    add_versions("9500", "ebff6593ce1555c2f01e19b8545d6b47db87d4aed5a8e67c721c45ef708b553b")
    add_versions("9000", "98bac6351ee3a1c6490e6c84940fdf213a39cf5f8f2100a680e646fa57a43608")
    add_versions("8500", "1ee7d187ede94452fcbb71ee5856e923212b84ed5f2ddfa5ec487a1079b23cb3")
    add_versions("6000", "9be103102d597a9820a525158f91d349ba84e19e12a9177bd591b67c82d2fc0f")
    add_versions("4000", "bdfc19f69f966ef98e0f1ab6c7744eda1229bafaa121f515b3f4f0ac8779fd9f")
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
    elseif is_plat("windows") then
        add_syslinks("advapi32")
    end

    add_links("llama", "ggml", "ggml-base", "ggml-cpu")

    add_deps("cmake", "ninja")

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
            package:add("links", "ggml-vulkan")
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
            "-DLLAMA_BUILD_TOOLS=OFF",
            "-DLLAMA_BUILD_COMMON=OFF",
            "-DLLAMA_BUILD_APP=OFF",
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

        if package:config("vulkan") then
            local shaderc = package:dep("shaderc")
            local fetched = shaderc:fetch()
            local glslc = fetched and fetched.program
            if not glslc then
                glslc = path.join(shaderc:installdir("bin"), "glslc" .. (is_host("windows") and ".exe" or ""))
            end
            if not (fetched and fetched.program) and not os.isfile(glslc) then
                glslc = nil
            end
            assert(glslc, "package(llama.cpp): Vulkan requires glslc from shaderc")
            if glslc then
                table.insert(configs, "-DVulkan_GLSLC_EXECUTABLE=" .. glslc)
            end
        end

        local opt = {builddir = "b"}
        if package:is_plat("windows") then
            local ninja = package:dep("ninja")
            if ninja then
                local ninja_exe = path.join(ninja:installdir("bin"), "ninja.exe")
                if os.isfile(ninja_exe) then
                    table.insert(configs, "-DCMAKE_MAKE_PROGRAM=" .. ninja_exe)
                end
            end
        end

        import("package.tools.cmake").install(package, configs, opt)

        if package:config("vulkan") then
            local vulkan_libs = os.files(path.join(package:installdir("lib"), "*ggml-vulkan*"))
            assert(vulkan_libs and #vulkan_libs > 0, "package(llama.cpp): Vulkan was enabled, but ggml-vulkan was not installed")
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ggml_time_us", {includes = "ggml.h"}))
        assert(package:has_cfuncs("llama_backend_init", {includes = "llama.h"}))
    end)
