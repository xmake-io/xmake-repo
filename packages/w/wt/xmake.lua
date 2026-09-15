package("wt")
    set_homepage("http://www.webtoolkit.eu/wt")
    set_description("Wt, C++ Web Toolkit")

    add_urls("https://github.com/emweb/wt/archive/refs/tags/$(version).tar.gz",
             "https://github.com/emweb/wt.git")

    add_versions("4.14.1", "7e815abf72687d37429a0655b30f6e70e2c940d43ddf3f2e09896ab73b7aca4c")
    add_versions("4.14.0", "c11b3b92377c5fa82a466e32618e7ae417c371e8aa294a455c67d497cb86b2ae")

    add_deps("cmake")
    add_deps("libpng", "zlib")
    add_deps("boost", {configs = {asio = true, atomic = true, filesystem = true, program_options = true, serialization = true, system = true, thread = true}})

    add_configs("ssl", {description = "Enable cryptography functions, using OpenSSL", type = "boolean", default = true})
    add_configs("haru", {description = "Enable Haru Free PDF Library, which is used to provide support for painting to PDF (WPdfImage)", type = "boolean", default = false})
    add_configs("pango", {description = "Enable Pango Library, which is used for improved font support (WPdfImage and WRasterImage)", type = "boolean", default = false})
    add_configs("sqlite", {description = "Build SQLite3 backend for Wt::Dbo", type = "boolean", default = false})
    add_configs("postgres", {description = "Build PostgreSQL backend for Wt::Dbo", type = "boolean", default = false})
    add_configs("firebird", {description = "Build FirebirdSQL backend for Wt::Dbo", type = "boolean", default = false, readonly = true})
    add_configs("mysql", {description = "Build mariadb/mysql backend for Wt::Dbo", type = "boolean", default = false})
    add_configs("mssqlserver", {description = "Build Microsoft SQL Server backend for Wt::Dbo", type = "boolean", default = false, readonly = true})
    add_configs("qt4", {description = "Build Qt4 interworking library (libwtwithqt)", type = "boolean", default = false, readonly = true})
    add_configs("qt5", {description = "Build Qt5 interworking library (libwtwithqt5)", type = "boolean", default = false, readonly = true})
    add_configs("qt6", {description = "Build Qt6 interworking library (libwtwithqt6)", type = "boolean", default = false, readonly = true})
    add_configs("saml", {description = "Build built-in SAML service provider for Wt::Auth", type = "boolean", default = false})
    add_configs("selenium_tests", {description = "Build Wt::Test::Selenium (requires Python3)", type = "boolean", default = false, readonly = true})
    add_configs("opengl", {description = "Build Wt with support for server-side opengl rendering", type = "boolean", default = false, readonly = true})
    add_configs("unwind", {description = "Build Wt with stacktrace support using libunwind", type = "boolean", default = false})

    add_configs("http", {description = "Build the stand-alone httpd connector (libwthttp)", type = "boolean", default = true})
    add_configs("libwtdbo", {description = "Build Wt::Dbo", type = "boolean", default = false})
    add_configs("fastcgi", {description = "Build the FastCGI connector (libwtfcgi)", type = "boolean", default = false})
    add_configs("libwttest", {description = "Build Wt::Test", type = "boolean", default = false})

    if is_plat("windows") then
        add_patches("4.14.0", "patches/4.14.0/cmake.patch", "8a8259bd8e8d4c835d8244bdf264787b933e61057cd0ab6551bfc95922674386")
    end

    on_install("macosx", "linux", "windows", function (package)
        local configs = {}

        table.insert(configs, "-DBUILD_EXAMPLES=OFF")
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DSHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        for name, enabled in table.orderpairs(package:configs()) do
            if name == "http" then
                table.insert(configs, "-DCONNECTOR_HTTP=" .. (package:config(name) and "ON" or "OFF"))
            elseif name == "fastcgi" then
                table.insert(configs, "-DCONNECTOR_FCGI=" .. (package:config(name) and "ON" or "OFF"))
            elseif not package:extraconf("configs", name, "builtin") then
                table.insert(configs, "-DENABLE_" .. string.upper(name) .. "=" .. (enabled and "ON" or "OFF"))
            end
        end

        table.insert(configs, "-DZLIB_PREFIX=" .. package:dep("zlib"):installdir())

        local configprefixes = {
            ssl = {"openssl3", "SSL_PREFIX"},
            fastcgi = {"fcgi", "FCGI_PREFIX"},
            postgres = {"libpq", "POSTGRES_PREFIX"},
            mysql = {"mariadb-connector-c", "MYSQL_PREFIX"},
            sqlite = {"sqlite3", "SQLITE3_PREFIX"},
            haru = {"libharu", "HARU_PREFIX"},
            unwind = {"libunwind", "UNWIND_PREFIX"}
        }

        for name, config in pairs(configprefixes) do
            local dep = config[1]
            local define = config[2]
            if package:config(name) then
                table.insert(configs, "-D" .. define .. "=" .. package:dep(dep):installdir())
            end
        end

        import("package.tools.cmake").install(package, configs)
    end)

    on_load(function (package)
        local configdeps = {
            ssl = "openssl3",
            haru = "libharu",
            pango = "pango",
            sqlite = "sqlite3",
            postgres = "libpq",
            mysql = "mariadb-connector-c",
            qt5 = "qt5base",
            qt6 = "qt6base",
            selenium_tests = "python >=3",
            opengl = "glew",
            unwind = "libunwind",
            fastcgi = "fcgi"
        }

        for name, dep in pairs(configdeps) do
            if package:config(name) then
                package:add("deps", dep)
            end
        end

        local configlinks = {
            http = "wthttp",
            fastcgi = "wtfcgi",
            dbo = "wtddbo"
        }

        for name, link in pairs(configlinks) do
            if package:config(name) then
                package:add("linkorders", (package:is_debug() and (link .. "d") or link), (package:is_debug() and "wtd" or "wt"))
            end
        end

        if package:is_plat("mingw") and package:config("http") then
            package:add("syslinks", "Mswsock", "Ole32")
        end

    end)

    on_test(function (package)
        if package:config("http") or package:config("fastcgi") then
            assert(package:check_cxxsnippets({test = [[
                class HelloApplication : public Wt::WApplication {
                public:
                    HelloApplication(const Wt::WEnvironment& env) : WApplication(env) {}
                };

                void test(int argc, char **argv) {
                    Wt::WRun(argc, argv, [](const Wt::WEnvironment &env) {
                        return std::make_unique<HelloApplication>(env);
                    });
                }
            ]]}, {configs = {languages = "c++17"}, includes = "Wt/WApplication.h"}))
        end
    end)
