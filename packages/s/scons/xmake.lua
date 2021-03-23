package("scons")

    set_homepage("https://scons.org")
    set_description("A software construction tool")

    add_urls("https://github.com/SCons/scons/archive/refs/tags/$(version).zip",
             "https://github.com/SCons/scons.git")
    add_versions("4.1.0", "106259e92ba001feae5b50175bcec92306d0420bb08229fb037440cf303fcfc3")

    add_deps("python >=3.0")

    set_kind("binary")

    on_load("@windows", "@linux", "@macosx", function (package)
        import("lib.detect.find_tool")

        -- get version from python
        local python = assert(find_tool("python"), "python not found!")
        local py_out = os.iorunv(python.program, {"--version"})
        local version = py_out:gsub("Python ", "")
        local index = version:find(".")
        local version_major = version:sub(0, index)
        local index1 = version:sub(index + 1):find(".")
        local version_minor = version:sub(index + 2, index1 + index + 1)

        -- get version from scons
        local scons_version = package:version()
        local scons_egg = "SCons-" .. scons_version:major() .. "." .. scons_version:minor() .. "." .. scons_version:patch() .. "-py" .. version_major .. "." .. version_minor .. ".egg"

        -- set PYTHONPATH
        local pyver = ("python%d.%d"):format(version_major, version_minor)
        local PYTHONPATH = package:installdir("lib", pyver, "site-packages", scons_egg)
        package:addenv("PYTHONPATH", PYTHONPATH)
    end)

    on_install("@windows", "@linux", "@macosx", function (package)
        import("lib.detect.find_tool")

        local python = assert(find_tool("python"), "python not found!")

        -- setup.py install needs these
        os.mkdir("build/doc/man")
        io.writefile("build/doc/man/scons.1", "")
        io.writefile("build/doc/man/scons-time.1", "")
        io.writefile("build/doc/man/sconsign.1", "")

        os.execv(python.program, {"setup.py", "install", "--prefix", package:installdir()})
    end)

    on_test(function (package)
        import("lib.detect.find_tool")
        local scons = assert(find_tool("scons"), "scons not found!")
        assert(os.execv(scons.program, {"--version"}))
    end)
