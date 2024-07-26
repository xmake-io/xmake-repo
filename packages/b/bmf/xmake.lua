package("bmf")
    set_homepage("https://babitmf.github.io/")
    set_description("Cross-platform, customizable multimedia/video processing framework.  With strong GPU acceleration, heterogeneous design, multi-language support, easy to use, multi-framework compatible and high performance, the framework is ideal for transcoding, AI inference, algorithm integration, live video streaming, and more.")
    set_license("Apache-2.0")

    add_urls("https://github.com/star-hengxing/bmf/archive/refs/heads/windows-support.zip")
    add_versions("v0.0.10", "424918fb8c45406db4c10c1cf5307339f8368e9ecac6513dba37be45b65f5d44")

    add_configs("breakpad", {description = "Enable build with breakpad support", default = false, type = "boolean"})
    add_configs("cuda", {description = "Enable CUDA support", default = false, type = "boolean"})
    add_configs("glog", {description = "Enable build with glog support", default = false, type = "boolean"})
    add_configs("ffmpeg", {description = "Enable build with ffmpeg support", default = false, type = "boolean"})
    add_configs("mobile", {description = "Enable build for mobile platform", default = false, type = "boolean"})
    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})

    add_deps("cmake")
    add_deps("nlohmann_json", {configs = {cmake = true}})
    add_deps("spdlog", {configs = {header_only = false, fmt_external = true}})
    add_deps("dlpack", "backward-cpp")

    if is_plat("windows") then
        add_deps("dlfcn-win32")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread", "dl")
    end
    
    on_check("windows", function (package)
        local vs_toolset = package:toolchain("msvc"):config("vs_toolset")
        if vs_toolset then
            local vs_toolset_ver = import("core.base.semver").new(vs_toolset)
            local minor = vs_toolset_ver:minor()
            assert(minor and minor >= 30, "package(bmf): Only support >= v143 toolset")
        end
    end)

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
            package:add("deps", "ffmpeg >=4.0.0 <5.1.0")
        end
        if package:config("mobile") then
            package:add("deps", "benchmark")
        end

        if package:has_tool("cxx", "cl") then
            package:add("cxxflags", "/Zc:preprocessor")
        end
    end)

    on_install("windows", "linux", function (package)
        local configs = {
            "-DBMF_LOCAL_DEPENDENCIES=OFF",
            "-DBMF_ENABLE_PYTHON=OFF",
            "-DBMF_ENABLE_TEST=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        local ver = package:version() or "0.0.10"
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

        os.cp(path.join(package:buildir(), "output/bmf/include"), package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                bmf_sdk::AudioFrame x(0, 0);
            }
        ]]}, {configs = {languages = "c++20"}, includes = "bmf/sdk/audio_frame.h"}))
    end)
