package("cppunit")
    set_homepage("https://freedesktop.org/wiki/Software/cppunit")
    set_description("CppUnit is the C++ port of the famous JUnit framework for unit testing")
    set_license("LGPL-2.1-or-later")

    add_urls("http://dev-www.libreoffice.org/src/cppunit-$(version).tar.gz")

    add_versions("1.15.1", "89c5c6665337f56fd2db36bc3805a5619709d51fb136e51937072f63fcc717a7")

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::cppunit")
    elseif is_plat("linux") then
        add_extsources("pacman::cppunit", "apt::libcppunit-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::cppunit")
    end

    on_install("!android", function (package)
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "CPPUNIT_DLL")
        end

        if is_host("windows") and not is_subhost("msys") then
            os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
            os.cp(path.join(package:scriptdir(), "port", "config-auto.h"), "include/cppunit/config-auto.h")
            import("package.tools.xmake").install(package)
        else
            local configs = {"--enable-doxygen=no", "--enable-dot=no", "--enable-werror=no", "--enable-werror=no"}
            table.insert(configs, "--enable-debug=" .. (package:is_debug() and "yes" or "no"))
            table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
            table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
            import("package.tools.autoconf").install(package, configs)
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                CPPUNIT_NS::TestResult controller;
            }
        ]]}, {configs = {languages = "c++11"}, includes = "cppunit/TestResult.h"}))
    end)
