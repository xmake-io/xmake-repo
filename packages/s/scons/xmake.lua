package("scons")

    set_homepage("https://scons.org")
    set_description("A software construction tool")

    add_urls("https://github.com/SCons/scons/archive/refs/tags/$(version).zip",
             "https://github.com/SCons/scons.git")
    add_versions("4.1.0", "106259e92ba001feae5b50175bcec92306d0420bb08229fb037440cf303fcfc3")

    add_deps("python >=3.0")

    set_kind("binary")

    on_install("@windows", "@linux", "@macosx", "@msys", function (package)
        import("lib.detect.find_tool")

        local python = assert(find_tool("python3"), "python3 not found!")

        -- get version from python
        local python_version = package:dep("python"):version()

        -- get version from scons
        local scons_version = package:version()
        local scons_egg = "SCons-" .. scons_version:major() .. "." .. scons_version:minor() .. "." .. scons_version:patch() .. "-py" .. python_version:major() .. "." .. python_version:minor() .. ".egg"

        -- set PYTHONPATH
        local PYTHONPATH = package:installdir("lib")
        if os.host() ~= "windows" then
            local pyver = ("python%d.%d"):format(python_version:major(), python_version:minor())
            PYTHONPATH = path.join(PYTHONPATH, pyver)
        end
        PYTHONPATH = path.join(PYTHONPATH, "site-packages", scons_egg)
        package:addenv("PYTHONPATH", PYTHONPATH)

        -- setup.py install needs these
        os.mkdir("build/doc/man")
        io.writefile("build/doc/man/scons.1", "")
        io.writefile("build/doc/man/scons-time.1", "")
        io.writefile("build/doc/man/sconsign.1", "")

        os.execv(python.program, {"setup.py", "install", "--prefix", package:installdir()})
        if package:is_plat("windows") then
            os.mv(package:installdir("Scripts", "*"), package:installdir("bin"))
        end
    end)

    on_test(function (package)
        import("lib.detect.find_tool")
        local scons = assert(find_tool("scons"), "scons not found!")
        assert(os.execv(scons.program, {"--version"}))
    end)
