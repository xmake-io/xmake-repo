package("shaderc")

    set_homepage("https://github.com/google/shaderc")
    set_description("A collection of tools, libraries, and tests for Vulkan shader compilation.")
    set_license("Apache-2.0")

    add_urls("https://github.com/google/shaderc/archive/refs/tags/$(version).tar.gz",
             "https://github.com/google/shaderc.git")
    add_versions("v2022.2", "517d36937c406858164673db696dc1d9c7be7ef0960fbf2965bfef768f46b8c0")

    add_deps("cmake", "python 3.x", {kind = "binary"})

    if is_plat("linux") then
        add_syslinks("pthread")
    end

    on_load(function (package)
        if package:is_binary() then
            package:set("kind", "binary")
        end
        if package:config("shared") then
            package:add("links", "shaderc_shared")
        else
            package:add("links", "shaderc_combined")
        end
    end)

    on_fetch(function (package, opt)
        if opt.system and package:is_binary() then
            return package:find_tool("glslc")
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
        if not package:is_binary() then
            assert(package:has_cfuncs("shaderc_compiler_initialize", {includes = "shaderc/shaderc.h"}))
        end
    end)

