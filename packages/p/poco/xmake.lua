package("poco")
    set_homepage("https://pocoproject.org/")
    set_description("The POCO C++ Libraries are powerful cross-platform C++ libraries for building network- and internet-based applications that run on desktop, server, mobile, IoT, and embedded systems.")
    set_license("BSL-1.0")

    add_urls("https://github.com/pocoproject/poco/archive/refs/tags/poco-$(version)-release.tar.gz",
             "https://github.com/pocoproject/poco.git")

    add_versions("1.11.0", "8a7bfd0883ee95e223058edce8364c7d61026ac1882e29643822ce9b753f3602")
    add_versions("1.11.1", "2412a5819a239ff2ee58f81033bcc39c40460d7a8b330013a687c8c0bd2b4ac0")
    add_versions("1.11.6", "ef0ac1bd1fe4d84b38cde12fbaa7a441d41bfbd567434b9a57ef8b79a8367e74")
    add_versions("1.11.8", "a59727335a9bf428dc1289cd8ce84f9c1749c1472a0cd3ae86bec85be23d7cbe")
    add_versions("1.12.1", "debc6d5d5eb946bb14e47cffc33db4fffb4f11765f34f8db04e71e866d1af8f9")
    add_versions("1.12.2", "30442ccb097a0074133f699213a59d6f8c77db5b2c98a7c1ad9c5eeb3a2b06f3")
    add_versions("1.12.4", "71ef96c35fced367d6da74da294510ad2c912563f12cd716ab02b6ed10a733ef")
    add_versions("1.12.5", "92b18eb0fcd2263069f03e7cc80f9feb43fb7ca23b8c822a48e42066b2cd17a6")
    add_versions("1.13.3", "9f074d230daf30f550c5bde5528037bdab6aa83b2a06c81a25e89dd3bcb7e419")

    -- https://docs.pocoproject.org/current/00200-GettingStarted.html
    add_configs("foundation", {description = "Build Foundation support library.", default = true, type = "boolean", readonly = true})
    add_configs("xml", {description = "Build XML support library.", default = true, type = "boolean"})
    add_configs("json", {description = "Build JSON support library.", default = false, type = "boolean"})
    add_configs("net", {description = "Build Net support library.", default = false, type = "boolean"})
    add_configs("netssl", {description = "Build NetSSL support library (Need installed openssl libraries).", default = false, type = "boolean"})
    add_configs("crypto", {description = "Build Crypto support library (Need installed openssl libraries).", default = false, type = "boolean"})
    add_configs("jwt", {description = "Build JWT (JSON Web Token) library (Need installed openssl libraries).", default = false, type = "boolean"})
    add_configs("data", {description = "Build Data support library.", default = false, type = "boolean"})
    add_configs("sqlite", {description = "Build Data SQlite support library.", default = false, type = "boolean"})
    add_configs("mysql", {description = "Build Data MySQL or MariaDB support library (Need installed MySQL or MariaDB client libraries).", default = false, type = "boolean"})
    add_configs("mariadb", {description = "Build Data MySQL or MariaDB support library (Need installed MySQL or MariaDB client libraries).", default = false, type = "boolean"})
    add_configs("postgresql", {description = "Build SQL PosgreSQL support library (Need installed PostgreSQL client libraries).", default = false, type = "boolean"})
    add_configs("sql_parser", {description = "Build SQL Parser support library.", default = false, type = "boolean"})
    -- There is no odbc in xmake for now.
    -- Todo:
    add_configs("odbc", {description = "Build Data ODBC support library (Need installed ODBC libraries).", default = false, type = "boolean", readonly = true})
    add_configs("mongodb", {description = "Build MongoDB support library.", default = false, type = "boolean"})
    add_configs("redis", {description = "Build Redis support library.", default = false, type = "boolean"})
    add_configs("pdf", {description = "Build PDF support library.", default = false, type = "boolean"})
    add_configs("util", {description = "Build Util support library.", default = false, type = "boolean"})
    add_configs("zip", {description = "Build Zip support library.", default = true, type = "boolean"})
    add_configs("sevenzip", {description = "Build 7Zip support library.", default = false, type = "boolean"})
    -- There is no aprutil and apache2 in xmake for now.
    -- Todo:
    add_configs("apache_connector", {description = "Build ApacheConnector support library (Need installed apache and apr libraries).", default = false, type = "boolean", readonly = true})
    add_configs("cpp_parser", {description = "Build C++ parser library.", default = false, type = "boolean"})
    add_configs("encodings", {description = "Build Encodings library.", default = false, type = "boolean"})
    add_configs("encodings_compiler", {description = "Enable Encodings Compiler.", default = false, type = "boolean"})
    add_configs("page_compiler", {description = "Build PageCompiler.", default = false, type = "boolean"})
    add_configs("file2page", {description = "Build PageCompiler File2Page.", default = false, type = "boolean"})
    
    if is_plat("windows") then
        add_configs("netssl_win", {description = "Build NetSSL support library(Need installed openssl libraries For Windows only).", default = false, type = "boolean"})
    end
    add_configs("prometheus", {description = "Enable Prometheus.", default = false, type = "boolean"})
    add_configs("active_record", {description = "Enable ActiveRecord.", default = false, type = "boolean"})
    add_configs("active_record_compiler", {description = "Enable ActiveRecord Compiler.", default = false, type = "boolean"})

    add_configs("poco_doc", {description = "Build Poco Documentation Generator.", default = false, type = "boolean"})
    add_configs("poco_test", {description = "Build Unit tests.", default = false, type = "boolean"})

    add_deps("cmake")
    add_deps("sqlite3", "expat", "zlib") -- required: sqlite3(No option sqlite, sqlite3 is also required), expat, zlib, pcre/pcre2

    add_defines("POCO_NO_AUTOMATIC_LIBS", "POCO_UNBUNDLED")
    if is_plat("windows") then
        add_syslinks("iphlpapi")
    end

    on_load(function (package)
        if package:version():ge("1.12.0") then
            package:add("deps", "pcre2")
        else
            package:add("deps", "pcre")
        end
        if package:config("net") and package:is_plat("windows") then
            package:add("syslinks", "ws2_32")
        end
        if package:config("netssl") or package:config("crypto") or package:config("jwt") then
            package:add("deps", "openssl")
        end
        if package:config("mysql") then
            package:add("deps", "mysql")
        end
        if package:config("mariadb") then
            package:add("deps", "mariadb-connector-c")
        end
        if package:config("postgresql") then
            package:add("deps", "postgresql")
        end
        -- There is no odbc in xmake for now.
        if package:config("odbc") then
            package:add("deps", "odbc")
        end
        -- There is no aprutil and apache2 in xmake for now.
        if package:config("apache_connector") then
            package:add("deps", "apr")
            package:add("deps", "aprutil")
            package:add("deps", "apache2")
        end

        if not package:config("shared") then
            package:add("defines", "POCO_STATIC")
        end
    end)

    on_check(function (package)
        if package:is_plat("windows") then
            if package:is_debug() and package:has_runtime("MT", "MD") then
                raise("package(poco) unsupported debug build type with MT/MD runtimes")
            end
        elseif package:is_plat("android") then
            if package:is_arch("armeabi-v7a") then
                local ndk = package:toolchain("ndk")
                local ndkver = ndk:config("ndkver")
                assert(ndkver and tonumber(ndkver) > 22, "package(poco) dep(pcre2/armeabi-v7a): need ndk version > 22")
            end
        end
        assert(not (package:is_plat("mingw") and package:is_subhost("macos")), "Poco not support mingw@macos")
        assert(not (package:is_plat("wasm")), "Poco not support wasm")

        assert(not (package:has_runtime("MT", "MTd") and package:config("shared")), "Poco cannot have both BUILD_SHARED_LIBS and POCO_MT")
        assert(not (package:config("mysql") and package:config("mariadb")), "Poco's options 'mysql' and 'mariadb' cannot exist together")

        -- warning: only works on windows sdk 10.0.18362.0 and later
        if package:is_plat("windows") then
            local vs_sdkver = package:toolchain("msvc"):config("vs_sdkver")
            if vs_sdkver then
                local build_ver = string.match(vs_sdkver, "%d+%.%d+%.(%d+)%.?%d*")
                assert(tonumber(build_ver) >= 18362, "poco requires Windows SDK to be at least 10.0.18362.0")
            end
        end

        -- check option's dependencies
        local dependencies = {xml                    = {"foundation"},
                              json                   = {"foundation"},
                              net                    = {"foundation"},
                              netssl                 = {"foundation", "net", "util", "crypto"},
                              crypto                 = {"foundation"},
                              jwt                    = {"foundation", "json", "crypto"},
                              data                   = {"foundation"},
                              sqlite                 = {"foundation", "data"},
                              mysql                  = {"foundation", "data"},
                              mariadb                = {"foundation", "data"},
                              postgresql             = {"foundation", "data"},
                              sql_parser             = {"foundation"},
                              odbc                   = {"foundation", "data"},
                              mongodb                = {"foundation", "net"},
                              redis                  = {"foundation", "net"},
                              pdf                    = {"foundation", "xml", "json", "util"},
                              util                   = {"foundation", "xml", "json"},
                              zip                    = {"foundation", "xml"},
                              sevenzip               = {"foundation", "xml"},
                              apache_connector       = {"foundation", "xml", "json", "util", "net"},
                              cpp_parser             = {"foundation"},
                              encodings              = {"foundation"},
                              encodings_compiler     = {"foundation", "xml", "json", "util", "net"},
                              page_compiler          = {"foundation", "xml", "json", "util", "net"},
                              file2page              = {"foundation", "xml", "json", "util", "net"},
                              netssl_win             = {"foundation"},
                              prometheus             = {"foundation", "net"},
                              active_record          = {"foundation", "data", "sqlite"},
                              active_record_compiler = {"foundation", "xml", "json", "util"}
                            }
        for opt, deps in pairs(dependencies) do
            if package:config(opt) then
                local flag = true
                for _, dep in ipairs(deps) do
                    flag = flag and package:config(dep)
                end
                assert(flag, "Option \'" .. opt .. "\' depends on {" .. table.concat(deps, ", ") .. "}. But some options not found")
            end
        end
    end)

    on_install(function (package)
        io.replace("CMakeLists.txt", 'include(InstallRequiredSystemLibraries)', '', {plain = true})
        io.replace("XML/CMakeLists.txt", "EXPAT REQUIRED", "EXPAT CONFIG REQUIRED")
        io.replace("XML/CMakeLists.txt", "EXPAT::EXPAT", "expat::expat")
        -- Todo: need to fix pcre2
        -- pcre2 has a partial problem with the static library, resulting in missing macros in poco's foundation module; the shared library has no problems
        if package:version():ge("1.12.0") and not package:dep("pcre2"):config("shared") then
            io.replace("Foundation/CMakeLists.txt", "PUBLIC POCO_UNBUNDLED", "PUBLIC POCO_UNBUNDLED PCRE_STATIC")
            io.replace("Foundation/CMakeLists.txt", "POCO_SOURCES%(SRCS RegExp.-%)", "")
            io.replace("cmake/FindPCRE2.cmake", "NAMES pcre2-8", "NAMES pcre2-8-static pcre2-8", {plain = true})
            io.replace("cmake/FindPCRE2.cmake", "IMPORTED_LOCATION \"${PCRE2_LIBRARY}\"", "IMPORTED_LOCATION \"${PCRE2_LIBRARY}\"\nINTERFACE_COMPILE_DEFINITIONS PCRE2_STATIC", {plain = true})
        end

        if package:config("mariadb") then
            for _, file in ipairs(os.files("Data/MySQL/include/**")) do
                io.replace(file, '#include <mysql/mysql.h>', '#include <mariadb/mysql.h>', {plain = true})
            end
            for _, file in ipairs(os.files("Data/MySQL/src/**")) do
                io.replace(file, '#include <mysql/mysql.h>', '#include <mariadb/mysql.h>', {plain = true})
            end
        end
        if package:config("mysql") or package:config("mariadb") then
            io.replace("Data/MySQL/include/Poco/Data/MySQL/MySQL.h", '#pragma comment(lib, "libmysql")', '', {plain = true})
            io.replace("cmake/FindMySQL.cmake", 'find_path(MYSQL_INCLUDE_DIR mysql/mysql.h', 'find_path(MYSQL_INCLUDE_DIR mysql/mysql.h mariadb/mysql.h', {plain = true})
            io.replace("cmake/FindMySQL.cmake", 'pkg_check_modules(PC_MARIADB QUIET mariadb)', 'pkg_check_modules(PC_MARIADB QUIET mariadb-connector-c)', {plain = true})
            io.replace("cmake/FindMySQL.cmake", 'find_library(MYSQL_LIBRARY NAMES mysqlclient\n', 'find_library(MYSQL_LIBRARY NAMES mysqlclient libmariadb\n', {plain = true})
        end

        local configs = {"-DPOCO_UNBUNDLED=ON", "-DPOCO_MT=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DPOCO_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        if package:config("netssl") or package:config("crypto") or package:config("jwt") then
            table.insert(configs, "-DOPENSSL_USE_STATIC_LIBS=" .. (package:dep("openssl"):config("shared") and "OFF" or "ON"))
        end

        table.insert(configs, "-DENABLE_XML=" .. (package:config("xml") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_JSON=" .. (package:config("json") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_NET=" .. (package:config("net") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_NETSSL=" .. (package:config("netssl") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_CRYPTO=" .. (package:config("crypto") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_JWT=" .. (package:config("jwt") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_DATA=" .. (package:config("data") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_DATA_SQLITE=" .. (package:config("sqlite") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_DATA_MYSQL=" .. (package:config("mysql") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_DATA_MYSQL=" .. (package:config("mariadb") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_DATA_POSTGRESQL=" .. (package:config("postgresql") and "ON" or "OFF"))
        table.insert(configs, "-DPOCO_DATA_NO_SQL_PARSER=" .. (package:config("sql_parser") and "OFF" or "ON"))
        table.insert(configs, "-DENABLE_DATA_ODBC=" .. (package:config("odbc") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_MONGODB=" .. (package:config("mongodb") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_REDIS=" .. (package:config("redis") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_PDF=" .. (package:config("pdf") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_UTIL=" .. (package:config("util") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_ZIP=" .. (package:config("zip") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_SEVENZIP=" .. (package:config("sevenzip") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_APACHECONNECTOR=" .. (package:config("apache_connector") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_CPPPARSER=" .. (package:config("cpp_parser") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_ENCODINGS=" .. (package:config("encodings") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_ENCODINGS_COMPILER=" .. (package:config("encodings_compiler") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_PAGECOMPILER=" .. (package:config("page_compiler") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_PAGECOMPILER_FILE2PAGE=" .. (package:config("file2page") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DENABLE_NETSSL_WIN=" .. (package:config("netssl_win") and "ON" or "OFF"))
        end
        table.insert(configs, "-DENABLE_PROMETHEUS=" .. (package:config("prometheus") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_ACTIVERECORD=" .. (package:config("active_record") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_ACTIVERECORD_COMPILER=" .. (package:config("active_record_compiler") and "ON" or "OFF"))

        table.insert(configs, "-DENABLE_POCODOC=" .. (package:config("poco_doc") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_TESTS=" .. (package:config("poco_test") and "ON" or "OFF"))

        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("Poco::BasicEvent<int>", {configs = {languages = "c++14"}, includes = "Poco/BasicEvent.h"}))

        -- option's test
        local optiontests = {{"xml",                    "Poco::XML::Document",              "Poco/DOM/Document.h"},
                             {"json",                   "Poco::JSON::Parser",               "Poco/JSON/Parser.h"},
                             {"net",                    "Poco::Net::HTTPServer",            "Poco/Net/HTTPServer.h"},
                             {"netssl",                 "Poco::Net::HTTPSStreamFactory",    "Poco/Net/HTTPSStreamFactory.h"},
                             {"crypto",                 "Poco::Crypto::CipherFactory",      "Poco/Crypto/CipherFactory.h"},
                             {"jwt",                    "Poco::JWT::Token",                 "Poco/JWT/Token.h"},
                             {"data",                   "Poco::Data::Row",                  "Poco/Data/Row.h"},
                             {"sqlite",                 "Poco::Data::SQLite::Connector",    "Poco/Data/SQLite/Connector.h"},
                             {"mysql",                  "Poco::Data::MySQL::Connector",     "Poco/Data/MySQL/Connector.h"},
                             {"mariadb",                "Poco::Data::MySQL::Connector",     "Poco/Data/MySQL/Connector.h"},
                             {"postgresql",             "Poco::Data::PostgreSQL::Connector",    "Poco/Data/PostgreSQL/Connector.h"},
                            --  {"sql_parser",             "Poco::XML::Document",              "Poco/DOM/Document.h"}, -- don't know how to check
                             {"odbc",                   "Poco::Data::ODBC::Connector",      "Poco/Data/ODBC/Connector.h"},
                             {"mongodb",                "Poco::MongoDB::Connection",        "Poco/MongoDB/Connection.h"},
                             {"redis",                  "Poco::Redis::Client",              "Poco/Redis/Client.h"},
                             {"pdf",                    "Poco::PDF::Document",              "Poco/PDF/Document.h"},
                             {"util",                   "Poco::Util::Application",          "Poco/Util/Application.h"},
                             {"zip",                    "Poco::Zip::Decompress",            "Poco/Zip/Decompress.h"},
                             {"sevenzip",               "Poco::SevenZip::ArchiveEntry",     "Poco/SevenZip/ArchiveEntry.h"},
                             {"apache_connector",       "Poco::ApacheConnector",            "Poco/ApacheConnector.h"},
                             {"cpp_parser",             "Poco::CppParser::CppToken",        "Poco/CppParser/CppToken.h"},
                             {"encodings",              "Poco::MacChineseSimpEncoding",     "Poco/MacChineseSimpEncoding.h"},
                            --  {"encodings_compiler",     "Poco::XML::Document",              "Poco/DOM/Document.h"}, -- don't know how to check
                            --  {"page_compiler",          "Poco::XML::Document",              "Poco/DOM/Document.h"}, -- don't know how to check
                            --  {"file2page",              "Poco::XML::Document",              "Poco/DOM/Document.h"}, -- don't know how to check
                             {"netssl_win",             "Poco::Net::HTTPSStreamFactory",    "Poco/Net/HTTPSStreamFactory.h"},
                             {"prometheus",             "Poco::Prometheus::CounterSample",  "Poco/Prometheus/CounterSample.h"},
                             {"active_record",          "Poco::ActiveRecord::DefaultStatementPlaceholderProvider", "Poco/ActiveRecord/ActiveRecord.h"}
                            --  {"active_record_compiler", "Poco::XML::Document",              "Poco/DOM/Document.h"} -- don't know how to check
                            }
        for _, optiontest in ipairs(optiontests) do
            local name = optiontest[1]
            local test = optiontest[2]
            local file = optiontest[3]
            if package:config(name) then
                assert(package:has_cxxtypes(test, {configs = {languages = "c++17"}, includes = file}))
            end
        end
    end)
