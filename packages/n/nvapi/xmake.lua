package("nvapi")
    set_homepage("https://github.com/NVIDIA/nvapi")
    set_description("NVAPI is NVIDIA's core software development kit that allows direct access to NVIDIA GPUs and drivers on supported platforms.")

    add_urls("https://github.com/NVIDIA/nvapi.git")
    add_versions("2025.12.18", "832a3673d66a0fdf6d6e522468821d5cbd925f23")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    on_install("windows|!arm*", function (package)
        os.cp("*.h", package:installdir("include"))
        if package:check_sizeof("void*") == "8" then
            os.cp("amd64/nvapi64.lib", package:installdir("lib"))
        else
            os.cp("x86/nvapi.lib", package:installdir("lib"))
        end
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("NvAPI_Initialize", {includes = "nvapi.h"}))
    end)
