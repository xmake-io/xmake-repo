add_rules("mode.debug", "mode.release")
add_rules("utils.install.cmake_importfiles")

option("tracy_enable",                      {type = "boolean", default = true,  description = "Enable profiling"})
option("on_demand",                         {type = "boolean", default = false, description = "On-demand profiling"})
option("enforce_callstack",                 {type = "boolean", default = false, description = "Enfore callstack collection for tracy regions"})
option("callstack",                         {type = "boolean", default = false, description = "Enable all callstack related functionality"})
option("callstack_inlines",                 {type = "boolean", default = false, description = "Enable the inline functions in callstacks"})
option("only_localhost",                    {type = "boolean", default = false, description = "Only listen on the localhost interface"})
option("broadcast",                         {type = "boolean", default = false, description = "Enable client discovery by broadcast to local network"})
option("only_ipv4",                         {type = "boolean", default = false, description = "Tracy will only accept connections on IPv4 addresses (disable IPv6)"})
option("code_transfer",                     {type = "boolean", default = false, description = "Enable collection of source code"})
option("context_switch",                    {type = "boolean", default = false, description = "Enable capture of context switches"})
option("exit",                              {type = "boolean", default = false, description = "Client executable does not exit until all profile data is sent to server"})
option("sampling",                          {type = "boolean", default = false, description = "Enable call stack sampling"})
option("verify",                            {type = "boolean", default = false, description = "Enable zone validation for C API"})
option("vsync_capture",                     {type = "boolean", default = false, description = "Enable capture of hardware Vsync events"})
option("frame_image",                       {type = "boolean", default = false, description = "Enable the frame image support and its thread"})
option("system_tracing",                    {type = "boolean", default = false, description = "Enable systrace sampling"})
option("patchable_nopsleds",                {type = "boolean", default = false, description = "Enable nopsleds for efficient patching by system-level tools (e.g. rr)"})
option("timer_fallback",                    {type = "boolean", default = false, description = "Use lower resolution timers"})
option("libunwind_backtrace",               {type = "boolean", default = false, description = "Use libunwind backtracing where supported"})
option("symbol_offline_resolve",            {type = "boolean", default = false, description = "Instead of full runtime symbol resolution, only resolve the image path and offset to enable offline symbol resolution"})
option("libbacktrace_elf_dynload_support",  {type = "boolean", default = false, description = "Enable libbacktrace to support dynamically loaded elfs in symbol resolution resolution after the first symbol resolve operation"})
option("delayed_init",                      {type = "boolean", default = false, description = "Enable delayed initialization of the library (init on first call)"})
option("manual_lifetime",                   {type = "boolean", default = false, description = "Enable the manual lifetime management of the profile"})
option("fibers",                            {type = "boolean", default = true,  description = "Enable fibers support"})
option("crash_handler",                     {type = "boolean", default = false, description = "Enable crash handling"})
option("verb",                              {type = "boolean", default = false, description = "Enable verbose logging"})

if has_config("libunwind_backtrace") then
    add_requires("libunwind")
end

target("tracy")
    set_kind("$(kind)")
    set_languages("c++14")
    add_files("public/TracyClient.cpp")
    add_headerfiles("public/(tracy/**.h)",  "public/(tracy/**.hpp)",
                    "public/(client/**.h)", "public/(client/**.hpp)",
                    "public/(common/**.h)", "public/(common/**.hpp)")

    if is_plat("windows", "mingw") then
        add_syslinks("ws2_32", "dbghelp")
    elseif is_plat("linux") then
        add_syslinks("pthread")
    elseif is_plat("bsd") then
        add_syslinks("pthread", "execinfo")
    end

    if has_config("tracy_enable") then
        add_defines("TRACY_ENABLE")
    end

    if has_config("on_demand") then
        add_defines("TRACY_ON_DEMAND")
    end

    if has_config("enforce_callstack") then
        add_defines("TRACY_CALLSTACK")
    end

    if has_config("callstack") then
        add_defines("TRACY_NO_CALLSTACK")
    end

    if has_config("callstack_inlines") then
        add_defines("TRACY_NO_CALLSTACK_INLINES")
    end

    if has_config("only_localhost") then
        add_defines("TRACY_ONLY_LOCALHOST")
    end

    if has_config("broadcast") then
        add_defines("TRACY_NO_BROADCAST")
    end

    if has_config("only_ipv4") then
        add_defines("TRACY_ONLY_IPV4")
    end

    if has_config("code_transfer") then
        add_defines("TRACY_NO_CODE_TRANSFER")
    end

    if has_config("context_switch") then
        add_defines("TRACY_NO_CONTEXT_SWITCH")
    end

    if has_config("exit") then
        add_defines("TRACY_NO_EXIT")
    end

    if has_config("sampling") then
        add_defines("TRACY_NO_SAMPLING")
    end

    if has_config("verify") then
        add_defines("TRACY_NO_VERIFY")
    end

    if has_config("vsync_capture") then
        add_defines("TRACY_NO_VSYNC_CAPTURE")
    end

    if has_config("frame_image") then
        add_defines("TRACY_NO_FRAME_IMAGE")
    end

    if has_config("system_tracing") then
        add_defines("TRACY_NO_SYSTEM_TRACING")
    end

    if has_config("patchable_nopsleds") then
        add_defines("TRACY_PATCHABLE_NOPSLEDS")
    end

    if has_config("delayed_init") then
        add_defines("TRACY_DELAYED_INIT")
    end

    if has_config("manual_lifetime") then
        add_defines("TRACY_MANUAL_LIFETIME")
    end

    if has_config("fibers") then
        add_defines("TRACY_FIBERS")
    end

    if has_config("timer_fallback") then
        add_defines("TRACY_TIMER_FALLBACK")
    end

    if has_config("crash_handler") then
        add_defines("TRACY_NO_CRASH_HANDLER")
    end

    if has_config("libunwind_backtrace") then
        add_defines("TRACY_LIBUNWIND_BACKTRACE")
        add_packages("libunwind")
    end

    if has_config("symbol_offline_resolve") then
        add_defines("TRACY_SYMBOL_OFFLINE_RESOLVE")
    end

    if has_config("libbacktrace_elf_dynload_support") then
        add_defines("TRACY_LIBBACKTRACE_ELF_DYNLOAD_SUPPORT")
    end

    if has_config("verb") then
        add_defines("TRACY_VERBOSE")
    end

    if is_kind("shared") then
        add_defines("TRACY_EXPORTS")
    end

    if is_plat("windows", "mingw") then
        add_defines("_WIN32")
    end
