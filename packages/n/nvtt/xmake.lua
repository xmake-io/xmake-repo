package("nvtt")

    set_homepage("https://developer.nvidia.com/legacy-texture-tools")
    set_description("The NVIDIA Texture Tools is a collection of image processing and texture manipulation tools.")
    set_license("MIT")

    add_urls("https://github.com/castano/nvidia-texture-tools/archive/refs/tags/$(version).tar.gz",
             "https://github.com/castano/nvidia-texture-tools.git")
    add_versions("2.1.2", "0187336b0285038fab4f4a6b7654f51beaebab040b6aad53c147c917c5ab519b")

    add_patches("2.1.2", path.join(os.scriptdir(), "patches", "2.1.2", "build.patch"), "ed9b5884d6a644445bd1e3407a6575ca2a72b24a9edb9b01afe5f4f8e7272b8e")

    add_configs("cuda", {description = "Enable CUDA support.", default = false, type = "boolean"})

    add_deps("cmake")
    if is_plat("windows") then
        add_syslinks("user32")
    elseif is_plat("linux") then
        add_syslinks("pthread")
    end
    add_links("nvtt", "nvimage", "nvthread", "bc6h", "bc7", "nvmath", "nvcore", "nvsquish")
    on_load("windows", "macosx", "linux", function (package)
        if package:config("cuda") then
            package:add("deps", "cuda")
        end
        if not package:config("shared") or package:is_plat("windows") then
            package:add("linkdirs", "lib/static")
        end
        if package:config("shared") and package:is_plat("windows") then
            package:add("defines", "NVTT_SHARED=1")
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DNVTT_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_DISABLE_FIND_PACKAGE_CUDA=" .. (package:config("cuda") and "OFF" or "ON"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                nvtt::CompressionOptions o;
                o.setFormat(nvtt::Format_BC7);
            }
        ]]}, {configs = {languages = "c++11"}, includes = "nvtt/nvtt.h"}))
    end)
