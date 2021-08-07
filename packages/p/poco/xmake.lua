package("poco")

    set_homepage("https://pocoproject.org/")
    set_description("The POCO C++ Libraries are powerful cross-platform C++ libraries for building network- and internet-based applications that run on desktop, server, mobile, IoT, and embedded systems.")
    set_license("BSL-1.0")

    add_urls("https://github.com/pocoproject/poco/archive/refs/tags/poco-$(version)-release.tar.gz",
             "https://github.com/pocoproject/poco.git")
    add_versions("1.11.0", "8a7bfd0883ee95e223058edce8364c7d61026ac1882e29643822ce9b753f3602")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end
    add_configs("mysql", {description = "Enable mysql support.", default = false, type = "boolean"})
    add_configs("postgresql", {description = "Enable postgresql support.", default = false, type = "boolean"})
    add_configs("odbc", {description = "Enable odbc support.", default = is_plat("windows"), type = "boolean"})

    add_deps("cmake")
    add_deps("openssl", "pcre", "sqlite3", "expat", "zlib")
    add_defines("POCO_NO_AUTOMATIC_LIBS")

    on_load("windows", "linux", "macosx", function (package)
        if package:config("postgresql") then
            package:add("deps", "postgresql")
        end
        if package:config("mysql") then
            package:add("deps", "mysql")
        end
    end)

    on_install("windows", "linux", "macosx", function (package)
        io.replace("XML/CMakeLists.txt", "EXPAT REQUIRED", "EXPAT CONFIG REQUIRED")
        io.replace("XML/CMakeLists.txt", "EXPAT::EXPAT", "expat::expat")
        io.replace("XML/CMakeLists.txt", "PUBLIC POCO_UNBUNDLED", "PUBLIC POCO_UNBUNDLED XML_DTD XML_NS")
        io.replace("Foundation/CMakeLists.txt", "PUBLIC POCO_UNBUNDLED", "PUBLIC POCO_UNBUNDLED PCRE_STATIC")
        local configs = {"-DPOCO_UNBUNDLED=ON", "-DENABLE_TESTS=OFF", "-DENABLE_PDF=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") and not package:config("shared") then
            table.insert(configs, "-DPOCO_MT=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        if package:is_plat("windows") then
            local vs_sdkver = get_config("vs_sdkver")
            if vs_sdkver then
                local build_ver = string.match(vs_sdkver, "%d+%.%d+%.(%d+)%.?%d*")
                assert(tonumber(build_ver) >= 18362, "poco requires Windows SDK to be at least 10.0.18362.0")
                table.insert(configs, "-DCMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION=" .. vs_sdkver)
                table.insert(configs, "-DCMAKE_SYSTEM_VERSION=" .. vs_sdkver)
            end
        end
        for _, lib in ipairs({"mysql", "postgresql", "odbc"}) do
            table.insert(configs, "-DENABLE_DATA_" .. lib:upper() .. "=" .. (package:config(lib) and "ON" or "OFF"))
        end

        -- warning: only works on windows sdk 10.0.18362.0 and later
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("Poco::BasicEvent<int>", {configs = {languages = "c++14"}, includes = "Poco/BasicEvent.h"}))
    end)
