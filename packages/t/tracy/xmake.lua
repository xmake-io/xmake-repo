package("tracy")
    set_homepage("https://github.com/wolfpld/tracy")
    set_description("C++ frame profiler")

    add_urls("https://github.com/wolfpld/tracy/archive/refs/tags/$(version).tar.gz",
             "https://github.com/wolfpld/tracy.git")

    add_versions("v0.10", "a76017d928f3f2727540fb950edd3b736caa97b12dbb4e5edce66542cbea6600")
    add_versions("v0.9.1", "c2de9f35ab2a516a9689ff18f5b62a55b73b93b66514bd09ba013d7957993cd7")
    add_versions("v0.9", "93a91544e3d88f3bc4c405bad3dbc916ba951cdaadd5fcec1139af6fa56e6bfc")
    add_versions("v0.8.2", "4784eddd89c17a5fa030d408392992b3da3c503c872800e9d3746d985cfcc92a")


    add_configs("on_demand",                        { default = false, type = "boolean", description = "On-demand profiling"})
    add_configs("enforce_callstack",                { default = false, type = "boolean", description = "Enforce callstack collection for tracy regions"})
    add_configs("callstack",                        { default = true,  type = "boolean", description = "Enable all callstack related functionality"})
    add_configs("callstack_inlines",                { default = true,  type = "boolean", description = "Enables the inline functions in callstacks"})
    add_configs("only_localhost",                   { default = false, type = "boolean", description = "Only listen on the localhost interface"})
    add_configs("broadcast",                        { default = true,  type = "boolean", description = "Enable client discovery by broadcast to local network"})
    add_configs("only_ipv4",                        { default = false, type = "boolean", description = "Tracy will only accept connections on IPv4 addresses (disable IPv6)"})
    add_configs("code_transfer",                    { default = true,  type = "boolean", description = "Enable collection of source code"})
    add_configs("context_switch",                   { default = true,  type = "boolean", description = "Enable capture of context switches"})
    add_configs("exit",                             { default = true,  type = "boolean", description = "Enable executable does not exit until all profile data is sent to server"})
    add_configs("sampling",                         { default = true,  type = "boolean", description = "Enable call stack sampling"})
    add_configs("verify",                           { default = true,  type = "boolean", description = "Enable zone validation for C API"})
    add_configs("vsync_capture",                    { default = true,  type = "boolean", description = "Enable capture of hardware Vsync events"})
    add_configs("frame_image",                      { default = true,  type = "boolean", description = "Enable the frame image support and its thread"})
    add_configs("system_tracing",                   { default = true,  type = "boolean", description = "Enable systrace sampling"})
    add_configs("patchable_nopsleds",               { default = false, type = "boolean", description = "Enable nopsleds for efficient patching by system-level tools (e.g. rr)"})
    add_configs("delayed_init",                     { default = false, type = "boolean", description = "Enable delayed initialization of the library (init on first call)"})
    add_configs("manual_lifetime",                  { default = false, type = "boolean", description = "Enable the manual lifetime management of the profile"})
    add_configs("fibers",                           { default = false, type = "boolean", description = "Enable fibers support"})
    add_configs("crash_handler",                    { default = true,  type = "boolean", description = "Enable crash handling"})
    add_configs("timer_fallback",                   { default = false, type = "boolean", description = "Use lower resolution timers"})
    add_configs("libunwind_backtrace",              { default = false, type = "boolean", description = "Use libunwind backtracing where supported"})
    add_configs("symbol_offline_resolve",           { default = false, type = "boolean", description = "Instead of full runtime symbol resolution, only resolve the image path and offset to enable offline symbol resolution"})
    add_configs("libbacktrace_elf_dynload_support", { default = false, type = "boolean", description = "Enable libbacktrace to support dynamically loaded elfs in symbol resolution resolution after the first symbol resolve operation"})

    add_deps("cmake")

    on_install("windows|x64", "macosx", "linux|x86_64", function (package)
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
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            static void test() {
                FrameMarkStart("Test start");
                FrameMarkEnd("Test end");
            }
        ]]}, {configs = {languages = "c++17"}, includes = {"tracy/Tracy.hpp"}}))
    end)
