package("ghostscript")

    set_homepage("https://www.ghostscript.com/")
    set_description("Ghostscript is an interpreter for the PostScript® language and PDF files.")
    set_license("AGPL-3.0")

    add_urls("https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/$(version).tar.gz", {version = function (version)
        return format("gs%s/ghostscript-%s", version:gsub("%.", ""), version)
    end})
    add_versions("9.55.0", "31e2064be67e15b478a8da007d96d6cd4d2bee253e5be220703a225f7f79a70b")
    add_versions("10.0.0", "a57764d70caf85e2fc0b0f59b83b92e25775631714dcdb97cc6e0cea414bb5a3")

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})

    if is_plat("windows") then
        add_defines("__WIN32__", "_Windows")
    end

    on_install("windows", function (package)
        local configs = {"-f", "psi/msvc.mak", "COMP=cl"}
        if package:is_arch("x64") then
            table.insert(configs, "WIN64=1")
        end
        local vs = import("core.tool.toolchain").load("msvc"):config("vs")
        local vs_toolset = import("core.tool.toolchain").load("msvc"):config("vs_toolset")
        local vc_ver = "13"
        if     vs == "2015" then vc_ver = "14"
        elseif vs == "2017" then vc_ver = "15"
        elseif vs == "2019" then vc_ver = "16"
        elseif vs == "2022" then vc_ver = "17"
        end
        table.insert(configs, "MSVC_VERSION=" .. vc_ver)
        table.insert(configs, "MS_TOOLSET_VERSION=" .. vs_toolset)
        table.insert(configs, "AROOTDIR=" .. package:installdir():gsub("\\", "/"))
        import("package.tools.nmake").build(package, configs)
        os.cp("psi/*.h", package:installdir("include"))
        os.cp("bin/gsdll*.lib", package:installdir("lib"))
        os.cp("bin/gsdll*.dll", package:installdir("bin"))
        os.cp("bin/gs*.exe", package:installdir("bin"))
        package:addenv("PATH", "bin")
    end)

    on_install("macosx", "linux", function (package)
        import("package.tools.autoconf").configure(package)
        os.vrun("make so")
        os.vrun("make soinstall")
        os.cp("soobj/*.h", package:installdir("include"))
        os.cp("base/*.h", package:installdir("include"))
        os.cp("psi/*.h", package:installdir("include"))
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        local program
        if package:is_plat("windows") then
            program = package:is_arch("x64") and "gswin64c" or "gswin32c"
        else
            program = "gsc"
            assert(package:has_cfuncs("gs_rotate", {includes = "gscoord.h"}))
        end
        os.vrunv(program, {"--version"})
        assert(package:has_cxxfuncs("gsapi_new_instance", {includes = "iapi.h"}))
    end)
