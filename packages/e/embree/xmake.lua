package("embree")

    set_homepage("https://www.embree.org/")
    set_description("Intel® Embree is a collection of high-performance ray tracing kernels, developed at Intel.")
    set_license("Apache-2.0")

    add_urls("https://github.com/embree/embree/archive/v$(version).tar.gz")
    add_versions("3.12.1", "0c9e760b06e178197dd29c9a54f08ff7b184b0487b5ba8b8be058e219e23336e")

    add_deps("cmake", "tbb")

    on_install("macosx", "linux", "windows", function (package)
        local configs = {"-DBUILD_TESTING=OFF", "-DBUILD_DOC=OFF", "-DEMBREE_TUTORIALS=OFF", "-DEMBREE_ISPC_SUPPORT=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        if package:is_plat("windows") then
            table.insert(configs, "-DUSE_STATIC_RUNTIME=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <cassert>
            void test() {
                RTCDevice device = rtcNewDevice(NULL);
                assert(device != NULL);
            }
        ]]}, {configs = {languages = "c++11"}, includes = "embree3/rtcore.h"}))
    end)
