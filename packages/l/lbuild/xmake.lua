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
        local pyver = ("python%d.%d"):format(python_version:major(), python_version:minor())
        local PYTHONPATH = package:installdir("lib")
        local PYTHONPATH1 = path.join(PYTHONPATH, pyver)
        PYTHONPATH = path.join(PYTHONPATH, "site-packages", "*")
        PYTHONPATH1 = path.join(PYTHONPATH1, "site-packages", "*")
        
        io.replace("setup.py", "from lbuild.__init__ import __version__", format("__version__ = '%s'", lbuild_version))

        os.vrunv("python", {"setup.py", "install", "--prefix", package:installdir()})
        for _, path in ipairs(os.dirs(PYTHONPATH)) do
            package:addenv("PYTHONPATH", path)
        end
        for _, path in ipairs(os.dirs(PYTHONPATH1)) do 
            package:addenv("PYTHONPATH", path)
        end
        if package:is_plat("windows") then
            os.mv(package:installdir("Scripts", "*"), package:installdir("bin"))
            os.rmdir(package:installdir("Scripts"))
        end
    end)

    on_test(function (package)
        os.vrun("lbuild --version")
    end)
