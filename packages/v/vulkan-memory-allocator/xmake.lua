package("vulkan-memory-allocator")

    set_homepage("https://gpuopen-librariesandsdks.github.io/VulkanMemoryAllocator/html/")
    set_description("Easy to integrate Vulkan memory allocation library.")
    set_license("MIT")

    add_urls("https://github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator.git")
    add_versions("2021.1.26", "5bd597587352e111cf517f14b12bf4b70aa34b77")

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
