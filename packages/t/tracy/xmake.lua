package("tracy")
    set_homepage("https://tracy.nereid.pl/")
    set_description("Frame profiler")

    add_urls("https://github.com/wolfpld/tracy/archive/refs/tags/$(version).tar.gz",
             "https://github.com/wolfpld/tracy.git")

    add_versions("v0.11.1", "2c11ca816f2b756be2730f86b0092920419f3dabc7a7173829ffd897d91888a1")

    add_configs("tracy_enable",                      {type = "boolean", default = true,  description = "Enable profiling"})
    add_configs("on_demand",                         {type = "boolean", default = false, description = "On-demand profiling"})
    add_configs("callstack",                         {type = "boolean", default = false, description = "Enfore callstack collection for tracy regions"})
    add_configs("no_callstack",                      {type = "boolean", default = false, description = "Disable all callstack related functionality"})
    add_configs("no_callstack_inlines",              {type = "boolean", default = false, description = "Disables the inline functions in callstacks"})
    add_configs("only_localhost",                    {type = "boolean", default = false, description = "Only listen on the localhost interface"})
    add_configs("no_broadcast",                      {type = "boolean", default = false, description = "Disable client discovery by broadcast to local network"})
    add_configs("only_ipv4",                         {type = "boolean", default = false, description = "Tracy will only accept connections on IPv4 addresses (disable IPv6)"})
    add_configs("no_code_transfer",                  {type = "boolean", default = false, description = "Disable collection of source code"})
    add_configs("no_context_switch",                 {type = "boolean", default = false, description = "Disable capture of context switches"})
    add_configs("no_exit",                           {type = "boolean", default = false, description = "Client executable does not exit until all profile data is sent to server"})
    add_configs("no_sampling",                       {type = "boolean", default = false, description = "Disable call stack sampling"})
    add_configs("no_verify",                         {type = "boolean", default = false, description = "Disable zone validation for C API"})
    add_configs("no_vsync_capture",                  {type = "boolean", default = false, description = "Disable capture of hardware Vsync events"})
    add_configs("no_frame_image",                    {type = "boolean", default = false, description = "Disable the frame image support and its thread"})
    add_configs("no_system_tracing",                 {type = "boolean", default = false, description = "Disable systrace sampling"})
    add_configs("patchable_nopsleds",                {type = "boolean", default = false, description = "Enable nopsleds for efficient patching by system-level tools (e.g. rr)"})
    add_configs("timer_fallback",                    {type = "boolean", default = false, description = "Use lower resolution timers"})
    add_configs("libunwind_backtrace",               {type = "boolean", default = false, description = "Use libunwind backtracing where supported"})
    add_configs("symbol_offline_resolve",            {type = "boolean", default = false, description = "Instead of full runtime symbol resolution, only resolve the image path and offset to enable offline symbol resolution"})
    add_configs("libbacktrace_elf_dynload_support",  {type = "boolean", default = false, description = "Enable libbacktrace to support dynamically loaded elfs in symbol resolution resolution after the first symbol resolve operation"})
    add_configs("delayed_init",                      {type = "boolean", default = false, description = "Enable delayed initialization of the library (init on first call)"})
    add_configs("manual_lifetime",                   {type = "boolean", default = false, description = "Enable the manual lifetime management of the profile"})
    add_configs("fibers",                            {type = "boolean", default = true,  description = "Enable fibers support"})
    add_configs("no_crash_handler",                  {type = "boolean", default = false, description = "Disable crash handling"})
    add_configs("verb",                              {type = "boolean", default = false, description = "Enable verbose logging"})

    if is_plat("windows", "mingw") then
        add_syslinks("ws2_32", "dbghelp")
    elseif is_plat("linux") then
        add_syslinks("pthread")
    elseif is_plat("bsd") then
        add_syslinks("pthread", "execinfo")
    end

    on_install(function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        local configs = {
            tracy_enable = package:config("tracy_enable"),
            on_demand = package:config("on_demand"),
            callstack = package:config("callstack"),
            no_callstack = package:config("no_callstack"),
            no_callstack_inlines = package:config("no_callstack_inlines"),
            only_localhost = package:config("only_localhost"),
            no_broadcast = package:config("no_broadcast"),
            only_ipv4 = package:config("only_ipv4"),
            no_code_transfer = package:config("no_code_transfer"),
            no_context_switch = package:config("no_context_switch"),
            no_exit = package:config("no_exit"),
            no_sampling = package:config("no_sampling"),
            no_verify = package:config("no_verify"),
            no_vsync_capture = package:config("no_vsync_capture"),
            no_frame_image = package:config("no_frame_image"),
            no_system_tracing = package:config("no_system_tracing"),
            patchable_nopsleds = package:config("patchable_nopsleds"),
            timer_fallback = package:config("timer_fallback"),
            libunwind_backtrace = package:config("libunwind_backtrace"),
            symbol_offline_resolve = package:config("symbol_offline_resolve"),
            libbacktrace_elf_dynload_support = package:config("libbacktrace_elf_dynload_support"),
            delayed_init = package:config("delayed_init"),
            manual_lifetime = package:config("manual_lifetime"),
            fibers = package:config("fibers"),
            no_crash_handler = package:config("no_crash_handler"),
            verb = package:config("verb"),
        }
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        if package:config("tracy_enable") then
            assert(package:check_cxxsnippets({test = [[
                #include <tracy/Tracy.hpp>
                void test() {
                    TracyPlotConfig("PlotConfig", tracy::PlotFormatType::Number, true, true, 0);
                }
            ]]}, {configs = {languages = "c++14"}}))
        end
        if package:config("fibers") then
            assert(package:check_cxxsnippets({test = [[
                #include <tracy/Tracy.hpp>
                void test() {
                    TracyFiberEnter("Fiber");
                }
            ]]}, {configs = {languages = "c++14"}}))
        end
    end)
