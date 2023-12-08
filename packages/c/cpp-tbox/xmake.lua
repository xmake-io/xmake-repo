package("cpp-tbox")
    set_homepage("https://github.com/cpp-main/cpp-tbox")
    set_description("A complete Linux application software development tool library and runtime framework, aim at make C++ development easy.")
    set_license("MIT")

    add_urls("https://github.com/cpp-main/cpp-tbox.git")
    add_versions("2023.10.20", "63fc6130364854705429f568b393366f422ce733")
    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
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
        io.replace("modules/util/base64.cpp", "#include <cstring>", "#include <cstring>\n#include <cstdint>", {plain = true})
        io.replace("modules/terminal/types.h", "#include <vector>", "#include <vector>\n#include <cstdint>", {plain = true})
        io.replace("modules/crypto/md5.h", "#include <string>", "#include <string>\n#include <cstdint>", {plain = true})
        io.replace("modules/flow/action_executor.h", "#include <deque>", "#include <deque>\n#include <array>", {plain = true})
        io.replace("modules/alarm/3rd-party/ccronexpr.cpp", 'int res = sprintf(str, "%d", num);', 'int res = snprintf(str, CRON_NUM_OF_DIGITS(num) + 1, "%d", num);', {plain = true})
        io.replace("modules/flow/action_executor.h", "#include <deque>", "#include <deque>\n#include <array>", {plain = true})
        io.replace("modules/eventx/timer_pool.cpp", "int cb_level_ = 0;", "", {plain = true})
        io.replace("modules/eventx/timer_pool.cpp", "TBOX_ASSERT(cb_level_ == 0);", "", {plain = true})
        io.replace("modules/jsonrpc/rpc.h", "event::Loop *loop_;", "", {plain = true})
        import("package.tools.cmake").install(package, configs)
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
