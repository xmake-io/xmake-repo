package("opencl-headers")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/KhronosGroup/OpenCL-Headers/")
    set_description("Khronos OpenCL-Headers")
    set_license("Apache-2.0")

    add_urls("https://github.com/KhronosGroup/OpenCL-Headers/archive/refs/tags/$(version).tar.gz",
             "https://github.com/KhronosGroup/OpenCL-Headers.git")
    add_versions("v2025.07.22", "98f0a3ea26b4aec051e533cb1750db2998ab8e82eda97269ed6efe66ec94a240")
    add_versions("v2025.06.13", "8bf2fda271c3511ee1cd9780b97446e9fa0cf2b0765cdd54aee60074a4567644")
    add_versions("v2024.10.24", "159f2a550592bae49859fee83d372acd152328fdf95c0dcd8b9409f8fad5db93")
    add_versions("v2024.05.08", "3c3dd236d35f4960028f4f58ce8d963fb63f3d50251d1e9854b76f1caab9a309")
    add_versions("v2023.12.14", "407d5e109a70ec1b6cd3380ce357c21e3d3651a91caae6d0d8e1719c69a1791d")
    add_versions("v2021.06.30", "6640d590c30d90f89351f5e3043ae6363feeb19ac5e64bc35f8cfa1a6cd5498e")

    add_deps("cmake")
    on_install(function (package)
        import("package.tools.cmake").install(package, {"-DBUILD_TESTING=OFF"})
    end)

    on_test(function (package)
        assert(package:has_ctypes("cl_int", {includes = "CL/cl.h"}))
    end)
