package("faiss")
    set_homepage("https://github.com/facebookresearch/faiss/")
    set_description("A library for efficient similarity search and clustering of dense vectors.")
    set_license("MIT")

    add_urls("https://github.com/facebookresearch/faiss/archive/refs/tags/$(version).tar.gz",
             "https://github.com/facebookresearch/faiss.git")
    add_versions("v1.7.4", "d9a7b31bf7fd6eb32c10b7ea7ff918160eed5be04fe63bb7b4b4b5f2bbde01ad")
    add_versions("v1.7.0", "f86d346ac9f409ee30abe37e52f6cce366b7f60d3924d65719f40aa07ceb4bec")

    add_deps("cmake")
    add_deps("cuda", {system = true, optional = true})
    add_deps("mkl", "cuda", {system = true, optional = true})

    if is_plat("linux") then
        add_syslinks("pthread")
    end

    on_load("windows|x64", "linux", function (package)
        if not find_package("mkl") then
            package:add("deps", "openblas")
        end
    end)

    on_install("windows|x64", "linux", function (package)
        io.replace("CMakeLists.txt", "add_subdirectory(demos)", "", {plain = true})
        io.replace("CMakeLists.txt", "add_subdirectory(tutorial/cpp)", "", {plain = true})
        local configs = {"-DFAISS_ENABLE_PYTHON=OFF", "-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DFAISS_ENABLE_GPU=" .. (package:dep("cuda"):exists() and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("faiss::MultiIndexQuantizer", {configs = {languages = "c++11"}, includes = "faiss/IndexPQ.h"}))
    end)
