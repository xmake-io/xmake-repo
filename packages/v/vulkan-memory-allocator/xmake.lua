package("vulkan-memory-allocator")

    set_homepage("https://gpuopen-librariesandsdks.github.io/VulkanMemoryAllocator/html/")
    set_description("Easy to integrate Vulkan memory allocation library.")
    set_license("MIT")

    add_urls("https://github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator/archive/$(version).tar.gz")
    add_versions("v2.3.0", "fc41221f72f16ec1f8a9550fc36a0d73921f7f347ee804af7c948f3184f60242")

    add_deps("vulkan-headers")

    on_install("windows", "linux", "macosx", function (package) 
        os.cp("src/vk_mem_alloc.h", package:installdir("include"))
    end)

    on_test(function (package) 
        assert(package:check_csnippets({test = [[
            void test() {
                int version = VMA_VULKAN_VERSION;
            }
        ]]}, {includes = "vk_mem_alloc.h"}))
    end)