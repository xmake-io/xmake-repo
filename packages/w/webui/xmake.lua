package("webui")

    set_homepage("https://webui.me")
    set_description("Use any web browser as GUI, with your preferred language in the backend and HTML5 in the frontend, all in a lightweight portable lib.")
    set_license("MIT")

    set_urls("https://github.com/webui-dev/webui/archive/refs/tags/$(version).tar.gz",
             "https://github.com/webui-dev/webui.git")
    add_versions("2.3.0", "14be57405b12cf434daade2310178534240866e3169c7213a6fa0e4a6c6f9f27")

    if is_plat("windows") then
        add_syslinks("user32", "advapi32")
    elseif is_plat("mingw") then
        add_syslinks("ws2_32")
    end

    on_install("windows", "linux", "macosx", "mingw", "msys", "android", "cross", function (package)
        local configs = {}
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("webui")
                set_kind("$(kind)")
                add_files("src/civetweb/civetweb.c", {defines = {"NO_CACHING", "NO_CGI", "NO_SSL", "USE_WEBSOCKET"}})
                add_files("src/webui.c", {defines = "WEBUI_LOG"})
                add_headerfiles("include/webui.h", "include/webui.hpp")
                add_includedirs("include", "src/civetweb")
                if is_plat("windows") then
                    add_syslinks("user32", "advapi32")
                elseif is_plat("mingw") then
                    add_syslinks("ws2_32")
                end
        ]])
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <webui.hpp>
            void test() {
                size_t my_window = webui_new_window();
                webui_show(my_window, "<html>Hello</html>");
                webui_wait();
            }
        ]]}))
    end)
