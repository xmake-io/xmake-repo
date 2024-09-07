package("embree")

    set_homepage("https://www.embree.org/")
    set_description("Intel® Embree is a collection of high-performance ray tracing kernels, developed at Intel.")
    set_license("Apache-2.0")

    add_urls("https://github.com/RenderKit/embree/archive/refs/tags/$(version).tar.gz",
             "https://github.com/RenderKit/embree.git")
    add_versions("v3.12.1", "0c9e760b06e178197dd29c9a54f08ff7b184b0487b5ba8b8be058e219e23336e")
    add_versions("v3.13.0", "4d86a69508a7e2eb8710d571096ad024b5174834b84454a8020d3a910af46f4f")
    add_versions("v3.13.3", "74ec785afb8f14d28ea5e0773544572c8df2e899caccdfc88509f1bfff58716f")
    add_versions("v3.13.4", "e6a8d1d4742f60ae4d936702dd377bc4577a3b034e2909adb2197d0648b1cb35")
    add_versions("v3.13.5", "b8c22d275d9128741265537c559d0ea73074adbf2f2b66b0a766ca52c52d665b")
    add_versions("v4.3.0", "baf0a57a45837fc055ba828a139467bce0bc0c6a9a5f2dccb05163d012c12308")
    add_versions("v4.3.3", "8a3bc3c3e21aa209d9861a28f8ba93b2f82ed0dc93341dddac09f1f03c36ef2d")

    -- Not recommanded to build embree as a static library.
    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean"})

    add_deps("cmake", "tbb")
    if is_plat("windows") then
        add_syslinks("advapi32")
    end

    on_install("macosx", "linux", "windows|x64", "windows|x86", function (package)
        if package:version():lt("4.0.0") then
            package:add("links", "embree3", "embree_sse42", "embree_avx", "embree_avx2", "embree_avx512", "tasking", "simd", "lexers", "math", "sys")
        end
        io.replace("common/tasking/CMakeLists.txt", "include(installTBB)", "", {plain = true})
        local configs = {"-DBUILD_TESTING=OFF", "-DBUILD_DOC=OFF", "-DEMBREE_TUTORIALS=OFF", "-DEMBREE_ISPC_SUPPORT=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DEMBREE_STATIC_LIB=" .. (package:config("shared") and "OFF" or "ON"))
        if package:is_plat("windows") then
            table.insert(configs, "-DUSE_STATIC_RUNTIME=" .. (package:has_runtime("MT", "MTd") and "ON" or "OFF"))
        end
        if package:is_plat("macosx") and package:is_arch("x86_64") and not package:config("shared") then
            table.insert(configs, "-DEMBREE_MAX_ISA=DEFAULT")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        local major_version = package:version():major()
        local includes = "embree" .. major_version .. "/rtcore.h"
        assert(package:check_cxxsnippets({test = [[
            #include <cassert>
            void test() {
                RTCDevice device = rtcNewDevice(NULL);
                assert(device != NULL);
            }
        ]]}, {configs = {languages = "c++11"}, includes = includes}))
    end)
