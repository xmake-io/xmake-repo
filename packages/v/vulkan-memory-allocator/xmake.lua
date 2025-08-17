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
    add_versions("v3.2.1", '5e7749504cb802427ffb7bec38a0b6a15db46ae253f00560acb3e624d9fe695c')
    add_versions("v3.3.0", 'c4f6bbe6b5a45c2eb610ca9d231158e313086d5b1a40c9922cb42b597419b14e')

    add_deps("vulkan-headers")

    on_load(function (package)
        if package:version() and package:version():ge("3.1.0") then
            package:add("deps", "cmake")
        end
    end)

    on_install("!cross and !wasm", function (package)
        if package:version() and package:version():ge("3.1.0") then
            local configs = {"-DVMA_BUILD_DOCUMENTATION=OFF", "-DVMA_BUILD_SAMPLES=OFF", "-DVMA_ENABLE_INSTALL=ON"}
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
            table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
            import("package.tools.cmake").install(package, configs)
        else
            os.cp("include/vk_mem_alloc.h", package:installdir("include"))
        end
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test() {
                int version = VMA_VULKAN_VERSION;
            }
        ]]}, {includes = "vk_mem_alloc.h"}))
    end)

