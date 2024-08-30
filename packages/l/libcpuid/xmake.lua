package("libcpuid")
    set_homepage("https://github.com/anrieff/libcpuid")
    set_description("a small C library for x86 CPU detection and feature extraction")

    add_urls("https://github.com/anrieff/libcpuid/archive/refs/tags/$(version).tar.gz",
             "https://github.com/anrieff/libcpuid.git")
    add_versions("v0.7.0", "cfd9e6bcda5da3f602273e55f983bdd747cb93dde0b9ec06560e074939314210")
    add_versions("v0.6.5", "4d106d66d211f2bfaf876eb62c84d4b54664e1c2b47eb6138161d3c608c0bc5e")
    add_versions("v0.6.4", "1cbb1a79bfe6c37884a538b56504fa0975e78e492aee7c265a42f654c6056cb3")
    add_versions("v0.6.3", "da570fdeb450634d84208f203487b2e00633eac505feda5845f6921e811644fc")
    add_versions("v0.5.1", "36d62842ef43c749c0ba82237b10ede05b298d79a0e39ef5fd1115ba1ff8e126")

    add_deps("cmake")

    on_install("windows|x86", "windows|x64", "macosx", "linux", "mingw", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        io.replace("CMakeLists.txt", "add_subdirectory(tests)", "", {plain = true})
        if package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
            table.insert(configs, "-DMSVC_CXX_ARCHITECTURE_ID=" .. package:targetarch())
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("cpuid_get_vendor", {includes = "libcpuid/libcpuid.h"}))
    end)
