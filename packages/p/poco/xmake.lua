package("poco")

    set_homepage("https://pocoproject.org/")
    set_description("The POCO C++ Libraries are powerful cross-platform C++ libraries for building network- and internet-based applications that run on desktop, server, mobile, IoT, and embedded systems.")
    set_license("BSL-1.0")

    add_urls("https://github.com/pocoproject/poco/archive/refs/tags/poco-$(version)-release.tar.gz",
             "https://github.com/pocoproject/poco.git")
    add_versions("1.11.0", "8a7bfd0883ee95e223058edce8364c7d61026ac1882e29643822ce9b753f3602")
    add_versions("1.11.1", "2412a5819a239ff2ee58f81033bcc39c40460d7a8b330013a687c8c0bd2b4ac0")
    add_versions("1.11.6", "ef0ac1bd1fe4d84b38cde12fbaa7a441d41bfbd567434b9a57ef8b79a8367e74")
    add_versions("1.12.1", "debc6d5d5eb946bb14e47cffc33db4fffb4f11765f34f8db04e71e866d1af8f9")
    add_versions("1.12.2", "30442ccb097a0074133f699213a59d6f8c77db5b2c98a7c1ad9c5eeb3a2b06f3")
    add_versions("1.12.4", "71ef96c35fced367d6da74da294510ad2c912563f12cd716ab02b6ed10a733ef")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end
    add_configs("mysql", {description = "Enable mysql support.", default = false, type = "boolean"})
    add_configs("postgresql", {description = "Enable postgresql support.", default = false, type = "boolean"})
    add_configs("odbc", {description = "Enable odbc support.", default = is_plat("windows"), type = "boolean"})

    add_deps("cmake")
    add_deps("openssl", "sqlite3", "expat", "zlib")
    add_defines("POCO_NO_AUTOMATIC_LIBS")
    if is_plat("windows") then
        add_syslinks("iphlpapi")
    end

    on_load("windows", "linux", "macosx", function (package)
        if package:config("postgresql") then
            package:add("deps", "postgresql")
        end
        if package:config("mysql") then
            package:add("deps", "mysql")
        end
        if package:version():ge("1.12.0") then
            package:add("deps", "pcre2")
        else
            package:add("deps", "pcre")
        end
    end)

    on_install("windows", "linux", "macosx", function (package)
        io.replace("XML/CMakeLists.txt", "EXPAT REQUIRED", "EXPAT CONFIG REQUIRED")
        io.replace("XML/CMakeLists.txt", "EXPAT::EXPAT", "expat::expat")
        io.replace("XML/CMakeLists.txt", "PUBLIC POCO_UNBUNDLED", "PUBLIC POCO_UNBUNDLED XML_DTD XML_NS")
        io.replace("Foundation/CMakeLists.txt", "PUBLIC POCO_UNBUNDLED", "PUBLIC POCO_UNBUNDLED PCRE_STATIC")
        io.replace("Foundation/CMakeLists.txt", "POCO_SOURCES%(SRCS RegExp.-%)", "")
        if package:version():ge("1.12.0") and package:dep("pcre2"):exists() and not package:dep("pcre2"):config("shared") then
            io.replace("cmake/FindPCRE2.cmake", "NAMES pcre2-8", "NAMES pcre2-8-static pcre2-8", {plain = true})
            io.replace("cmake/FindPCRE2.cmake", "IMPORTED_LOCATION \"${PCRE2_LIBRARY}\"", "IMPORTED_LOCATION \"${PCRE2_LIBRARY}\"\nINTERFACE_COMPILE_DEFINITIONS PCRE2_STATIC", {plain = true})
        end
        local configs = {"-DPOCO_UNBUNDLED=ON", "-DENABLE_TESTS=OFF", "-DENABLE_PDF=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") and not package:config("shared") then
            table.insert(configs, "-DPOCO_MT=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        if package:is_plat("windows") then
            local vs_sdkver = import("core.tool.toolchain").load("msvc"):config("vs_sdkver")
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
        
        if package:config("mysql") then
            io.replace("Data/MySQL/include/Poco/Data/MySQL/MySQL.h", '#pragma comment(lib, "libmysql")', '', {plain = true})
            local libmysql = package:dep("mysql"):fetch()
            if libmysql then
                table.insert(configs, "-DMYSQL_INCLUDE_DIR=" .. table.concat(libmysql.includedirs or libmysql.sysincludedirs, ";"))
                table.insert(configs, "-DMYSQL_LIBRARY=" .. table.concat(libmysql.libfiles or {}, ";"))
            end
        end

        -- warning: only works on windows sdk 10.0.18362.0 and later
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("Poco::BasicEvent<int>", {configs = {languages = "c++14"}, includes = "Poco/BasicEvent.h"}))
    end)
