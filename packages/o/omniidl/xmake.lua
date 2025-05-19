package("omniidl")
    set_kind("binary")
    set_homepage("https://omniorb.sourceforge.io/omni41/omniidl.html")
    set_description("omniidl is omniORB IDL compiler.")
    set_license("GPL-2.0")

    add_urls("https://sourceforge.net/projects/omniorb/files/omniORB/omniORB-$(version)/omniORB-$(version).tar.bz2")

    add_versions("4.3.3", "accd25e2cb70c4e33ed227b0d93e9669e38c46019637887c771398870ed45e7a")

    add_deps("python 3.x", {kind = "binary"})

    on_load("windows", function(package)
        package:addenv("PATH", "bin")
        local msystem = "MINGW" .. (package:is_arch64() and "64" or "32")
        package:add("deps", "msys2", {configs = {msystem = msystem, base_devel = true, gcc = true, make = true}})
    end)

    on_install("windows", function (package)
        import("package.tools.make")
        local python = package:dep("python")
        local python_dir = python:installdir()
        os.setenv("PYTHONHOME", python_dir)
        os.setenv("PYTHONPATH", path.join(python_dir, "Lib") .. ";" .. path.join(python_dir, "Lib", "site-packages"))
        -- Wrap python3 installation for further use of omniorb
        package:addenv("PYTHONHOME", python_dir)
        package:addenv("PYTHONPATH", path.join(python_dir, "Lib") .. ";" .. path.join(python_dir, "Lib", "site-packages"))
        -- Fix windows manifest flag
        io.replace("mk/win32.mk", "/outputresource:", "-outputresource:", {plain = true})
        io.replace("mk/win32.mk", "/manifest", "-manifest", {plain = true})
        -- Do not build libs & applications & services, build only tool
        io.replace("src/dir.mk", "SUBDIRS += lib", "", {plain = true})
        io.replace("src/dir.mk", "SUBDIRS += appl services", "", {plain = true})
        -- Specify vs toolset
        local msvc = import("core.tool.toolchain").load("msvc")
        local vs = msvc:config("vs")
        local platform
        if     vs == "2015" then platform = "x86_win32_vs_14"
        elseif vs == "2017" then platform = "x86_win32_vs_15"
        elseif vs == "2019" then platform = "x86_win32_vs_16"
        elseif vs == "2022" then platform = "x86_win32_vs_17"
        end
        io.replace("config/config.mk", "#platform = " .. platform, "platform = " .. platform, {plain = true})
        -- Specify python.exe file path
        local python = path.cygwin_path(package:dep("python"):installdir("bin") .. "/python")
        io.replace("mk/platforms/" .. platform .. ".mk", "#PYTHON = /cygdrive/c/Python27/python", "PYTHON = " .. python, {plain = true})
        -- Wrap missing env variables in order MSVC (cl/link/rc) -> MinGW (make/sh/mkdir/basename/install)
        local envs = make.buildenvs(package)
        envs.PATH = os.getenv("PATH")
        local msvc = import("core.tool.toolchain").load("msvc")
        envs = os.joinenvs(msvc:runenvs(), envs)
        -- Build tool
        os.cd("src")
        make.make(package, { "export" }, {envs = envs})
        os.cd("..")
        -- Install tool
        os.cp("**.lib", package:installdir("lib"))
        if package:config("shared") then
            os.cp("**.dll", package:installdir("bin"))
        end
        os.cp("**.exe", package:installdir("bin"))
        -- omniidl: Python files for IDL compiler omniidl & omniidl_be python modules
        os.cp("lib/python/omniidl_be", path.join(python_dir, "Lib", "site-packages"))
        os.cp("lib/python/omniidl", path.join(python_dir, "Lib", "site-packages"))
    end)

    on_test(function (package)
        os.vrun("omniidl -u")
    end)
