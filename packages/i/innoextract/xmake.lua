package("innoextract")
    set_kind("binary")
    set_homepage("https://constexpr.org/innoextract/")
    set_description("A tool to unpack installers created by Inno Setup")

    add_urls("https://github.com/dscharrer/innoextract.git")

    add_versions("2025.02.07", "6e9e34ed0876014fdb46e684103ef8c3605e382e")

    add_deps("cmake")
    add_deps("xz")
    add_deps("boost", {configs = {
        iostreams = true,
            zlib = true,
            bzip2 = true,
        filesystem = true,
        date_time = true,
        system = true,
        program_options = true,
    }})

    on_install(function (package)
        local configs = {"-DUSE_STATIC_LIBS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_LTO=" .. (package:config("lto") and "ON" or "OFF"))

        table.insert(configs, "-DLZMA_USE_STATIC_LIBS=" .. (package:dep("xz"):config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DZLIB_USE_STATIC_LIBS=" .. (package:dep("boost"):config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DBZip2_USE_STATIC_LIBS=" .. (package:dep("bzip2"):config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DBoost_USE_STATIC_LIBS=" .. (package:dep("zlib"):config("shared") and "OFF" or "ON"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        os.vrun("innoextract --help")
    end)
