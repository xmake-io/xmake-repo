package("tracy")
    set_homepage("https://github.com/wolfpld/tracy")
    set_description("C++ frame profiler")

    add_urls("https://github.com/wolfpld/tracy/archive/refs/tags/$(version).tar.gz",
             "https://github.com/wolfpld/tracy.git")

    add_versions("v0.13.1", "d4efc50ebcb0bfcfdbba148995aeb75044c0d80f5d91223aebfaa8fa9e563d2b")
    add_versions("v0.13.0", "b0e972dfeebe42470187c1a47b449c8ee9e8656900bcf87b403175ed50796918")
    add_versions("v0.12.2", "09617765ba5ff1aa6da128d9ba3c608166c5ef05ac28e2bb77f791269d444952")
    add_versions("v0.12.1", "03580b01df3c435f74eec165193d6557cdbf3a84d39582ca30969ef5354560aa")
    add_versions("v0.12.0", "ce2fb5b89aeb6db8401d7efe1bfe8393b7a81ca551273e8c6dd46ed37c02a040")
    add_versions("v0.11.1", "2c11ca816f2b756be2730f86b0092920419f3dabc7a7173829ffd897d91888a1")
    add_versions("v0.11.0", "b591ef2820c5575ccbf17e2e7a1dc1f6b9a2708f65bfd00f4ebefad2a1ccf830")
    add_versions("v0.10", "a76017d928f3f2727540fb950edd3b736caa97b12dbb4e5edce66542cbea6600")
    add_versions("v0.9.1", "c2de9f35ab2a516a9689ff18f5b62a55b73b93b66514bd09ba013d7957993cd7")
    add_versions("v0.9", "93a91544e3d88f3bc4c405bad3dbc916ba951cdaadd5fcec1139af6fa56e6bfc")
    add_versions("v0.8.2", "4784eddd89c17a5fa030d408392992b3da3c503c872800e9d3746d985cfcc92a")

    add_configs("cmake",                            {description = "Use cmake buildsystem", default = true, type = "boolean"})

    add_configs("tracy_enable",                     {type = "boolean", default = true,  description = "Enable profiling"})
    add_configs("on_demand",                        {type = "boolean", default = false, description = "On-demand profiling"})
    add_configs("enforce_callstack",                {type = "boolean", default = true,  description = "Enfore callstack collection for tracy regions"})
    add_configs("callstack",                        {type = "boolean", default = true,  description = "Enable all callstack related functionality"})
    add_configs("callstack_inlines",                {type = "boolean", default = false, description = "Enable the inline functions in callstacks"})
    add_configs("only_localhost",                   {type = "boolean", default = false, description = "Only listen on the localhost interface"})
    add_configs("broadcast",                        {type = "boolean", default = true,  description = "Enable client discovery by broadcast to local network"})
    add_configs("only_ipv4",                        {type = "boolean", default = false, description = "Tracy will only accept connections on IPv4 addresses (disable IPv6)"})
    add_configs("code_transfer",                    {type = "boolean", default = true,  description = "Enable collection of source code"})
    add_configs("context_switch",                   {type = "boolean", default = true,  description = "Enable capture of context switches"})
    add_configs("exit",                             {type = "boolean", default = true,  description = "Client executable will exit even if some profile data is not sent to server"})
    add_configs("sampling",                         {type = "boolean", default = true,  description = "Enable call stack sampling"})
    add_configs("verify",                           {type = "boolean", default = true,  description = "Enable zone validation for C API"})
    add_configs("vsync_capture",                    {type = "boolean", default = true,  description = "Enable capture of hardware Vsync events"})
    add_configs("frame_image",                      {type = "boolean", default = true,  description = "Enable the frame image support and its thread"})
    add_configs("system_tracing",                   {type = "boolean", default = true,  description = "Enable systrace sampling"})
    add_configs("patchable_nopsleds",               {type = "boolean", default = false, description = "Enable nopsleds for efficient patching by system-level tools (e.g. rr)"})
    add_configs("timer_fallback",                   {type = "boolean", default = false, description = "Use lower resolution timers"})
    add_configs("libunwind_backtrace",              {type = "boolean", default = false, description = "Use libunwind backtracing where supported"})
    add_configs("symbol_offline_resolve",           {type = "boolean", default = false, description = "Instead of full runtime symbol resolution, only resolve the image path and offset to enable offline symbol resolution"})
    add_configs("libbacktrace_elf_dynload_support", {type = "boolean", default = false, description = "Enable libbacktrace to support dynamically loaded elfs in symbol resolution resolution after the first symbol resolve operation"})
    add_configs("delayed_init",                     {type = "boolean", default = false, description = "Enable delayed initialization of the library (init on first call)"})
    add_configs("manual_lifetime",                  {type = "boolean", default = false, description = "Enable the manual lifetime management of the profile"})
    add_configs("fibers",                           {type = "boolean", default = true,  description = "Enable fibers support"})
    add_configs("crash_handler",                    {type = "boolean", default = true,  description = "Enable crash handling"})
    add_configs("verb",                             {type = "boolean", default = false, description = "Enable verbose logging"})

    add_includedirs("include", "include/tracy")

    if is_plat("windows", "mingw") then
        add_syslinks("ws2_32", "dbghelp")
    elseif is_plat("linux") then
        add_syslinks("pthread")
    elseif is_plat("bsd") then
        add_syslinks("pthread", "execinfo")
    end

    if on_check then
        on_check("android", function (package)
            if package:version() and package:version():eq("v0.13.1") then
                local ndk = package:toolchain("ndk"):config("ndkver")
                assert(ndk and tonumber(ndk) > 22, "package(tracy v0.13.1) require ndk version > 22")
            end
        end)
    end

    on_load(function (package)
        if package:config("cmake") then
            package:add("deps", "cmake")
        end
    end)

    on_install(function (package)
        io.replace("public/client/TracyProfiler.cpp", [[#ifdef TRACY_ENABLE]], [[#ifdef TRACY_ENABLE
#ifdef __MINGW32__
#define __try try
#define __except(filter) catch(...)
#endif]], {plain = true})
        io.replace("public/client/TracyProfiler.cpp", [[RelationProcessorDie]], [[static_cast<LOGICAL_PROCESSOR_RELATIONSHIP>(5)]], {plain = true})
        if package:config("cmake") then
            io.replace("CMakeLists.txt", [[/$<IF:$<CONFIG:Release>,,$<CONFIG>>]], "", {plain = true})

            local configs = {}
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
            table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

            table.insert(configs, "-DTRACY_ON_DEMAND=" .. (package:config("on_demand") and "ON" or "OFF"))
            table.insert(configs, "-DTRACY_CALLSTACK=" .. (package:config("enforce_callstack") and "ON" or "OFF"))
            table.insert(configs, "-DTRACY_NO_CALLSTACK=" .. (package:config("callstack") and "OFF" or "ON"))
            table.insert(configs, "-DTRACY_NO_CALLSTACK_INLINES=" .. (package:config("callstack_inlines") and "OFF" or "ON"))
            table.insert(configs, "-DTRACY_ONLY_LOCALHOST=" .. (package:config("only_localhost") and "ON" or "OFF"))
            table.insert(configs, "-DTRACY_NO_BROADCAST=" .. (package:config("broadcast") and "OFF" or "ON"))
            table.insert(configs, "-DTRACY_ONLY_IPV4=" .. (package:config("only_ipv4") and "ON" or "OFF"))
            table.insert(configs, "-DTRACY_NO_CODE_TRANSFER=" .. (package:config("code_transfer") and "OFF" or "ON"))
            table.insert(configs, "-DTRACY_NO_CONTEXT_SWITCH=" .. (package:config("context_switch") and "OFF" or "ON"))
            table.insert(configs, "-DTRACY_NO_EXIT=" .. (package:config("exit") and "OFF" or "ON"))
            table.insert(configs, "-DTRACY_NO_SAMPLING=" .. (package:config("sampling") and "OFF" or "ON"))
            table.insert(configs, "-DTRACY_NO_VERIFY=" .. (package:config("verify") and "OFF" or "ON"))
            table.insert(configs, "-DTRACY_NO_VSYNC_CAPTURE=" .. (package:config("vsync_capture") and "OFF" or "ON"))
            table.insert(configs, "-DTRACY_NO_FRAME_IMAGE=" .. (package:config("frame_image") and "OFF" or "ON"))
            table.insert(configs, "-DTRACY_NO_SYSTEM_TRACING=" .. (package:config("system_tracing") and "OFF" or "ON"))
            table.insert(configs, "-DTRACY_PATCHABLE_NOPSLEDS=" .. (package:config("patchable_nopsleds") and "ON" or "OFF"))
            table.insert(configs, "-DTRACY_DELAYED_INIT=" .. (package:config("delayed_init") and "ON" or "OFF"))
            table.insert(configs, "-DTRACY_MANUAL_LIFETIME=" .. (package:config("manual_lifetime") and "ON" or "OFF"))
            table.insert(configs, "-DTRACY_FIBERS=" .. (package:config("fibers") and "ON" or "OFF"))
            table.insert(configs, "-DTRACY_NO_CRASH_HANDLER=" .. (package:config("crash_handler") and "OFF" or "ON"))
            table.insert(configs, "-DTRACY_TIMER_FALLBACK=" .. (package:config("timer_fallback") and "ON" or "OFF"))
            table.insert(configs, "-DTRACY_LIBUNWIND_BACKTRACE=" .. (package:config("libunwind_backtrace") and "ON" or "OFF"))
            table.insert(configs, "-DTRACY_SYMBOL_OFFLINE_RESOLVE=" .. (package:config("symbol_offline_resolve") and "ON" or "OFF"))
            table.insert(configs, "-DTRACY_LIBBACKTRACE_ELF_DYNLOAD_SUPPORT=" .. (package:config("libbacktrace_elf_dynload_support") and "ON" or "OFF"))

            -- collect tracy defines from cmake configs
            for _, config in ipairs(configs) do
                local define, value = config:match("-D(TRACY_%S+)=(.*)")
                if define and value and value == "ON" then
                    package:add("defines", define)
                end
            end

            import("package.tools.cmake").install(package, configs)
        else
            os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
            local configs = {
                tracy_enable = package:config("tracy_enable"),
                on_demand = package:config("on_demand"),
                enforce_callstack = package:config("enforce_callstack"),
                callstack = not package:config("callstack"),
                callstack_inlines = not package:config("callstack_inlines"),
                only_localhost = package:config("only_localhost"),
                broadcast = not package:config("broadcast"),
                only_ipv4 = package:config("only_ipv4"),
                code_transfer = not package:config("code_transfer"),
                context_switch = not package:config("context_switch"),
                exit = not package:config("exit"),
                sampling = not package:config("sampling"),
                verify = not package:config("verify"),
                vsync_capture = not package:config("vsync_capture"),
                frame_image = not package:config("frame_image"),
                system_tracing = not package:config("system_tracing"),
                patchable_nopsleds = package:config("patchable_nopsleds"),
                timer_fallback = package:config("timer_fallback"),
                libunwind_backtrace = package:config("libunwind_backtrace"),
                symbol_offline_resolve = package:config("symbol_offline_resolve"),
                libbacktrace_elf_dynload_support = package:config("libbacktrace_elf_dynload_support"),
                delayed_init = package:config("delayed_init"),
                manual_lifetime = package:config("manual_lifetime"),
                fibers = package:config("fibers"),
                crash_handler = not package:config("crash_handler"),
                verb = package:config("verb"),
            }
            import("package.tools.xmake").install(package, configs)

            local defines = {
                tracy_enable = "TRACY_ENABLE",
                on_demand = "TRACY_ON_DEMAND",
                enforce_callstack = "TRACY_ENABLE_CALLSTACK",
                callstack = { define = "TRACY_NO_CALLSTACK", invert = true },
                callstack_inlines = { define = "TRACY_NO_CALLSTACK_INLINES", invert = true },
                only_localhost = "TRACY_ONLY_LOCALHOST",
                broadcast = { define = "TRACY_NO_BROADCAST", invert = true },
                only_ipv4 = "TRACY_ONLY_IPV4",
                code_transfer = { define = "TRACY_NO_CODE_TRANSFER", invert = true },
                context_switch = { define = "TRACY_NO_CONTEXT_SWITCH", invert = true },
                exit = { define = "TRACY_NO_EXIT", invert = true },
                sampling = { define = "TRACY_NO_SAMPLING", invert = true },
                verify = { define = "TRACY_NO_VERIFY", invert = true },
                vsync_capture = { define = "TRACY_NO_VSYNC_CAPTURE", invert = true },
                frame_image = { define = "TRACY_NO_FRAME_IMAGE", invert = true },
                system_tracing = { define = "TRACY_NO_SYSTEM_TRACING", invert = true },
                patchable_nopsleds = "TRACY_PATCHABLE_NOPSLEDS",
                timer_fallback = "TRACY_TIMER_FALLBACK",
                libunwind_backtrace = "TRACY_LIBUNWIND_BACKTRACE",
                symbol_offline_resolve = "TRACY_SYMBOL_OFFLINE_RESOLVE",
                libbacktrace_elf_dynload_support = "TRACY_LIBBACKTRACE_ELF_DYNLOAD_SUPPORT",
                delayed_init = "TRACY_DELAYED_INIT",
                manual_lifetime = "TRACY_MANUAL_LIFETIME",
                fibers = "TRACY_FIBERS",
                crash_handler = { define = "TRACY_NO_CRASH_HANDLER", invert = true },
                verb = "TRACY_VERBOSE"
            }

            for name, def in pairs(defines) do
                local define, invert
                if type(def) == "table" then
                    define = def.define
                    invert = def.invert
                else
                    define = def
                    invert = false
                end
                local value = package:config(name)
                if value ~= nil then
                    if invert then
                        value = not value
                    end
                    if value then
                        package:add("defines", define)
                    end
                end
            end
        end
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
