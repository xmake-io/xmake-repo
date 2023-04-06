package("vulkan-memory-allocator-hpp")
    set_kind("library", {headeronly = true})
    set_homepage("https://gpuopen-librariesandsdks.github.io/VulkanMemoryAllocator/html/")
    set_description("C++ bindings for VulkanMemoryAllocator.")
    set_license("CC0")

    add_urls("https://github.com/YaaZ/VulkanMemoryAllocator-Hpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/YaaZ/VulkanMemoryAllocator-Hpp.git")
    add_versions("v3.0.0", '2f062b1631af64519d09e7b319c2ba06d7de3c9c5589fb7109a3f4e341cee2b7')
    add_versions("v3.0.1-1", '0e0c374751d5ca6123d0ae0df756693f0674412d7c758ec4a39a5a9dcc412911')

    add_deps("vulkan-memory-allocator")

    on_install("windows|x86", "windows|x64", "linux", "macosx", "mingw", "android", "iphoneos", function (package)
        os.cp("include", package:installdir())
        if package:gitref() or package:version():ge("3.0.1") then
            package:add("deps", "vulkan-hpp >= 1.3.234")
        else
            package:add("deps", "vulkan-hpp < 1.3.234")
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                int version = VMA_VULKAN_VERSION;
            }
        ]]}, {includes = "vk_mem_alloc.hpp", configs = {languages = "c++11"} }))
    end)
