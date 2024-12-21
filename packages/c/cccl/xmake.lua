package("cccl")
    set_kind("library", {headeronly = true})
    set_homepage("https://nvidia.github.io/cccl/")
    set_description("CUDA Core Compute Libraries")
    set_license("Apache-2.0")

    add_urls("https://github.com/NVIDIA/cccl/archive/refs/tags/$(version).tar.gz",
             "https://github.com/NVIDIA/cccl.git")

    add_versions("v2.6.1", "993f483a3f8134bd719dc61651c0a0db17ad6007ee22e97f4ac4a3c310834004")

    add_configs("cmake", {description = "Use cmake buildsystem", default = false, type = "boolean", readonly = true})

    add_deps("cuda", {system = true})

    on_load(function (package)
        if package:config("cmake") then
            package:add("deps", "cmake")
        end
    end)

    on_install(function (package)
        if package:config("cmake") then
            -- TODO: preset support >= v2.7.0
            local configs = {"--preset", "install"}
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
            import("package.tools.cmake").install(package, configs)
        else
            os.vcp("thrust/thrust", package:installdir("include"))
            os.vcp("cub/cub", package:installdir("include"))
            os.vcp("libcudacxx/include", package:installdir())
            os.vcp("cudax/include/cuda/experimental", package:installdir("include/cuda"))
        end
    end)

    on_test(function (package)
        assert(package:has_cxxincludes("thrust/version.h", {configs = {languages = "c++14"}}))
        assert(package:has_cxxincludes("cub/version.cuh", {configs = {languages = "c++14"}}))
        assert(package:has_cxxincludes("cuda/version", {configs = {languages = "c++14"}}))
        assert(package:has_cxxincludes("cuda/experimental/version.cuh", {configs = {languages = "c++14"}}))
    end)
