local function qt_table(sdkdir, version)
    return {
        version = version,
        sdkdir = sdkdir,
        sdkver = version,
        bindir = path.join(sdkdir, "bin"),
        includedir = path.join(sdkdir, "include"),
        libdir = path.join(sdkdir, "lib"),
        libexecdir = path.join(sdkdir, "libexec"),
        mkspecsdir = path.join(sdkdir, "mkspecs"),
        qmldir = path.join(sdkdir, "qml"),
        pluginsdir = path.join(sdkdir, "plugins")
    }
end

package("qt6base")
    set_kind("phony")
    set_base("qtbase")

    add_versions("6.3.0", "dummy")

    on_load(function (package)
        package:set("kind", "phony")
    end)

    on_test(function (package)
        local qt = assert(package:data("qt"))
        os.vrun(path.join(qt.bindir, "moc") .. " -v")
        os.vrun(path.join(qt.bindir, "rcc") .. " -v")
    end)
