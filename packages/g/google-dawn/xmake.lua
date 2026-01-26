package("google-dawn")
    set_homepage("https://dawn.googlesource.com/dawn")
    set_description("a WebGPU implementation")
    set_license("BSD-3-Clause")

    set_urls("https://github.com/google/dawn.git",
             "https://dawn.googlesource.com/dawn.git", {submodules = false})

    add_versions("2024.09.16", "8118e317875777203bb96cd489ecf8df68209de0")

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})

    if is_host("windows") then
        set_policy("platform.longpaths", true)
    end

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
        add_deps("libx11")
    end

    add_deps("cmake", "python 3.x", {kind = "binary"})
    add_deps("abseil", "spirv-tools")

    on_load(function (package)
        if package:config("shared") then
            package:add("defines", "WGPU_SHARED_LIBRARY", "DAWN_NATIVE_SHARED_LIBRARY")
        end
    end)

    on_install(function (package)
        local python = package:is_plat("windows") and "python" or "python3"
        os.vrun(python .. " -m pip install jinja2")

        import("patch")(package)
        local configs = import("configs").get(package)

        local packagedeps = {}
        if package:is_plat("linux", "bsd") then
            table.insert(packagedeps, "libx11")
        end
        import("package.tools.cmake").install(package, configs, {packagedeps = packagedeps})
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("wgpuCreateInstance", {includes = "dawn/webgpu.h"}))
    end)
