package("polyscope")

    set_homepage("https://polyscope.run/")
    set_description("A C++ & Python viewer for 3D data like meshes and point clouds")
    set_license("MIT")

    add_urls("https://github.com/nmwsharp/polyscope/archive/refs/tags/$(version).tar.gz",
             "https://github.com/nmwsharp/polyscope.git")
    add_versions("v1.3.0", "c0d3594b1c818c6e7efe2c2589d71f5e254db383d36a92555aa909a2114f12d4")

    add_patches("1.3.0", path.join(os.scriptdir(), "patches", "v1.3.0", "deps.patch"), "2d183713be791deddcfb48e4546793f584071eb1aa7a045e03c7ceed841470c8")
    add_patches("1.3.0", path.join(os.scriptdir(), "patches", "v1.3.0", "imgui.patch"), "e7865d6de85103098cdc25ab8a0e94dd26fb5f718609f20093b91891cc8f21e1")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")
    add_deps("imgui <=1.86", {configs = {glfw_opengl3 = true}})
    add_deps("glad", "glfw", "glm", "happly", "nlohmann_json", "stb")
    on_install("windows", "macosx", "linux", function (package)
        os.mv("deps/stb/stb_impl.cpp", "deps/stb_impl.cpp")
        local configs = {"-DPOLYSCOPE_BACKEND_OPENGL_MOCK=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs, {packagedeps = {"imgui", "glad", "glfw", "glm", "happly", "nlohmann_json", "stb"}})
        os.cp("include/polyscope", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <polyscope/polyscope.h>
            void test() {
                polyscope::init();
                polyscope::show();
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
