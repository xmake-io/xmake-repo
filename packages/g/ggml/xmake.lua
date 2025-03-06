package("ggml")
    set_homepage("https://github.com/ggml-org/ggml")
    set_description("Tensor library for machine learning")
    set_license("MIT")

    add_urls("https://github.com/ggml-org/ggml.git", {submodules = false})

    add_versions("2025.03.05", "d013aa56cdcccefd9086ac93a58951256c84ff16")

    add_configs("openmp", {description = "use OpenMP", default = false, type = "boolean"})
    add_configs("cuda", {description = "use CUDA", default = false, type = "boolean"})
    add_configs("vulkan", {description = "use Vulkan", default = false, type = "boolean"})
    add_configs("kcompute", {description = "use Kompute", default = false, type = "boolean"})
    add_configs("blas", {description = "use BLAS", default = nil, type = "string", values = {"mkl", "openblas"}})

    add_deps("cmake")

    on_check("windows", function (package)
        if package:is_arch("arm.*") and package:has_tool("cxx", "cl") then
            raise("package(ggml) MSVC is not supported for ARM, use clang")
        end
    end)

    on_load(function (package)
        if package:config("openmp") then
            package:add("deps", "openmp")
        end
        if package:config("cuda") then
            package:add("deps", "cuda")
        end
        if package:config("kcompute") then
            package:add("deps", "kcompute")
        end
        if package:config("vulkan") then
            -- requires vulkan loader and glslc
            package:add("deps", "vulkansdk")
            package:add("deps", "shaderc", {configs = {binaryonly = true}})
        end
        if package:config("blas") then
            -- TODO: test it
            if is_subhost("windows") then
                package:add("deps", "pkgconf")
            else
                package:add("deps", "pkg-config")
            end
        end

        if package:config("shared") then
            package:add("defines", "GGML_SHARED")
        end

        local backends = {
            "ggml-cpu",
            "ggml-cuda",
            "ggml-vulkan",
        }
        package:add("links", "ggml", backends, "ggml-base")

        if package:is_plat("linux", "bsd") then
            package:add("syslinks", "pthread", "dl", "m")
        elseif package:is_plat("android") then
            package:add("syslinks", "dl")
        end
    end)

    on_install("!cross", function (package)
        -- Fix missing prefix `lib` for mingw
        io.replace("CMakeLists.txt", "# remove the lib prefix on win32 mingw\nif (WIN32)", "if(0)", {plain = true})

        local configs = {
            "-DGGML_ALL_WARNINGS=OFF",
            "-DGGML_BUILD_TESTS=OFF",
            "-DGGML_BUILD_EXAMPLES=OFF",
            "-DGGML_CCACHE=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DGGML_LTO=" .. (package:config("lto") and "ON" or "OFF"))
        table.insert(configs, "-DGGML_SANITIZE_ADDRESS=" .. (package:config("asan") and "ON" or "OFF"))

        table.insert(configs, "-DGGML_OPENMP=" .. (package:config("openmp") and "ON" or "OFF"))
        table.insert(configs, "-DGGML_CUDA=" .. (package:config("cuda") and "ON" or "OFF"))
        table.insert(configs, "-DGGML_VULKAN=" .. (package:config("vulkan") and "ON" or "OFF"))
        table.insert(configs, "-DGGML_OPENBLAS=" .. (package:config("blas") and "ON" or "OFF"))
        table.insert(configs, "-DGGML_KOMPUTE=" .. (package:config("kcompute") and "ON" or "OFF"))

        local opt = {}
        if package:has_tool("cxx", "cl") then
            opt.cxflags = "/utf-8"
            if package:config("cuda") then
                table.insert(configs, "-DCMAKE_CUDA_FLAGS=-Xcompiler /utf-8")
            end
        end
        import("package.tools.cmake").install(package, configs, opt)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ggml_time_init", {includes = "ggml.h"}))
    end)
