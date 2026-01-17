package("matio")
    set_homepage("https://matio.sourceforge.io")
    set_description("MATLAB MAT File I/O Library")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/tbeu/matio/archive/refs/tags/$(version).tar.gz",
             "https://github.com/tbeu/matio.git", {submodules = false})

    add_versions("v1.5.30", "cd514c42e13bb39477e7d8fdeaa1502014c552a6a53f0678809cce6951db2bc1")
    add_versions("v1.5.29", "345f18bad65ad4a736ef5b4d660e8587c672939ff88b8551453e03d2146ff8b0")
    add_versions("v1.5.28", "04d14160a637ea822593c336b231227372179f650250c98024a8a2b744afef25")
    add_versions("v1.5.27", "2efe7c4a206885287c0f56128f3a36aa6e453077d03e4c2c42cdce9d332b67eb")
    add_versions("v1.5.26", "4aa5ac827ee49a3111f88f8d9b8ae034b8757384477e8f29cb64582c7d54e156")

    add_configs("zlib", {description = "Build with zlib support", default = false, type = "boolean"})
    add_configs("hdf5", {description = "Build with hdf5 support", default = false, type = "boolean"})
    add_configs("extended_sparse", {description = "Enable extended sparse matrix data types not supported in MATLAB", default = false, type = "boolean"})
    add_configs("mat73", {description = "Enable support for version 7.3 MAT files", default = false, type = "boolean"})
    add_configs("default_file_version", {description = "Select what MAT file format version is used by default", default = "5", type = "string", values = {"4", "5", "7.5"}})
    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})
    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")

    on_load(function (package)
        if package:config("zlib") then
            package:add("deps", "zlib >=1.2.3")
        end
        if package:config("hdf5") then
            package:add("deps", "hdf5 >=1.8.x")
        end
    end)

    on_install(function (package)
        io.replace("CMakeLists.txt", "include(cmake/test.cmake)", "", {plain = true})
        if not package:config("tools") then
            io.replace("CMakeLists.txt", "include(cmake/tools.cmake)", "", {plain = true})
        end

        local configs = {"-DMATIO_BUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DMATIO_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DMATIO_PIC=" .. (package:config("pic") and "ON" or "OFF"))
        table.insert(configs, "-DMATIO_WITH_ZLIB=" .. (package:config("zlib") and "ON" or "OFF"))
        table.insert(configs, "-DMATIO_WITH_HDF5=" .. (package:config("hdf5") and "ON" or "OFF"))
        table.insert(configs, "-DMATIO_EXTENDED_SPARSE=" .. (package:config("extended_sparse") and "ON" or "OFF"))
        table.insert(configs, "-DMATIO_MAT73=" .. (package:config("mat73") and "ON" or "OFF"))
        table.insert(configs, "-DMATIO_DEFAULT_FILE_VERSION=" .. package:config("default_file_version"))

        local hdf5 = package:dep("hdf5")
        if hdf5 and not hdf5:is_system() then
            table.insert(configs, "-DHDF5_ROOT=" .. hdf5:installdir())
            table.insert(configs, "-DHDF5_USE_STATIC_LIBRARIES=" .. (hdf5:config("shared") and "OFF" or "ON"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("Mat_Open", {includes = "matio.h"}))
    end)
