package("cpp-tbox")
    set_homepage("https://github.com/cpp-main/cpp-tbox")
    set_description("A complete Linux application software development tool library and runtime framework, aim at make C++ development easy.")
    set_license("MIT")

    add_urls("https://github.com/cpp-main/cpp-tbox.git")
    add_versions("2023.12.13", "1666e59a1ff2407a692d619691d744d52c1c057d")
    add_configs("mqtt", {description = "Enable mosquitto", default = false, type = "boolean"})

    add_deps("cmake")
    add_deps("dbus", "nlohmann_json")

    on_load(function (package)
        if package:config("mqtt") then
            add_deps("mosquitto")
        end
    end)

    on_install("linux", function (package)
        local configs = {"-DCMAKE_ENABLE_TEST=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DTBOX_ENABLE_MQTT=" .. (package:config("mqtt") and "ON" or "OFF"))
        table.insert(configs, "-DTBOX_BUILD_LIB_TYPE=" .. (package:config("shared") and "SHARED" or "STATIC"))
        import("package.tools.cmake").install(package, configs)
        os.mv(package:installdir() .. "/include/tbox/http/types.h", package:installdir() .. "/include/tbox/http/server/types.h")
        os.mv(package:installdir() .. "/include/tbox/http/server.h", package:installdir() .. "/include/tbox/http/server/server.h")
        os.mv(package:installdir() .. "/include/tbox/http/context.h", package:installdir() .. "/include/tbox/http/server/context.h")
        os.mv(package:installdir() .. "/include/tbox/http/middleware.h", package:installdir() .. "/include/tbox/http/server/middleware.h")
        os.mv(package:installdir() .. "/include/tbox/http/router.h", package:installdir() .. "/include/tbox/http/server/router.h")
        os.mv(package:installdir() .. "/include/tbox/http/client.h", package:installdir() .. "/include/tbox/http/client/client.h")
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <tbox/base/log.h>
            #include <tbox/base/log_output.h>
            #include <tbox/base/scope_exit.hpp>
            using namespace tbox;
            void test() {
                LogOutput_Enable();
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
