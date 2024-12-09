package("nanopb")
    set_homepage("https://jpa.kapsi.fi/nanopb/")
    set_description("Protocol Buffers with small code size")
    set_license("zlib")

    set_urls("https://github.com/nanopb/nanopb/archive/refs/tags/$(version).tar.gz",
             "https://github.com/nanopb/nanopb.git")

    add_versions("0.4.9", "524882ce9b6b8abeab3d458b9f15449c3f11d60c099eb388d8732d1bf2944eb3")

    add_configs("generator", {description = "Build the protoc plugin for code generation", default = false, type = "boolean"})

    add_deps("cmake", "protoc")

    on_load(function (package)
        if package:config("generator") then
            package:add("deps", "python 3.x", {kind = "binary"})
            package:addenv("PYTHONPATH", "lib/site-packages")
            package:add("patches", ">=0.4.9", "patches/0.4.9/nanopb_generator.patch", "40031727bac5719c2e98bdd2c2b7b05d58e649b8706087fea1b17413f171df72")
        end
    end)

    on_install(function (package)
        local configs = {
            "-Dnanopb_BUILD_RUNTIME=ON",
            "-Dnanopb_MSVC_STATIC_RUNTIME=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_STATIC_LIBS=" .. (package:config("shared") and "OFF" or "ON"))
        if package:config("shared") and package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end

        if package:config("generator") then
            table.insert(configs, "-Dnanopb_BUILD_GENERATOR=ON")
            table.insert(configs, "-Dnanopb_PYTHON_INSTDIR_OVERRIDE=" .. package:installdir("lib/site-packages"))
            if is_host("windows") then
                local python = package:dep("python")
                if python:is_system() then
                    table.insert(configs, "-DPython_EXECUTABLE=python")
                else
                    table.insert(configs, "-DPython_EXECUTABLE=" .. python:installdir("bin/python.exe"))
                end
            end
        else
            table.insert(configs, "-Dnanopb_BUILD_GENERATOR=OFF")
            table.insert(configs, "-Dnanopb_PYTHON_INSTDIR_OVERRIDE=.")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("pb_encode", {includes = "nanopb/pb_encode.h"}))
    end)
