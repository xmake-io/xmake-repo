package("scons")
    set_kind("binary")

    set_homepage("https://scons.org")
    set_description("A software construction tool")

    add_urls("https://github.com/SCons/scons/archive/refs/tags/$(version).zip",
             "https://github.com/SCons/scons.git")
    add_versions("4.1.0", "106259e92ba001feae5b50175bcec92306d0420bb08229fb037440cf303fcfc3")

    add_deps("python >=3.0")

    on_install("@windows", "@linux", "@macosx", "@msys", function (package)
        local python_version = package:dep("python"):version()

        local scons_version = package:version()
        local scons_egg = "SCons-" .. scons_version:major() .. "." .. scons_version:minor() .. "." .. scons_version:patch() .. "-py" .. python_version:major() .. "." .. python_version:minor() .. ".egg"

        local PYTHONPATH = package:installdir("lib")
        local pyver = ("python%d.%d"):format(python_version:major(), python_version:minor())
        local PYTHONPATH1 = path.join(PYTHONPATH, pyver)
        PYTHONPATH = path.join(PYTHONPATH, "site-packages", scons_egg)
        PYTHONPATH1 = path.join(PYTHONPATH1, "site-packages", scons_egg)
        package:addenv("PYTHONPATH", PYTHONPATH, PYTHONPATH1)

        -- setup.py install needs these
        io.writefile("build/doc/man/scons.1", "")
        io.writefile("build/doc/man/scons-time.1", "")
        io.writefile("build/doc/man/sconsign.1", "")

        os.vrunv("python", {"setup.py", "install", "--prefix", package:installdir()})
        if package:is_plat("windows") then
            os.mv(package:installdir("Scripts", "*"), package:installdir("bin"))
            os.rmdir(package:installdir("Scripts"))
        end
    end)

    on_test(function (package)
        os.vrun("scons --version")
    end)
