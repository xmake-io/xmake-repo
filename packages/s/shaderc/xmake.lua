package("shaderc")

    set_homepage("https://github.com/google/shaderc")
    set_description("A collection of tools, libraries, and tests for Vulkan shader compilation.")
    set_license("Apache-2.0")

    add_urls("https://github.com/google/shaderc.git")
    add_versions("2021.11.22", "657c5ed2ba1714c0430895a274a94d6f2aeeab85")

    add_configs("binaryonly", { description = "Only use binary program.", default = false, type = "boolean"})

    add_deps("cmake", "python 3.x", {kind = "binary"})

    if is_plat("linux") then
        add_syslinks("pthread")
    end

    on_load(function (package)
        if package:config("binaryonly") then
            package:set("kind", "binary")
        end
    end)

    on_load(function (package)
        if package:config("shared") then
            package:add("links", "shaderc_shared")
        else
            package:add("links", "shaderc_combined")
        end
    end)

    on_install("linux", "windows", "macosx", function (package)
        os.execv("python3", {"./utils/git-sync-deps"})
        package:addenv("PATH", "bin")
        local configs = {"-DSHADERC_ENABLE_EXAMPLES=OFF", "-DSHADERC_SKIP_TESTS=ON", "-DSHADERC_ENABLE_COPYRIGHT_CHECK=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        os.vrun("glslc --version")
        if not package:config("binaryonly") then
            assert(package:has_cfuncs("shaderc_compiler_initialize", {includes = "shaderc/shaderc.h"}))
        end
    end)

