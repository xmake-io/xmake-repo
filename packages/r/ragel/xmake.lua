package("ragel")
    set_homepage("https://www.colm.net/open-source/ragel/")
    set_description("Ragel State Machine Compiler")
    set_license("MIT")
    set_kind("binary")

    add_urls("http://www.colm.net/files/ragel/ragel-$(version).tar.gz",
             "https://github.com/adrian-thurston/ragel.git")
    add_versions("6.10", "5f156edb65d20b856d638dd9ee2dfb43285914d9aa2b6ec779dac0270cd56c3f")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("ragel")
                set_kind("binary")
                add_files("ragel/*.cpp")
                add_headerfiles("ragel/*.h")
                add_includedirs("aapl")
        ]])
        io.writefile("ragel/config.h", [[
            /* Name of package */
            #define PACKAGE "ragel"

            /* Define to the address where bug reports for this package should be sent. */
            #define PACKAGE_BUGREPORT ""

            /* Define to the full name of this package. */
            #define PACKAGE_NAME "ragel"

            /* Define to the full name and version of this package. */
            #define PACKAGE_STRING "ragel 6.10"

            /* Define to the one symbol short name of this package. */
            #define PACKAGE_TARNAME "ragel"

            /* Define to the home page for this package. */
            #define PACKAGE_URL ""

            /* Define to the version of this package. */
            #define PACKAGE_VERSION "6.10"

            /* Version number of package */
            #define VERSION "6.10"
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        os.vrun("ragel -v")
    end)
