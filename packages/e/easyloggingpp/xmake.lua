package("easyloggingpp")

    set_homepage("https://github.com/amrayn/easyloggingpp")
    set_description("Single header C++ logging library.")
    set_license("MIT")

    add_urls("https://github.com/amrayn/easyloggingpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/amrayn/easyloggingpp.git")
    add_versions("v9.97.1", "ebe473e17b13f1d1f16d0009689576625796947a711e14aec29530f39560c7c2")
    add_versions("v9.97.0", "9110638e21ef02428254af8688bf9e766483db8cc2624144aa3c59006907ce22")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("easyloggingpp")
                set_kind("static")
                set_languages("c++11")
                add_files("src/easylogging++.cc")
                add_headerfiles("src/easylogging++.h")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            INITIALIZE_EASYLOGGINGPP
            void test() {
                LOG(INFO) << "My first info log using default logger";
            }
        ]]}, {configs = {languages = "c++11"}, includes = "easylogging++.h"}))
    end)
