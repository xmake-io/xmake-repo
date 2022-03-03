package("qt5core")
    set_homepage("https://www.qt.io")
    set_description("Qt is the faster, smarter way to create innovative devices, modern UIs & applications for multiple screens. Cross-platform software development at its best.")
    set_license("LGPL-3")

    add_configs("shared", {description = "Download shared binaries.", default = true, type = "boolean", readonly = true})
    add_configs("vs_runtime", {description = "Set vs compiler runtime.", default = "MD", readonly = true})

    add_versions("5.15.2", "dummy")
    add_versions("5.12.5", "dummy")

    if is_plat("android") then
        add_syslinks("z")
    end

    on_load(function (package)
        package:add("deps", "qt5base", {debug = package:is_debug(), version = package:version_str()})
    end)

    on_fetch(function (package)
        local base = package:dep("qt5base")
        local qt = base:data("qt")
        if not qt then
            return
        end

        local libname = "Qt5Core"
        local links
        if package:is_plat("windows") then
            if package:is_debug() then
                libname = libname .. "d"
            end
        elseif package:is_plat("android") then
            if package:is_arch("x86_64", "x64") then
                libname = libname .. "_x86_64"
            elseif package:is_arch("arm64", "arm64-v8a") then
                libname = libname .. "_arm64-v8a"
            elseif package:is_arch("armv7", "armv7-v7a") then
                libname = libname .. "_armeabi-v7a"
            elseif package:is_arch("x86") then
                libname = libname .. "_x86"
            end

            links = {libname, "z"}
        end

        return {
            qtdir = qt,
            version = qt.version,
            includedirs = {qt.includedir, path.join(qt.includedir, "QtCore")},
            links = links or table.wrap(libname),
            linkdirs = table.wrap(qt.libdir)
        }
    end)

    on_install("windows", "linux", "macosx", "mingw", "android", "iphoneos", function (package)
        local base = package:dep("qt5base")
        local qt = base:data("qt")
        assert(qt, "qt5base is required")
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            int test(int argc, char** argv) {
                QCoreApplication app (argc, argv);
                return app.exec();
            }
        ]]}, {configs = {languages = "c++14", cxflags = not package:is_plat("windows") and "-fPIC" or nil}, includes = {"QCoreApplication"}}))
    end)
