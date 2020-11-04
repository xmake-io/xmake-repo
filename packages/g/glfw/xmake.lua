package("glfw")

    set_homepage("https://www.glfw.org/")
    set_description("GLFW is an Open Source, multi-platform library for OpenGL, OpenGL ES and Vulkan application development.")

    if is_plat("windows", "mingw") then
        if is_arch("x64", "x86_64") then
            set_urls("https://github.com/glfw/glfw/releases/download/$(version)/glfw-$(version).bin.WIN64.zip")
            add_versions("3.3.2", "aa291d8dce27d9e6cd567dc56e3768dcefceb3ddb7a65fb4cc3ef35be2a7548c")
        else
            set_urls("https://github.com/glfw/glfw/releases/download/$(version)/glfw-$(version).bin.WIN32.zip")
            add_versions("3.3.2", "a2a5f93884f728dfc1bcb090fbdbb1015f1c1898b35a50fa17c7ade6761102b1")
        end
    elseif is_plat("macosx") then
        set_urls("https://github.com/glfw/glfw/releases/download/$(version)/glfw-$(version).bin.MACOS.zip")
        add_versions("3.3.2", "e412c75f850c320192df491ec3bf623847fafa847b46ffd3bbd7478057148f5a")
    elseif is_plat("linux") then
        set_urls("https://github.com/glfw/glfw/releases/download/$(version)/glfw-$(version).zip")
        add_versions("3.3.2", "08a33a512f29d7dbf78eab39bd7858576adcc95228c9efe8e4bc5f0f3261efc7")
        add_deps("cmake")
    end

    add_configs("include_none", {description = "Adds the GLFW_INCLUDE_NONE Preprocessor Macro to disable all OpenGL includes inside GLFW", default = true, type = "boolean"})

    if is_plat("macosx") then
        add_frameworks("Cocoa", "IOKit")
    elseif is_plat("linux") then
        add_deps("libx11", "libxrandr", "libxrender", "libxinerama", "libxcursor", "libxi", "libxext")
        add_defines("_GLFW_X11")
    end

    on_load(function (package)
        if package:config("shared") then
            if package:is_plat("windows", "mingw") then
                package:add("defines", "GLFW_DLL")
                package:add("links", "glfw3dll")
            elseif package:is_plat("macosx") then
                package:add("links", "glfw")
            end
        else
            if package:is_plat("windows", "mingw") then
                package:add("links", "glfw3")
                if package:is_plat("windows") then
                    package:add("syslinks", "user32", "shell32")
                end
                package:add("syslinks", "gdi32")
            elseif package:is_plat("macosx") then
                package:add("links", "glfw3")
            elseif package:is_plat("linux") then
                package:add("syslinks", "dl", "pthread")
            end
        end

        if package:config("include_none") then
            package:add("defines", "GLFW_INCLUDE_NONE")
        end
    end)

    on_install("windows", function (package)
        os.cp("include/*", package:installdir("include"))
        local pathlist = os.args(package:build_getenv("cxx")):split('\\')
        local msvc_ver = pathlist[table.getn(pathlist)-9]
        os.cp("lib-vc"..msvc_ver.."/*.lib", package:installdir("lib"))
        os.cp("lib-vc"..msvc_ver.."/*.dll", package:installdir("lib"))
    end)

    on_install("mingw", function (package)
        os.cp("include/*", package:installdir("include"))
        if is_arch("x64", "x86_64") then
            os.cp("lib-mingw-w64/*.a", package:installdir("lib"))
            os.cp("lib-mingw-w64/*.dll", package:installdir("lib"))
        else
            os.cp("lib-mingw/*.a", package:installdir("lib"))
            os.cp("lib-mingw/*.dll", package:installdir("lib"))
        end
    end)

    on_install("macosx", function (package)
        os.cp("include/*", package:installdir("include"))
        os.cp("lib-macos/*.a", package:installdir("lib"))
        os.cp("lib-macos/*.dylib", package:installdir("lib"))
    end)

    on_install("linux", function (package)
        local configs = {}
        table.insert(configs, "-DGLFW_BUILD_DOCS=OFF")
        table.insert(configs, "-DGLFW_BUILD_TESTS=OFF")
        table.insert(configs, "-DGLFW_BUILD_EXAMPLES=OFF")
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        -- patch missing libxrender/includes
        local cflags = {}
        local fetchinfo = package:dep("libxrender"):fetch()
        if fetchinfo then
            for _, includedir in ipairs(fetchinfo.includedirs) do
                table.insert(cflags, "-I" .. includedir)
            end
        end
        if #cflags > 0 then
            table.insert(configs, "-DCMAKE_C_FLAGS=" .. table.concat(cflags, " "))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        local cxflags
        if not package:config("shared") and package:is_plat("windows") then
            cxflags = "/MD"
        end
        assert(package:has_cfuncs("glfwInit", {includes = "GLFW/glfw3.h", configs = {cxflags = cxflags}}))
    end)
