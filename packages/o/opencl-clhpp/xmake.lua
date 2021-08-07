package("opencl-clhpp")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/KhronosGroup/OpenCL-CLHPP/")
    set_description("OpenCL API C++ bindings")
    set_license("Apache-2.0")

    add_urls("https://github.com/KhronosGroup/OpenCL-$(version)", {version = function (version)
        if version:ge("2.0") then
            return "CLHPP/archive/refs/tags/v" .. version .. ".tar.gz"
        else
            return "Registry.git"
        end
    end})
    add_versions("2.0.15", "0175806508abc699586fc9a9387e01eb37bf812ca534e3b493ff3091ec2a9246")
    add_versions("1.2.8", "2a35cdc00e31234fa8e5306adc61d8944a810c90")

    add_deps("opencl", {system = true})

    on_install(function (package)
        if package:version():ge("2.0") then
            os.cp("include/CL", package:installdir("include"))
        else
            os.cp("api/2.1/cl.hpp", package:installdir("include", "CL"))
        end
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("cl::Platform", {configs = {languages = "c++14"}, includes = (package:version():ge("2.0") and "CL/opencl.hpp" or "CL/cl.hpp")}))
    end)
