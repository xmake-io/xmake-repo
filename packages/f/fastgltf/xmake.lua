package("fastgltf")
    set_homepage("https://fastgltf.readthedocs.io/v0.7.x/")
    set_description("A modern C++17 glTF 2.0 library focused on speed, correctness, and usability")
    set_license("MIT")

    add_urls("https://github.com/spnda/fastgltf/archive/refs/tags/$(version).tar.gz",
             "https://github.com/spnda/fastgltf.git")

    add_versions("v0.8.0", "0bc88a0858c88d94306443946a5a1606118b7d5e4960f1e6186a3632e9df38fb")
    add_versions("v0.7.2", "292fc9d0d5a6726c90db88c1aadf09e6d152ffc0ebffe6fb968736c47288511c")
    add_versions("v0.7.1", "44bcb025dd5cd480236a3bc7a3f8c9a708a801ed773b7859677440d22e0e1e7c")

    add_patches("0.7.1", "patches/0.7.1/cmake-simdjson.patch", "943828708f0e011122249196dc70d9a1f026e3212e1c1c35f6988907a6ea4e49")

    add_configs("small_vector", {description = "Uses a custom SmallVector type optimised for small arrays", default = false, type = "boolean"})
    add_configs("memory_pool", {description = "Disables the memory allocation algorithm based on polymorphic resources", default = false, type = "boolean"})
    add_configs("f64", {description = "Default to 64-bit double precision floats for everything", default = false, type = "boolean"})
    add_configs("cxx_standard", {description = "Select c++ standard to build.", default = "17", type = "string", values = {"17", "20"}})
    if is_plat("linux", "mingw") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")
    add_deps("simdjson")

    on_install("windows|x64", "mingw|x86_64", "macosx|x86_64", "linux|x86_64", "linux|arm64", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DFASTGLTF_USE_CUSTOM_SMALLVECTOR=" .. (package:config("small_vector") and "ON" or "OFF"))
        table.insert(configs, "-DFASTGLTF_DISABLE_CUSTOM_MEMORY_POOL=" .. (package:config("memory_pool") and "ON" or "OFF"))
        table.insert(configs, "-DFASTGLTF_USE_64BIT_FLOAT=" .. (package:config("f64") and "ON" or "OFF"))
        table.insert(configs, "-DFASTGLTF_COMPILE_AS_CPP20=" .. ((package:config("cxx_standard") == "20") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs, {packagedeps = "simdjson"})
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("fastgltf::Parser", {configs = {languages = "c++" .. package:config("cxx_standard")}, includes = "fastgltf/core.hpp"}))
    end)
