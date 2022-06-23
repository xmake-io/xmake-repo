package("lbuild")
    set_kind("binary")
    set_homepage("https://pypi.org/project/lbuild")
    set_description("lbuild: a generic, modular code generator in Python 3")

    add_urls("https://github.com/modm-io/lbuild.git")
    add_versions("2022.02.14", "5d65b36ebed5156809cd4e4675718c04df0515da")

    add_deps("python 3.x", {kind = "binary"})

    on_install(function (package)
        local python_version = package:dep("python"):version()
        local lbuild_version = package:version()
        local lbuild_egg = "lbuild-" .. lbuild_version:major() .. "." .. lbuild_version:minor() .. "." .. lbuild_version:patch() .. "-py" .. python_version:major() .. "." .. python_version:minor() .. ".egg"
        local pyver = ("python%d.%d"):format(python_version:major(), python_version:minor())
        local PYTHONPATH = package:installdir("lib")
        local PYTHONPATH1 = path.join(PYTHONPATH, pyver)
        PYTHONPATH = path.join(PYTHONPATH, "site-packages", lbuild_egg)
        PYTHONPATH2 = path.join(PYTHONPATH1, "site-packages", "lxml-4.9.0-py3.9-macosx-12-x86_64.egg")
        PYTHONPATH1 = path.join(PYTHONPATH1, "site-packages", lbuild_egg)
        package:addenv("PYTHONPATH", PYTHONPATH, PYTHONPATH1, PYTHONPATH2)

        io.writefile("build/doc/man/lbuild.1", "")
        io.writefile("build/doc/man/lbuild-time.1", "")
        io.writefile("build/doc/man/lbuildign.1", "")
        io.replace("setup.py", "from lbuild.__init__ import __version__", format("__version__ = '%s'", lbuild_version))

        os.vrunv("python", {"setup.py", "install", "--prefix", package:installdir()})
        if package:is_plat("windows") then
            os.mv(package:installdir("Scripts", "*"), package:installdir("bin"))
            os.rmdir(package:installdir("Scripts"))
        end
    end)

    on_test(function (package)
        os.vrun("lbuild --version")
    end)
