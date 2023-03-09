package("vulkan-memory-allocator")
    set_kind("library")
    set_homepage("https://gpuopen-librariesandsdks.github.io/VulkanMemoryAllocator/html/")
    set_description("Easy to integrate Vulkan memory allocation library.")
    set_license("MIT")

    add_urls("https://github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator/archive/refs/tags/$(version).tar.gz",
             "https://github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator.git")
    add_versions("v3.0.0", 'dbb621a7a13fb70b8c34fef62fbe5128cc5193c7179c9edacead9f110df79a2f')
    add_versions("v3.0.1", '2a84762b2d10bf540b9dc1802a198aca8ad1f3d795a4ae144212c595696a360c')

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean"})

    add_deps("vulkan-headers", "cmake")
    
    on_install("windows", "linux", "mingw", "macosx", "iphoneos", "android", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test() {
                int version = VMA_VULKAN_VERSION;
            }
        ]]}, {includes = "vk_mem_alloc.h"}))
    end)

