package("daxa")
    set_homepage("https://github.com/Ipotrick/Daxa")
    set_description("Daxa is a convenient, simple and modern gpu api built on vulkan")
    set_license("MIT")

    add_urls("https://github.com/Ipotrick/Daxa/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Ipotrick/Daxa.git")

    add_versions("3.5", "e5c257a945cbd06a11031cf69fc887d59504777d9d127d8b6f9705ec6bdc08c7")

    add_configs("imgui", {description = "The ImGUI Daxa utility", default = true, type = "boolean"})
    add_configs("mem", {description = "The Mem Daxa utility", default = true, type = "boolean"})
    add_configs("glslang", {description = "Build with glslang", default = true, type = "boolean"})
    add_configs("slang", {description = "Build with Slang", default = false, type = "boolean"})
    add_configs("spirv-validation", {description = "Build with SPIR-V validation", default = true, type = "boolean"})
    add_configs("task-graph", {description = "The Task-Graph Daxa utility", default = true, type = "boolean"})

    add_deps("cmake")
    add_deps("vulkan-headers", "vulkan-loader", "vulkan-memory-allocator")

    on_load(function (package)
        if package:config("imgui") then
            package:add("deps", "imgui v1.91.8-docking", "implot")
            package:add("defines", "DAXA_BUILT_WITH_UTILS_IMGUI=1")
        end
        if package:config("mem") then
            package:add("defines", "DAXA_BUILT_WITH_UTILS_MEM=1")
        end
        if package:config("glslang") then
            package:add("deps", "glslang")
            package:add("defines", "DAXA_BUILT_WITH_UTILS_PIPELINE_MANAGER_GLSLANG=1")
        end
        if package:config("spirv-validation") then
            package:add("deps", "spirv-tools")
            package:add("defines", "DAXA_BUILT_WITH_UTILS_PIPELINE_MANAGER_SPIRV_VALIDATION=1")
        end
        if package:config("slang") then
            package:add("deps", "slang")
            package:add("defines", "DAXA_BUILT_WITH_UTILS_PIPELINE_MANAGER_SLANG=1")
        end
        if package:config("task-graph") then
            package:add("defines", "DAXA_BUILT_WITH_UTILS_TASK_GRAPH=1")
        end
        if package:is_plat("linux", "bsd") then
            package:add("deps", "pkgconf", "libx11", "wayland", "libxkbcommon")
            package:add("defines", "DAXA_BUILT_WITH_X11=1", "DAXA_BUILT_WITH_WAYLAND=1")
        end
        if package:is_plat("windows") then
            if package:config("shared") then
                package:add("defines", "DAXA_CMAKE_EXPORT=__declspec(dllimport)", "DAXA_EXPORT=DAXA_CMAKE_EXPORT")
            else
                package:add("defines", "DAXA_CMAKE_EXPORT=", "DAXA_EXPORT=DAXA_CMAKE_EXPORT")
            end
        end
    end)

    on_install("windows", "linux", "macosx", function (package)
        -- GCC 15 changed uint64_t from unsigned long to unsigned long long on some platforms,
        -- causing ull/ll literals to mismatch u64/i64 in template deduction.
        -- Also: imgui 1.91.x changed ImTextureID from void* to ImU64.
        io.replace("src/impl_swapchain.cpp",
            "std::max(0ll, self->cpu_frame_timeline)",
            "std::max(i64{0}, self->cpu_frame_timeline)", {plain = true})
        io.replace("src/utils/impl_task_graph_mk2.cpp",
            "auto transient_heap_size = 0ull;",
            "VkDeviceSize transient_heap_size = 0;", {plain = true})
        io.replace("src/utils/impl_task_graph_mk2.cpp",
            "auto transient_heap_alignment = 0ull;",
            "VkDeviceSize transient_heap_alignment = 0;", {plain = true})
        -- align_up(current_offset, sizeof(X)): current_offset is u64, sizeof is size_t
        io.replace("src/utils/impl_task_graph_mk2.cpp",
            "align_up(current_offset,",
            "align_up<u64>(current_offset,", {plain = true})
        -- std::min(actual_size, cinfo.size): usize vs u64 deduction conflict
        io.replace("src/utils/impl_task_graph_mk2.cpp",
            "std::min(actual_size, cinfo.size)",
            "std::min<u64>(actual_size, cinfo.size)", {plain = true})
        io.replace("src/utils/impl_task_graph_ui.cpp",
            "std::min(255ull, resource.name.size())",
            "std::min<size_t>(255, resource.name.size())", {plain = true})
        io.replace("src/utils/impl_task_graph_ui.cpp",
            "std::min(255ull, task.name.size())",
            "std::min<size_t>(255, task.name.size())", {plain = true})
        io.replace("src/utils/impl_resource_viewer.cpp",
            "std::min(work_code.size(), 20ull)",
            "std::min(work_code.size(), size_t{20})", {plain = true})
        -- ImTextureID changed from void* to ImU64 (unsigned long long) in imgui 1.91.x
        io.replace("src/utils/impl_resource_viewer.hpp",
            "void * imgui_image_id = {};",
            "unsigned long long imgui_image_id = {};", {plain = true})

        io.replace("CMakeLists.txt",
            "pkg_check_modules(WAYLAND_CLIENT wayland-client)",
            "pkg_check_modules(WAYLAND_CLIENT IMPORTED_TARGET wayland-client)", {plain = true})
        io.replace("CMakeLists.txt",
            "pkg_check_modules(WAYLAND_CURSOR wayland-cursor)",
            "pkg_check_modules(WAYLAND_CURSOR IMPORTED_TARGET wayland-cursor)", {plain = true})
        io.replace("CMakeLists.txt",
            "pkg_check_modules(WAYLAND_EGL wayland-egl)",
            "pkg_check_modules(WAYLAND_EGL IMPORTED_TARGET wayland-egl)", {plain = true})
        io.replace("CMakeLists.txt",
            "pkg_check_modules(XKBCOMMON xkbcommon)",
            "pkg_check_modules(XKBCOMMON IMPORTED_TARGET xkbcommon)", {plain = true})
        io.replace("CMakeLists.txt", [[
                    ${WAYLAND_CLIENT_INCLUDE_DIRS}
                    ${WAYLAND_CURSOR_INCLUDE_DIRS}
                    ${WAYLAND_EGL_INCLUDE_DIRS}
                    ${XKBCOMMON_INCLUDE_DIRS}]], "", {plain = true})
        io.replace("CMakeLists.txt", [[
                    ${WAYLAND_CLIENT_LIBRARIES}
                    ${WAYLAND_CURSOR_LIBRARIES}
                    ${WAYLAND_EGL_LIBRARIES}
                    ${XKBCOMMON_LIBRARIES}]], [[
                    PkgConfig::WAYLAND_CLIENT
                    PkgConfig::WAYLAND_CURSOR
                    PkgConfig::WAYLAND_EGL
                    PkgConfig::XKBCOMMON]], {plain = true})

        io.writefile("cmake/deps.cmake", [[
find_package(Vulkan REQUIRED)

# VMA - header-only, no cmake config: create INTERFACE target from installed headers
find_path(VMA_INCLUDE_DIR "vk_mem_alloc.h" REQUIRED)
if(NOT TARGET GPUOpen::VulkanMemoryAllocator)
    add_library(GPUOpen::VulkanMemoryAllocator INTERFACE IMPORTED)
    target_include_directories(GPUOpen::VulkanMemoryAllocator INTERFACE "${VMA_INCLUDE_DIR}")
endif()

if(DAXA_ENABLE_UTILS_PIPELINE_MANAGER_GLSLANG AND NOT TARGET glslang::glslang)
    find_package(glslang CONFIG REQUIRED)
endif()

if(DAXA_ENABLE_UTILS_IMGUI AND NOT TARGET imgui::imgui)
    find_package(imgui CONFIG REQUIRED)
    # implot has no cmake config - create STATIC IMPORTED target manually
    find_path(IMPLOT_INCLUDE_DIR "implot.h" REQUIRED)
    find_library(IMPLOT_LIBRARY "implot" REQUIRED)
    if(NOT TARGET implot::implot)
        add_library(implot::implot STATIC IMPORTED)
        set_target_properties(implot::implot PROPERTIES
            IMPORTED_LOCATION "${IMPLOT_LIBRARY}"
            INTERFACE_INCLUDE_DIRECTORIES "${IMPLOT_INCLUDE_DIR}"
        )
        target_link_libraries(implot::implot INTERFACE imgui::imgui)
    endif()
endif()

if(DAXA_ENABLE_UTILS_PIPELINE_MANAGER_SPIRV_VALIDATION)
    find_package(SPIRV-Tools CONFIG REQUIRED)
    # If that target is absent, wrap the shared target under the expected name.
    if(NOT TARGET SPIRV-Tools-static AND TARGET SPIRV-Tools)
        add_library(SPIRV-Tools-static INTERFACE IMPORTED)
        target_link_libraries(SPIRV-Tools-static INTERFACE SPIRV-Tools)
    endif()
endif()

if(DAXA_ENABLE_UTILS_PIPELINE_MANAGER_SLANG AND NOT TARGET slang::slang)
    find_package(slang CONFIG REQUIRED)
endif()
]])
        local configs = {"-DDAXA_ENABLE_STATIC_ANALYSIS=OFF", "-DDAXA_ENABLE_TESTS=OFF"}
        if package:is_plat("windows") then
            table.insert(configs, "-DDAXA_USE_STATIC_CRT=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DDAXA_ENABLE_UTILS_IMGUI=" .. (package:config("imgui") and "ON" or "OFF"))
        table.insert(configs, "-DDAXA_ENABLE_UTILS_MEM=" .. (package:config("mem") and "ON" or "OFF"))
        table.insert(configs, "-DDAXA_ENABLE_UTILS_PIPELINE_MANAGER_GLSLANG=" .. (package:config("glslang") and "ON" or "OFF"))
        table.insert(configs, "-DDAXA_ENABLE_UTILS_PIPELINE_MANAGER_SLANG=" .. (package:config("slang") and "ON" or "OFF"))
        table.insert(configs, "-DDAXA_ENABLE_UTILS_PIPELINE_MANAGER_SPIRV_VALIDATION=" .. (package:config("spirv-validation") and "ON" or "OFF"))
        table.insert(configs, "-DDAXA_ENABLE_UTILS_TASK_GRAPH=" .. (package:config("task-graph") and "ON" or "OFF"))
        import("package.tools.cmake").build(package, configs)
        os.cp("include", package:installdir())
        os.trycp("**.a", package:installdir("lib"))
        os.trycp("**.dylib", package:installdir("lib"))
        os.trycp("**.so", package:installdir("lib"))
        os.trycp("**.lib", package:installdir("lib"))
        os.trycp("**.dll", package:installdir("bin"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                daxa::Instance instance = daxa::create_instance({});
            }
        ]]}, {configs = {languages = "c++20"}, includes = "daxa/daxa.hpp"}))
    end)
