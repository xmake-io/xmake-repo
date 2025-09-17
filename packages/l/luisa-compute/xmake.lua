package("luisa-compute")
    set_homepage("https://luisa-render.com/")
    set_description("High-Performance Rendering Framework on Stream Architectures")
    set_license("Apache-2.0")

    add_urls("https://github.com/LuisaGroup/LuisaCompute.git")
    add_versions("2025.09.17", "2fc3ff3efaa792ac68fa8a5877f976ad8de5773d")

    add_configs("cuda", {description = "Enable CUDA backend", default = false, type = "boolean"})
    add_configs("vulkan", {description = "Enable Vulkan backend", default = false, type = "boolean"})
    add_configs("cpu", {description = "Enable CPU backend", default = false, type = "boolean"})
    add_configs("gui", {description = "Enable GUI support", default = false, type = "boolean"})
    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})

    if is_host("widnows") then
        set_policy("platform.longpaths", true)
    end

    add_includedirs("include", "include/luisa/ext")

    add_defines(
        "LUISA_USE_SYSTEM_SPDLOG=1",
        "LUISA_USE_SYSTEM_XXHASH=1",
        "LUISA_USE_SYSTEM_MAGIC_ENUM=1",
        "LUISA_USE_SYSTEM_STL=1",
        "LUISA_USE_SYSTEM_REPROC=1",
        "LUISA_USE_SYSTEM_YYJSON=1",
        "MARL_USE_SYSTEM_STL=1",
        "LUISA_USE_SYSTEM_MARL=1",
        "LUISA_USE_SYSTEM_LMDB=1",

        "LUISA_ENABLE_DSL=1",
        "LUISA_ENABLE_XIR=1"
    )
    if is_plat("windows") then
        add_defines("LUISA_PLATFORM_WINDOWS=1", "_DISABLE_CONSTEXPR_MUTEX_CONSTRUCTOR")
    elseif is_plat("macosx") then
        add_defines("LUISA_PLATFORM_APPLE=1")
    else
        add_defines("LUISA_PLATFORM_UNIX=1")
    end

    add_deps("cmake", "pkgconf")
    add_deps("spdlog", {configs = {header_only = false, fmt_external = true}})
    add_deps("lmdb", "reproc", "xxhash", "yyjson", "magic_enum", "marl")

    on_check(function (package)
        assert(package:is_arch64(), "package(luisa-compute) only support 64 bit")
    end)

    on_load(function (package)
        if package:config("gui") then
            package:add("deps", "glfw")
            package:add("defines", "LUISA_USE_SYSTEM_GLFW=1")
        end
        if package:config("cuda") then
            package:add("deps", "cuda")
        end
        if package:config("vulkan") then
            package:add("deps", "vulkansdk", "volk")
            package:add("defines", "LUISA_USE_SYSTEM_VULKAN=1")
        end
    end)

    on_install("windows|x64", "macosx", function (package)
        if package:has_tool("cxx", "cl") then
            package:add("cxflags", "/Zc:preprocessor", "/Zc:__cplusplus")
        end

        local configs = {
            "-DLUISA_COMPUTE_ENABLE_SCCACHE=OFF",
            "-DLUISA_COMPUTE_BUILD_TESTS=OFF",
            "-DLUISA_COMPUTE_ENABLE_UNITY_BUILD=ON",

            "-DLUISA_COMPUTE_USE_SYSTEM_LIBS=ON",

            "-DLUISA_COMPUTE_ENABLE_RUST=OFF",
            "-DLUISA_COMPUTE_ENABLE_REMOTE=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DLUISA_COMPUTE_ENABLE_LTO=" .. (package:config("lto") and "ON" or "OFF"))
        table.insert(configs, "-DLUISA_COMPUTE_ENABLE_SANITIZERS=" .. (package:config("asan") and "ON" or "OFF"))

        table.insert(configs, "-DLUISA_COMPUTE_ENABLE_CUDA=" .. (package:config("cuda") and "ON" or "OFF"))
        table.insert(configs, "-DLUISA_COMPUTE_ENABLE_VULKAN=" .. (package:config("vulkan") and "ON" or "OFF"))
        table.insert(configs, "-DLUISA_COMPUTE_ENABLE_CPU=" .. (package:config("cpu") and "ON" or "OFF"))
        table.insert(configs, "-DLUISA_COMPUTE_ENABLE_GUI=" .. (package:config("gui") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <luisa/luisa-compute.h>
            #include <luisa/dsl/sugar.h>

            void test(int argc, char *argv[]) {
                luisa::compute::Context context{argv[0]};
                luisa::compute::Device device = context.create_device("cuda");
                luisa::compute::Stream stream = device.create_stream();
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
