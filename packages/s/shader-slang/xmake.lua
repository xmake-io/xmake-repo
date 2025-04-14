package("shader-slang")
    set_homepage("https://github.com/shader-slang/slang")
    set_description("Making it easier to work with shaders")
    set_license("MIT")

    add_urls("https://github.com/shader-slang/slang.git", { submodules = false })

    add_versions("v2025.6.3", "b9300bae08a77df6ef2efe2b62de14a13b10b9a4")
    add_patches("v2025.6.3", path.join(os.scriptdir(), "patches", "v2025.6.3.patch"))

    add_configs("shared", { description = "Build shared library", default = true, type = "boolean", readonly = true })

    on_load(function (package)
        local version = package:version();
        package:add("defines", "SLANG_VERSION=\"" .. version:gsub("v", "") .. "\"")
    end)

    on_install("windows", "linux", function (package)
        local root = path.join(os.scriptdir(), "port")
        for _, file in ipairs(os.files(path.join(root, "**.lua"))) do
            os.cp(file, path.relative(file, root))
        end

        import("package.tools.xmake").install(package, {
            slang_version = package:version_str(),
        })
        os.cp("include/*.h", package:installdir("include"))
        os.trycp(path.join(package:buildir(), "**.so"), package:installdir("lib"))
        os.trycp(path.join(package:buildir(), "**.dll"), package:installdir("lib"))
    end)
package_end()

