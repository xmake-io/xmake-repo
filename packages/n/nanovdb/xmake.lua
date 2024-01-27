package("nanovdb")

    set_homepage("https://developer.nvidia.com/nanovdb")
    set_description("Developed by NVIDIA, NanoVDB adds real-time rendering GPU support for OpenVDB.")

    add_urls("https://github.com/AcademySoftwareFoundation/openvdb.git")
    add_versions("20201219", "9b79bb0dd66a442149083c8093deefcb03f881c3")

    add_deps("cmake")
    add_deps("cuda", "optix", {system = true})
    add_deps("openvdb")

    on_load("windows", function (package)
        package:add("defines", "_USE_MATH_DEFINES")
        package:add("defines", "NOMINMAX")
    end)

    on_install("macosx", "linux", "windows", function (package)
        os.cd("nanovdb")
        local configs = {"-DNANOVDB_BUILD_UNITTESTS=OFF", "-DNANOVDB_BUILD_EXAMPLES=OFF", "-DNANOVDB_BUILD_BENCHMARK=OFF", "-DOPENVDB_USE_STATIC_LIBS=ON", "-DBoost_USE_STATIC_LIBS=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        local optix = package:dep("optix"):fetch()
        table.insert(configs, "-DOptiX_ROOT=" .. path.directory(optix.sysincludedirs[1]))
        if package:is_plat("windows") then
            table.insert(configs, "-DBoost_USE_STATIC_RUNTIME=" .. ((package:config("runtimes") and package:has_runtime("MT", "MTd")) or (package:config("vs_config") and package:config("vs_config"):startswith("MT")) and "ON" or "OFF"))
            table.insert(configs, "-DCMAKE_CUDA_FLAGS_DEBUG=-Xcompiler /" .. package:config("vs_runtime"))
            table.insert(configs, "-DCMAKE_CUDA_FLAGS_RELEASE=-Xcompiler /" .. package:config("vs_runtime"))
        end
        import("package.tools.cmake").install(package, configs)
        os.mv(package:installdir("nanovdb"), package:installdir("include"))
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                nanovdb::GridBuilder<float> builder(0.0f);
                auto acc = builder.getAccessor();
                acc.setValue(nanovdb::Coord(1, 2, 3), 1.0f);
            }
        ]]}, {configs = {languages = "c++14"},
              includes = {"nanovdb/util/GridBuilder.h"}}))
    end)
