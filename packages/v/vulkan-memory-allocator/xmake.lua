package("vulkan-memory-allocator")
    set_kind("library", {headeronly = true})
    set_homepage("https://gpuopen-librariesandsdks.github.io/VulkanMemoryAllocator/html/")
    set_description("Easy to integrate Vulkan memory allocation library.")
    set_license("MIT")

    add_urls("https://github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator/archive/refs/tags/$(version).tar.gz",
             "https://github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator.git")
    add_versions("v3.0.0", 'dbb621a7a13fb70b8c34fef62fbe5128cc5193c7179c9edacead9f110df79a2f')

    add_deps("vulkan-headers")

    on_install("windows", "linux", "mingw", "macosx", "iphoneos", "android", function (package)
        os.cp("include/vk_mem_alloc.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test() {
                int version = VMA_VULKAN_VERSION;
            }
        ]]}, {includes = "vk_mem_alloc.h"}))
    end)

