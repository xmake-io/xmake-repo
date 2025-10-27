package("faiss")
    set_homepage("https://github.com/facebookresearch/faiss/")
    set_description("A library for efficient similarity search and clustering of dense vectors.")
    set_license("MIT")

    add_urls("https://github.com/facebookresearch/faiss/archive/refs/tags/$(version).tar.gz",
             "https://github.com/facebookresearch/faiss.git")
    add_versions("v1.7.0", "f86d346ac9f409ee30abe37e52f6cce366b7f60d3924d65719f40aa07ceb4bec")
    add_versions("v1.12.0", "561376d1a44771bf1230fabeef9c81643468009b45a585382cf38d3a7a94990a")

    add_configs("gpu",        {description = "Enable support for GPU indexes.", default = false, type = "boolean"})
    add_configs("gpu_static", {description = "Link GPU libraries statically.",  default = false, type = "boolean"})
    add_configs("mkl",        {description = "Enable MKL.",                     default = false, type = "boolean"})
    add_configs("python",     {description = "Build Python extension.",         default = false, type = "boolean"})
    add_configs("c_api",      {description = "Build C API.",                    default = false, type = "boolean"})

    if is_plat("linux") then
        add_syslinks("pthread")
    end

    add_deps("cmake", "openmp")
    on_load(function (package)
        if package:config("gpu") then
            package:add("deps", "cuda")
        end
        if package:config("mkl") then
            package:add("deps", "mkl", {system = true, optional = true})
        else
            package:add("deps", "openblas")
        end
    end)

    on_install("windows|x64", "linux", "macosx", function (package)
        local configs = {
            "-DBUILD_TESTING=OFF",
            "-DFAISS_ENABLE_EXTRAS=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DFAISS_ENABLE_GPU=" .. (package:config("gpu") and "ON" or "OFF"))
        table.insert(configs, "-DFAISS_GPU_STATIC=" .. (package:config("gpu_static") and "ON" or "OFF"))
        table.insert(configs, "-DFAISS_ENABLE_MKL=" .. (package:config("mkl") and "ON" or "OFF"))
        table.insert(configs, "-DFAISS_ENABLE_PYTHON=" .. (package:config("python") and "ON" or "OFF"))
        table.insert(configs, "-DFAISS_ENABLE_C_API=" .. (package:config("c_api") and "ON" or "OFF"))
        table.insert(configs, "-DFAISS_ENABLE_LTO=" .. (package:config("lto") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("faiss::MultiIndexQuantizer", {configs = {languages = "c++17"}, includes = "faiss/IndexPQ.h"}))
    end)
