package("ozz-animation")
    set_homepage("http://guillaumeblanc.github.io/ozz-animation/")
    set_description("Open source c++ skeletal animation library and toolset")
    set_license("MIT")

    add_urls("https://github.com/guillaumeblanc/ozz-animation/archive/refs/tags/$(version).tar.gz",
             "https://github.com/guillaumeblanc/ozz-animation.git")

    add_versions("0.14.2", "52938e5a699b2c444dfeb2375facfbb7b1e3d405b424e361ad1a27391a53b89a")

    add_configs("fbx", {description = "Build Fbx pipeline (Requires Fbx SDK)", default = false, type = "boolean"})
    add_configs("gltf", {description = "Build glTF importer", default = false, type = "boolean"})
    add_configs("data", {description = "Build data on code change", default = false, type = "boolean"})
    add_configs("simd_ref", {description = "Force SIMD math reference implementation", default = false, type = "boolean"})
    add_configs("postfix", {description = "Use per config postfix name", default = false, type = "boolean"})

    add_deps("cmake")

    on_install(function (package)
        local configs =
        {
            "-Dozz_build_tools=OFF",
            "-Dozz_build_samples=OFF",
            "-Dozz_build_tests=OFF",
            "-Dozz_build_howtos=OFF",
            "-Dozz_run_tests_headless=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        for name, enabled in pairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") then
                table.insert(configs, "-Dozz_build_" .. name .. "=" .. (enabled and "ON" or "OFF"))
            end
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <ozz/animation/runtime/animation.h>
            void test() {
                auto x = ozz::animation::Animation();
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
