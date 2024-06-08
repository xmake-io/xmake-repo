package("bmf")
    set_homepage("https://babitmf.github.io/")
    set_description("Cross-platform, customizable multimedia/video processing framework.  With strong GPU acceleration, heterogeneous design, multi-language support, easy to use, multi-framework compatible and high performance, the framework is ideal for transcoding, AI inference, algorithm integration, live video streaming, and more.")
    set_license("Apache-2.0")

    add_urls("https://github.com/BabitMF/bmf/archive/refs/tags/$(version).tar.gz",
             "https://github.com/BabitMF/bmf.git")

    add_versions("v0.0.10", "9d24fc909a626730518dc8f9f4dc02d76345ea38445166b116b3f10ef9adb691")

    add_configs("breakpad", {description = "Enable build with breakpad support", default = false, type = "boolean"})
    add_configs("cuda", {description = "Enable CUDA support", default = false, type = "boolean"})
    add_configs("glog", {description = "Enable build with glog support", default = false, type = "boolean"})
    add_configs("ffmpeg", {description = "Enable build with ffmpeg support", default = false, type = "boolean"})
    add_configs("mobile", {description = "Enable build for mobile platform", default = false, type = "boolean"})

    add_deps("cmake")
    add_deps("nlohmann_json", {configs = {cmake = true}})
    add_deps("spdlog", {configs = {header_only = false}})
    add_deps("fmt <=8.0.0", "dlpack", "backward-cpp")
    if is_plat("windows") then
        add_deps("dlfcn-win32")
    elseif is_plat("linux") then
        add_syslinks("pthread")
    end

    on_load(function (package)
        if package:config("breakpad") then
            package:add("deps", "breakpad")
        end
        if package:config("cuda") then
            package:add("deps", "cuda")
        end
        if package:config("glog") then
            package:add("deps", "glog")
        end
        if package:config("ffmpeg") then
            package:add("deps", "ffmpeg")
        end
    end)

    on_install("!windows", function (package)
        io.replace("cmake/dependencies.cmake", "find_package(pybind11 REQUIRED)", "", {plain = true})
        io.replace("bmf/hml/cmake/dependencies.cmake", "find_package(GTest REQUIRED)", "", {plain = true})
        io.replace("bmf/hml/cmake/dependencies.cmake", "add_library(gtest ALIAS GTest::gtest)", "", {plain = true})
        io.replace("bmf/hml/cmake/dependencies.cmake", "add_library(gtest_main ALIAS GTest::gtest_main)", "", {plain = true})
        io.replace("bmf/hml/cmake/dependencies.cmake", "find_package(benchmark REQUIRED)", "", {plain = true})
        -- io.replace("bmf/hml/src/core/logging.cpp", "backward.hpp", "backward/backward.hpp", {plain = true})

        if package:is_plat("windows") then
            for _, file in ipairs(os.files("bmf/**.cpp", "bmf/**.h")) do
                io.replace(file, "#include <unistd.h>", "", {plain = true})
            end
        end

        local configs = {
            "-DBMF_LOCAL_DEPENDENCIES=OFF",
            "-DBMF_ENABLE_PYTHON=OFF",
            "-DBMF_ENABLE_TEST=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        local ver = package:version()
        if ver then
            table.insert(configs, "-DBMF_BUILD_VERSION=" .. ver)
        end

        table.insert(configs, "-DBMF_ENABLE_BREAKPAD=" .. (package:config("breakpad") and "ON" or "OFF"))
        table.insert(configs, "-DBMF_ENABLE_CUDA=" .. (package:config("cuda") and "ON" or "OFF"))
        table.insert(configs, "-DBMF_ENABLE_GLOG=" .. (package:config("glog") and "ON" or "OFF"))
        table.insert(configs, "-DBMF_ENABLE_FFMPEG=" .. (package:config("ffmpeg") and "ON" or "OFF"))
        table.insert(configs, "-DBMF_ENABLE_MOBILE=" .. (package:config("mobile") and "ON" or "OFF"))

        local envs = import("package.tools.cmake").buildenvs(package)
        if package:is_plat("windows") then
            envs.SCRIPT_EXEC_MODE = "win"
        end
        import("package.tools.cmake").install(package, configs, {envs = envs})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <audio_frame.h>
            void test() {
                AudioFrame x();
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
