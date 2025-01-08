package("vulkan-memory-allocator")
    set_kind("library", {headeronly = true})
    set_homepage("https://gpuopen-librariesandsdks.github.io/VulkanMemoryAllocator/html/")
    set_description("Easy to integrate Vulkan memory allocation library.")
    set_license("MIT")

    add_urls("https://github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator/archive/refs/tags/$(version).tar.gz",
             "https://github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator.git")
    add_versions("v3.0.0", 'dbb621a7a13fb70b8c34fef62fbe5128cc5193c7179c9edacead9f110df79a2f')
    add_versions("v3.0.1", '2a84762b2d10bf540b9dc1802a198aca8ad1f3d795a4ae144212c595696a360c')
    add_versions("v3.1.0", 'ae134ecc37c55634f108e926f85d5d887b670360e77cd107affaf3a9539595f2')
    add_versions("v3.2.0", 'e59a80307daa1d048e48f62bfee8c02e4a60180ca0d14b9b28181fc17eb36b07')

    add_deps("vulkan-headers")

    on_install("windows", "linux", "mingw", "macosx", "iphoneos", "android", "bsd", function (package)
        os.cp("include/vk_mem_alloc.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test() {
                int version = VMA_VULKAN_VERSION;
            }
        ]]}, {includes = "vk_mem_alloc.h"}))
    end)

