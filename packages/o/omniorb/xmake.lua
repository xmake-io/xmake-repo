package("omniorb")
    set_kind("binary")
    set_homepage("https://sourceforge.net/projects/omniorb/")
    set_description("omniORB is a CORBA object request broker for C++ and Python. It is very fast, robust, and standards-compliant.")
    set_license("GPL-2.0")
    add_urls("https://sourceforge.net/projects/omniorb/files/omniORB/omniORB-$(version)/omniORB-$(version).tar.bz2")
    add_versions("4.3.3", "accd25e2cb70c4e33ed227b0d93e9669e38c46019637887c771398870ed45e7a")
    add_deps("python 3.x", {kind = "binary"})

    on_load("windows", function(package)
        -- if is_subhost("windows") then
        local msystem = "MINGW" .. (package:is_arch64() and "64" or "32")
        package:add("deps", "msys2", {configs = {msystem = msystem, base_devel = true, gcc = true, make = true}})
        -- end
    end)

    on_install("windows", function (package)
        import("package.tools.make")

        -- os.mkdir("bin/x86_win32")
        -- os.mkdir("lib")
        -- os.mkdir("lib/x86_win32")

        local msvc = import("core.tool.toolchain").load("msvc")
        local vs = msvc:config("vs")
        local platform
        if     vs == "2015" then platform = "x86_win32_vs_14"
        elseif vs == "2017" then platform = "x86_win32_vs_15"
        elseif vs == "2019" then platform = "x86_win32_vs_16"
        elseif vs == "2022" then platform = "x86_win32_vs_17"
        end
        -- Specify vs toolset
        io.replace("config/config.mk", "#platform = " .. platform, "platform = " .. platform, {plain = true})
        local python = path.cygwin_path(package:dep("python"):installdir("bin") .. "/python")
        print("python => " .. python)
        -- Specify python 3 bin directory
        io.replace("mk/platforms/" .. platform .. ".mk", "#PYTHON = /cygdrive/c/Python27/python", "PYTHON = " .. python, {plain = true})

        local msys2 = package:dep("msys2")
        local msys2_bin = msys2:installdir("usr/bin")
        print("msys2_bin => " .. msys2_bin)

        
        -- os.setenv("PATH", msys2_bin .. ";" .. os.getenv("PATH"))

        local msvc = import("core.tool.toolchain").load("msvc")

        local envs = make.buildenvs(package)
        envs.PATH = os.getenv("PATH")
        envs = os.joinenvs(msvc:runenvs(), envs)
        -- envs.PATH = msvc:tool("ld") .. ";" .. envs.PATH
        
        -- envs.link = [["]] .. path.unix(msvc:tool("ld")) .. [["]]
        -- print("MSVC LD => " .. msvc:tool("ld"))


        -- print(envs)
        -- envs.PATH = os.getenv("PATH")
        -- local envs = msvc:runenvs()
        -- envs.PATH = os.getenv("PATH")

        -- envs.PATH = msys2_bin .. ";" .. envs.PATH


        -- os.setenvs(envs)

        -- local cl_path = [["]] .. path.cygwin_path(msvc:tool("cc")) .. [["]]
        -- print(cl_path)
        -- io.replace("src/tool/win32/dir.mk", [[CL.EXE $< advapi32.lib]], cl_path .. [[ $< advapi32.lib]], {plain = true})


        os.cd("src")
        -- make export
        make.make(package, { "export" }, {envs = envs})
        os.cd("..")
        os.cp("**.lib", package:installdir("lib"))
        if package:config("shared") then
            os.cp("**.dll", package:installdir("bin"))
        end
        os.cp("**.exe", package:installdir("bin"))
    end)

    -- on_test(function (package)
    
    -- end)