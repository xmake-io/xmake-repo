package("opensubdiv")

    set_homepage("https://graphics.pixar.com/opensubdiv/docs/intro.html")
    set_description("OpenSubdiv is a set of open source libraries that implement high performance subdivision surface (subdiv) evaluation on massively parallel CPU and GPU architectures.")
    set_license("Apache-2.0")

    add_urls("https://github.com/PixarAnimationStudios/OpenSubdiv/archive/refs/tags/v$(version).tar.gz", {version = function (version) return version:gsub("%.", "_") end})
    add_versions("3.4.4", "20d49f80a2b778ad4d01f091ad88d8c2f91cf6c7363940c6213241ce6f1048fb")
    add_versions("3.5.0", "8f5044f453b94162755131f77c08069004f25306fd6dc2192b6d49889efb8095")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_configs("glfw",   {description = "Enable components depending on GLFW.", default = true, type = "boolean"})
    add_configs("ptex",   {description = "Enable components depending on Ptex.", default = true, type = "boolean"})
    add_configs("tbb",    {description = "Enable components depending on TBB.", default = false, type = "boolean"})
    add_configs("openmp", {description = "Enable OpenMP backend.", default = false, type = "boolean"})
    add_configs("opencl", {description = "Enable OpenCL backend.", default = false, type = "boolean"})
    add_configs("cuda",   {description = "Enable CUDA backend.", default = false, type = "boolean"})

    add_deps("cmake")
    if is_plat("windows") then
        add_defines("NOMINMAX")
    end
    on_load("windows", "macosx", "linux", function (package)
        for _, dep in ipairs({"glfw", "ptex", "tbb"}) do
            if package:config(dep) then
                package:add("deps", dep)
            end
        end
        for _, dep in ipairs({"openmp", "opencl", "cuda"}) do
            if package:config(dep) then
                package:add("deps", dep, {system = true})
            end
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        local configs = {"-DNO_EXAMPLES=ON", "-DNO_TUTORIALS=ON", "-DNO_REGRESSION=ON", "-DNO_DOC=ON", "-DNO_CLEW=ON", "-DNO_TESTS=ON", "-DNO_GLTESTS=ON"}
        if package:config("glfw") then
            io.replace("cmake/FindGLFW.cmake", "NOT X11_xf86vmode_FOUND", "FALSE", {plain = true})
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        for _, dep in ipairs({"glfw", "ptex", "tbb", "opencl", "cuda"}) do
            table.insert(configs, "-DNO_" .. dep:upper() .. "=" .. (package:config(dep) and "OFF" or "ON"))
        end
        table.insert(configs, "-DNO_OMP=" .. (package:config("openmp") and "OFF" or "ON"))
        if package:is_plat("windows") then
            local vs_sdkver = import("core.tool.toolchain").load("msvc"):config("vs_sdkver")
            if vs_sdkver then
                local build_ver = string.match(vs_sdkver, "%d+%.%d+%.(%d+)%.?%d*")
                assert(tonumber(build_ver) >= 18362, "OpenSubDiv requires Windows SDK to be at least 10.0.18362.0")
                table.insert(configs, "-DCMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION=" .. vs_sdkver)
                table.insert(configs, "-DCMAKE_SYSTEM_VERSION=" .. vs_sdkver)
            end
            table.insert(configs, "-DMSVC_STATIC_CRT=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
        if package:config("shared") then
            os.tryrm(path.join(package:installdir("lib"), "lib*.a"))
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <opensubdiv/osd/glMesh.h>
            void test() {
                OpenSubdiv::Osd::MeshBitset bits;
                bits.set(OpenSubdiv::Osd::MeshAdaptive, true);
                bits.set(OpenSubdiv::Osd::MeshUseSingleCreasePatch, true);
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
