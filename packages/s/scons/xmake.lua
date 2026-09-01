package("scons")

    set_kind("binary")
    set_homepage("https://scons.org")
    set_description("A software construction tool")

    add_urls("https://github.com/SCons/scons/archive/refs/tags/$(version).zip",
             "https://github.com/SCons/scons.git")
    add_versions("4.10.1", "384625e035335a2abd723b2c9cee9d76f42d7e96efa86c2f2a91cddf4bab5488")
    add_versions("4.9.1", "074d8ceb95b6f0cbf91ec15ba087635cff0e9d06d02d0f838a852496781e8cc6")
    add_versions("4.8.0", "2309f77eede26a494d697a18b6bb803ddb4ba20875091fb82da504a3665241cd")
    add_versions("4.7.0", "c783ac12040d1682b81ffd153b48ac1dd9a0eff5a9fbfbb55d86c5d186e88e4a")
    add_versions("4.6.0", "ae729515e951cde252205c1c5a7f237025ce204db8e8b9a145616614d87c6f86")
    add_versions("4.1.0", "106259e92ba001feae5b50175bcec92306d0420bb08229fb037440cf303fcfc3")
    add_versions("4.3.0", "c8cb3be5861c05a46250c60938857b9711c29a1500001da187e36dc05ee70295")

    add_deps("python 3.x", {kind = "binary"})

    on_install("@windows", "@linux", "@macosx", "@msys", "@bsd", function (package)
        local python_version = package:dep("python"):version()
        local scons_version = package:version()
        local scons_egg = "SCons-" .. scons_version:major() .. "." .. scons_version:minor() .. "." .. scons_version:patch() .. "-py" .. python_version:major() .. "." .. python_version:minor() .. ".egg"
        local pyver = ("python%d.%d"):format(python_version:major(), python_version:minor())
        local PYTHONPATH = package:installdir("lib")
        local PYTHONPATH1 = path.join(PYTHONPATH, pyver)
        PYTHONPATH = path.join(PYTHONPATH, "site-packages", scons_egg)
        PYTHONPATH1 = path.join(PYTHONPATH1, "site-packages", scons_egg)
        package:addenv("PYTHONPATH", PYTHONPATH, PYTHONPATH1)

        -- setup.py install needs these
        if package:version():ge("4.3.0") then
            io.writefile("scons.1", "")
            io.writefile("scons-time.1", "")
            io.writefile("sconsign.1", "")
        else
            io.writefile("build/doc/man/scons.1", "")
            io.writefile("build/doc/man/scons-time.1", "")
            io.writefile("build/doc/man/sconsign.1", "")
        end

        -- fix ml64 support for x64
        -- @see https://stackoverflow.com/questions/58919970/building-x64-nsis-using-vs2012
        io.replace("SCons/Tool/masm.py", "'ml'", "'ml64' if env.get('TARGET_ARCH')=='amd64' else 'ml'", {plain = true})
        os.vrunv("python", {"setup.py", "install", "--prefix", package:installdir()})
        if is_host("windows", "msys") then
            os.mv(package:installdir("Scripts", "*"), package:installdir("bin"))
            os.rmdir(package:installdir("Scripts"))
        end
    end)

    on_test(function (package)
        os.vrun("scons --version")
    end)
