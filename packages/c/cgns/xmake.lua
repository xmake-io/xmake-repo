package("cgns")

    set_homepage("http://cgns.github.io/")
    set_description("CFD General Notation System")

    add_urls("https://github.com/CGNS/CGNS/archive/refs/tags/$(version).tar.gz")
    add_versions("v4.5.1", "ae63b0098764803dd42b7b2a6487cbfb3c0ae7b22eb01a2570dbce49316ad279")
    add_versions("v4.5.0", "c72355219318755ba0a8646a8e56ee1c138cf909c1d738d258d2774fa4b529e9")
    add_versions("v4.4.0", "3b0615d1e6b566aa8772616ba5fd9ca4eca1a600720e36eadd914be348925fe2")
    add_versions("v4.2.0", "090ec6cb0916d90c16790183fc7c2bd2bd7e9a5e3764b36c8196ba37bf1dc817")

    add_configs("hdf5", {description = "Enable HDF5 interface.", default = false, type = "boolean"})

    add_deps("cmake")
    on_load("windows", "macosx", "linux", function (package)
        if package:config("hdf5") then
            package:add("deps", "hdf5")
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        if package:config("shared") then
            io.replace("src/CMakeLists.txt", "install(TARGETS cgns_static", "#", {plain = true})
        end
        local configs = {"-DCGNS_ENABLE_FORTRAN=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DCGNS_BUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCGNS_ENABLE_HDF5=" .. (package:config("hdf5") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("cg_is_cgns", {includes = "cgnslib.h"}))
    end)
