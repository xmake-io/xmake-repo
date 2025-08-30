package("poselib")
    set_homepage("https://github.com/PoseLib/PoseLib")
    set_description("Minimal solvers for calibrated camera pose estimation")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/PoseLib/PoseLib/archive/refs/tags/$(version).tar.gz",
             "https://github.com/PoseLib/PoseLib.git")

    add_versions("v2.0.5", "a9493e6725c58e6ae541fe416c0a6179185a60006880ff3ddf32737a43695668")
    add_versions("v2.0.4", "caa0c1c9b882f6e36b5ced6f781406ed97d4c1f0f61aa31345ebe54633d67c16")

    -- https://github.com/PoseLib/PoseLib/issues/157
    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")
    add_deps("eigen")

    on_install("!wasm and (!windows or windows|!arm64)", function (package)
        io.replace("CMakeLists.txt", "-march=native", "", {plain = true})
        io.replace("CMakeLists.txt", "-Wall -Werror -fPIC", "", {plain = true})

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:config("shared") and package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                std::vector<Eigen::Vector3d> x1(10, Eigen::Vector3d{});
                std::vector<Eigen::Vector3d> x2(10, Eigen::Vector3d{});
                Eigen::Matrix3d h;
                int res = poselib::homography_4pt(x1, x2, &h);
            }
        ]]}, {configs = {languages = "c++17"}, includes = "PoseLib/poselib.h"}))
    end)
