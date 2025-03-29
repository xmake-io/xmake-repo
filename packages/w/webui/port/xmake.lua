add_rules("mode.debug", "mode.release")

option("log",              {showmenu = true,  default = true})

target("webui")
    set_kind("$(kind)")
    add_files("src/civetweb/civetweb.c", {defines = {"NO_CACHING", "NO_CGI", "NO_SSL", "USE_WEBSOCKET"}})
    add_files("src/webui.c", (has_config("log") and {defines = "WEBUI_LOG"} or {}))
    add_headerfiles("include/webui.h", "include/webui.hpp")
    add_includedirs("include", "src/civetweb")
    if is_plat("windows") then
        add_syslinks("user32", "advapi32", "shell32", "ws2_32", "ole32")
    elseif is_plat("mingw") then
        add_syslinks("ws2_32")
    elseif is_plat("linux") then
        add_syslinks("pthread", "dl")
    end
