package("cpp-tbox")
    set_homepage("https://github.com/cpp-main/cpp-tbox")
    set_description("A complete Linux application software development tool library and runtime framework, aim at make C++ development easy.")
    set_license("MIT")

    add_urls("https://github.com/cpp-main/cpp-tbox.git")
    add_versions("2023.12.13", "1666e59a1ff2407a692d619691d744d52c1c057d")

    add_deps("dbus", "nlohmann_json", "mosquitto")

    on_install("linux", function (package)
        local cflags = {}
        local depinfo = package:dep("mosquitto"):fetch()
        for _, includedir in ipairs(depinfo.includedirs or depinfo.sysincludedirs) do
            table.insert(cflags, "-I" .. includedir)
        end
        io.replace("build_env.mk", "CCFLAGS := -I$(STAGING_INCLUDE)", "CCFLAGS := -I$(STAGING_INCLUDE) " .. table.concat(cflags, " "), {plain=true})
        local configs = {"3rd-party", "modules"}
        if not package:debug() then
            table.insert(configs, "RELEASE=1")
        else
            table.insert(configs, "RELEASE=0")
        end
        if package:config("shared") then
            table.insert(configs, "ENABLE_SHARED_LIB=yes")
            table.insert(configs, "ENABLE_STATIC_LIB=no")
            table.insert(configs, "INSTALL_DIR=" .. package:installdir())
            table.insert(configs, "STAGING_DIR=" .. package:installdir())
        else
            table.insert(configs, "ENABLE_SHARED_LIB=no")
            table.insert(configs, "ENABLE_STATIC_LIB=yes")
            table.insert(configs, "STAGING_DIR=" .. package:installdir())
        end
        
        import("package.tools.make").make(package, configs)
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
