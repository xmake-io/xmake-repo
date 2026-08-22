package("polyscope")
    set_homepage("https://polyscope.run/")
    set_description("A C++ & Python viewer for 3D data like meshes and point clouds")
    set_license("MIT")

    add_urls("https://github.com/nmwsharp/polyscope/archive/refs/tags/$(version).tar.gz",
             "https://github.com/nmwsharp/polyscope.git")

    add_versions("v2.5.0", "419a1eaa204dedc29ef67bff05c0a387c9c859ec4fe55fdba63390dac353fd4f")
    add_versions("v2.4.0", "bd240ab00797901c3ae9a789bf944e4023127ff7066cc12daf0402285409afbd")
    add_versions("v2.3", "2f57d6d206aa69d277858f046f4db08d27f03c10e97d691a0c3fc9e221a0cd60")
    add_versions("v2.2.1", "1952d20722cb37c5531e88d5b7f5db88c2827c55fd7ada481c2ac425f3bc4d25")
    add_versions("v2.1.0", "bdad2daab33a44b3b6424cec82b43cecb842b529769fd0df3bf7d8e616cea34c")
    add_versions("v1.3.0", "c0d3594b1c818c6e7efe2c2589d71f5e254db383d36a92555aa909a2114f12d4")

    add_patches(">=2.2.1", "patches/v2.2.1/deps.patch", "7183fac6dcb6ebc9441c02e4c5f51721ab2a64fe524488611e6085e5b72bb6ae")
    add_patches("2.1.0", "patches/v2.1.0/deps.patch", "01bc0b31193e65b8cc079d9f232f73fb995b3cfd276840add58a01dfcf477cc8")
    add_patches("1.3.0", "patches/v1.3.0/deps.patch", "2d183713be791deddcfb48e4546793f584071eb1aa7a045e03c7ceed841470c8")
    add_patches("1.3.0", "patches/v1.3.0/imgui.patch", "e7865d6de85103098cdc25ab8a0e94dd26fb5f718609f20093b91891cc8f21e1")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")
    add_deps("glad", "glfw", "glm <=1.0.1", "nlohmann_json", "stb")
    on_load("windows", "macosx", "linux", function (package)
        local version = package:version()
        local cfgs = {glfw = true, opengl3 = true}
        local is_shared = package:config("shared")
        if version and version:ge("2.5.0") then
            if is_shared then
                package:add("deps", "implot", {configs = {shared = true}})
            else
                package:add("deps", "implot")
            end
            package:add("deps", "imgui <1.91", {configs = cfgs})
        elseif version and version:ge("2.2.0") then
            package:add("deps", "imgui <=1.90.4", {configs = cfgs})
        else
            package:add("deps", "happly", "imgui <=1.86", {configs = cfgs})
        end
        package:add("defines", "GLM_ENABLE_EXPERIMENTAL")
    end)

    on_install("windows", "macosx", "linux", function (package)
        os.cp("deps/stb/stb_impl.cpp", "deps/stb_impl.cpp")
        local configs = {"-DPOLYSCOPE_BACKEND_OPENGL_MOCK=OFF", "-DPOLYSCOPE_BACKEND_OPENGL3_EGL=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        local version = package:version()
        local opt = {}
        local packagedeps = {"imgui", "glad", "glfw", "glm", "nlohmann_json", "stb"}
        if version and version:ge("2.5.0") then
            table.insert(packagedeps, 1, "implot")
        elseif not version or version:lt("2.2.0") then
            table.insert(packagedeps, "happly")
        end
        opt.packagedeps = packagedeps
        import("package.tools.cmake").install(package, configs, opt)

        if version and version:lt("2.2.0") then
            os.cp("include/polyscope", package:installdir("include"))
        end
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
