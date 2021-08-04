package("easyloggingpp")

    set_homepage("https://github.com/amrayn/easyloggingpp")
    set_description("Single header C++ logging library.")
    set_license("MIT")

    add_urls("https://github.com/amrayn/easyloggingpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/amrayn/easyloggingpp.git")
    add_versions("v9.97.0", "9110638e21ef02428254af8688bf9e766483db8cc2624144aa3c59006907ce22")

    on_load("windows", function (package)
        if package:config("shared") then
            package:add("defines", "ELPP_AS_DLL")
        end
    end)

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("easyloggingpp")
                set_kind("$(kind)")
                add_files("src/easylogging++.cc")
                add_headerfiles("src/easylogging++.h")
                if is_plat("windows") and is_kind("shared") then
                    add_defines("ELPP_AS_DLL", "ELPP_EXPORT_SYMBOLS")
                end
        ]])
        import("package.tools.xmake").install(package, {kind = package:config("shared") and "shared" or "static"})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            INITIALIZE_EASYLOGGINGPP
            void test() {
                LOG(INFO) << "My first info log using default logger";
            }
        ]]}, {configs = {languages = "c++11"}, includes = "easylogging++.h"}))
    end)
