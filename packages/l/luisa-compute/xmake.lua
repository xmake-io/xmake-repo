-- Usage
--[[
    add_requires("luisa-compute")

    set_languages("c++20")

    target("test")
        set_kind("binary")
        add_files("src/main.cpp")
        add_packages("luisa-compute")

        on_config(function (target)
            -- Context require a path to find backend shared libraries
            -- Context context{argv[1]};
            target:add("runargs", path.join(target:pkg("luisa-compute"):installdir(), "bin"))
            -- -- Use target:targetdir() path
            -- -- Context context{argv[0]};
            -- os.vcp(path.join(target:pkg("luisa-compute"):installdir(), "bin/*.dll"), target:targetdir())
        end)
--]]

package("luisa-compute")
    set_homepage("https://luisa-render.com/")
    set_description("High-Performance Rendering Framework on Stream Architectures")
    set_license("Apache-2.0")

    add_urls("https://github.com/LuisaGroup/LuisaCompute.git", {submodules = false})
    add_versions("2025.11.05", "f363db428873120924880e28d3a284202edb237a")

    add_configs("cuda", {description = "Enable CUDA backend", default = false, type = "boolean"})
    add_configs("vulkan", {description = "Enable Vulkan backend", default = false, type = "boolean"})
    add_configs("cpu", {description = "Enable CPU backend", default = false, type = "boolean"})
    add_configs("gui", {description = "Enable GUI support", default = false, type = "boolean"})
    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})

    if is_host("windows") then
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

    if is_plat("linux") then
        add_links("luisa-xir", "luisa-dsl", "luisa-runtime", "luisa-ast", "luisa-osl", "luisa-core", "luisa-ext-volk")
    end

    add_deps("cmake", "pkgconf")
    add_deps("spdlog", {configs = {header_only = false, fmt_external = true}})
    add_deps("lmdb", "reproc", "xxhash", "yyjson", "magic_enum", "marl", "stb") -- TODO: half
    if is_plat("linux") then
        add_deps("libuuid")
    end

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
            package:add("deps", "vulkansdk")
            package:add("defines", "LUISA_USE_SYSTEM_VULKAN=1")
        end
    end)

    on_install("windows|x64", "linux", "macosx", function (package)
        if package:has_tool("cxx", "cl") then
            package:add("cxflags", "/Zc:preprocessor", "/Zc:__cplusplus")
        end

        local configs = {
            "-DLUISA_COMPUTE_ENABLE_SCCACHE=OFF",
            "-DLUISA_COMPUTE_BUILD_TESTS=OFF",

            "-DLUISA_COMPUTE_USE_SYSTEM_LIBS=ON",

            "-DLUISA_COMPUTE_ENABLE_RUST=OFF",
            "-DLUISA_COMPUTE_ENABLE_REMOTE=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DLUISA_COMPUTE_ENABLE_UNITY_BUILD=" .. (not package:is_plat("linux") and "ON" or "OFF"))
        table.insert(configs, "-DLUISA_COMPUTE_ENABLE_LTO=" .. (package:config("lto") and "ON" or "OFF"))
        table.insert(configs, "-DLUISA_COMPUTE_ENABLE_SANITIZERS=" .. (package:config("asan") and "ON" or "OFF"))
        if package:is_plat("windows") and package:is_debug() then
            -- xmake default flags will break unity build
            table.insert(configs, "-DCMAKE_COMPILE_PDB_OUTPUT_DIRECTORY=")
        end

        table.insert(configs, "-DLUISA_COMPUTE_ENABLE_CUDA=" .. (package:config("cuda") and "ON" or "OFF"))
        table.insert(configs, "-DLUISA_COMPUTE_ENABLE_VULKAN=" .. (package:config("vulkan") and "ON" or "OFF"))
        table.insert(configs, "-DLUISA_COMPUTE_ENABLE_CPU=" .. (package:config("cpu") and "ON" or "OFF"))
        table.insert(configs, "-DLUISA_COMPUTE_ENABLE_GUI=" .. (package:config("gui") and "ON" or "OFF"))

        os.vcp(package:dep("stb"):installdir("include/stb"), "src/ext/stb/")
        import("package.tools.cmake").install(package, configs)

        if package:is_plat("windows") and package:is_debug() then
            local dir = package.builddir and package:builddir() or package:buildir()
            os.vcp(path.join(dir, "lib/*.pdb"), package:installdir("bin"))
        end
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
