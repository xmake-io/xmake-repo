package("vexcl")

    set_homepage("https://github.com/ddemidov/vexcl")
    set_description("VexCL is a C++ vector expression template library for OpenCL/CUDA/OpenMP")
    set_license("MIT")

    add_urls("https://github.com/ddemidov/vexcl/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ddemidov/vexcl.git")
    add_versions("1.4.3", "c9f2a429dc4454e69332cc8b7fbaa5adcd831bce1267fcc1f19e1c110d82deb8")
    add_versions("1.4.2", "3a2be30e303c4f44a269ca85de48f1a628127012f18abee0aa82c0c2cbb0e0c8")

    add_deps("cmake")
    add_deps("opencl-clhpp 1.x")
    add_deps("opencl", {system = true})
    add_deps("boost", {configs = {filesystem = true,
                                  date_time = true,
                                  program_options = true,
                                  system = true,
                                  thread = true,
                                  test = true}})

    if is_plat("windows") then
        add_defines("NOMINMAX")
    end

    on_install("windows", "linux", "macosx", function (package)
        local configs = {"-DVEXCL_BUILD_TESTS=OFF", "-DVEXCL_BUILD_EXAMPLES=OFF", "-DBoost_USE_STATIC_LIBS=ON"}
        if package:is_plat("windows") then
            table.insert(configs, "-DBoost_USE_STATIC_RUNTIME=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                auto dev = vex::backend::device_list(vex::Filter::Any);
            }
        ]]}, {configs = {languages = "c++17"}, includes = "vexcl/devlist.hpp"}))
    end)
