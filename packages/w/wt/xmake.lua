package("wt")
    set_homepage("http://www.webtoolkit.eu/wt")
    set_description("Wt, C++ Web Toolkit")

    add_urls("https://github.com/emweb/wt/archive/refs/tags/$(version).tar.gz",
             "https://github.com/emweb/wt.git")

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
    add_configs("dbo", {description = "Build Wt::Dbo", type = "boolean", default = false})
    add_configs("fastcgi", {description = "Build the FastCGI connector (libwtfcgi)", type = "boolean", default = false})
    add_configs("test", {description = "Build Wt::Test", type = "boolean", default = false})

    on_install(function (package)
        local configs = {}

        table.insert(configs, "-DBUILD_EXAMPLES=OFF")
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DSHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_SSL=" .. (package:config("ssl") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_HARU=" .. (package:config("haru") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_PANGO=" .. (package:config("pango") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_SQLITE=" .. (package:config("sqlite") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_POSTGRES=" .. (package:config("postgres") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_FIREBIRD=" .. (package:config("firebird") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_MYSQL=" .. (package:config("mysql") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_MSSQLSERVER=" .. (package:config("mssqlserver") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_QT4=" .. (package:config("qt4") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_QT5=" .. (package:config("qt5") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_QT6=" .. (package:config("qt6") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_SAML=" .. (package:config("saml") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_SELENIUM_TESTS=" .. (package:config("selenium_tests") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_OPENGL=" .. (package:config("opengl") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_UNWIND=" .. (package:config("unwind") and "ON" or "OFF"))

        table.insert(configs, "-DCONNECTOR_HTTP=" .. (package:config("http") and "ON" or "OFF"))
        table.insert(configs, "-DCONNECTOR_FCGI=" .. (package:config("fastcgi") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_LIBWTDBO=" .. (package:config("dbo") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_LIBWTTEST=" .. (package:config("test") and "ON" or "OFF"))

        import("package.tools.cmake").install(package, configs)
    end)

    on_load(function (package)
        if package:config("ssl") then
            package:add("deps", "openssl")
        end

        if package:config("haru") then
            package:add("deps", "libharu")
        end
        if package:config("pango") then
            package:add("deps", "pango")
        end
        if package:config("sqlite") then
            package:add("deps", "sqlite3")
        end
        if package:config("postgres") then
            package:add("deps", "libpq")
        end
        if package:config("mysql") then
            package:add("deps", "mysql")
        end
        if package:config("qt5") then
            package:add("deps", "qt5base")
        end
        if package:config("qt6") then
            package:add("deps", "qt6base")
        end
        if package:config("selenium_tests") then
            package:add("deps", "python >= 3")
        end
        if package:config("opengl") then
            package:add("deps", "opengl", "glew")
        end
        if package:config("unwind") then
            package:add("deps", "libunwind")
        end
        if package:config("http") then
            package:add("linkorders", "wthttp", "wt")
        end
        if package:config("fastcgi") then
            package:add("deps", "fcgi")
            package:add("linkorders", "wtfcgi", "wt")
        end
        if package:config("dbo") then
            package:add("linkorders", "wtdbo", "wt")
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
