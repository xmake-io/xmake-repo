package("tracy")
    set_homepage("https://github.com/wolfpld/tracy")
    set_description("C++ frame profiler")

    add_urls("https://github.com/wolfpld/tracy/archive/refs/tags/$(version).tar.gz",
             "https://github.com/wolfpld/tracy.git")

    add_versions("v0.10", "a76017d928f3f2727540fb950edd3b736caa97b12dbb4e5edce66542cbea6600")
    add_versions("v0.9.1", "c2de9f35ab2a516a9689ff18f5b62a55b73b93b66514bd09ba013d7957993cd7")
    add_versions("v0.9", "93a91544e3d88f3bc4c405bad3dbc916ba951cdaadd5fcec1139af6fa56e6bfc")
    add_versions("v0.8.2", "4784eddd89c17a5fa030d408392992b3da3c503c872800e9d3746d985cfcc92a")


    -- This list is from CMakeLists.txt of tracy
    local tracy_defines = {
        { key = "on_demand",                        desc = "On-demand profiling"},
        { key = "callstack",                        desc = "Enforce callstack collection for tracy regions"},
        { key = "no_callstack",                     desc = "Disable all callstack related functionality"},
        { key = "no_callstack_inlines",             desc = "Disables the inline functions in callstacks"},
        { key = "only_localhost",                   desc = "Only listen on the localhost interface"},
        { key = "no_broadcast",                     desc = "Disable client discovery by broadcast to local network"},
        { key = "only_ipv4",                        desc = "Tracy will only accept connections on IPv4 addresses (disable IPv6)"},
        { key = "no_code_transfer",                 desc = "Disable collection of source code"},
        { key = "no_context_switch",                desc = "Disable capture of context switches"},
        { key = "no_exit",                          desc = "Client executable does not exit until all profile data is sent to server"},
        { key = "no_sampling",                      desc = "Disable call stack sampling"},
        { key = "no_verify",                        desc = "Disable zone validation for C API"},
        { key = "no_vsync_capture",                 desc = "Disable capture of hardware Vsync events"},
        { key = "no_frame_image",                   desc = "Disable the frame image support and its thread"},
        { key = "no_system_tracing",                desc = "Disable systrace sampling"},
        { key = "patchable_nopsleds",               desc = "Enable nopsleds for efficient patching by system-level tools (e.g. rr)"},
        { key = "delayed_init",                     desc = "Enable delayed initialization of the library (init on first call)"},
        { key = "manual_lifetime",                  desc = "Enable the manual lifetime management of the profile"},
        { key = "fibers",                           desc = "Enable fibers support"},
        { key = "no_crash_handler",                 desc = "Disable crash handling"},
        { key = "timer_fallback",                   desc = "Use lower resolution timers"},
        { key = "libunwind_backtrace",              desc = "Use libunwind backtracing where supported"},
        { key = "symbol_offline_resolve",           desc = "Instead of full runtime symbol resolution, only resolve the image path and offset to enable offline symbol resolution"},
        { key = "libbacktrace_elf_dynload_support", desc = "Enable libbacktrace to support dynamically loaded elfs in symbol resolution resolution after the first symbol resolve operation"},
    }

    for _, cfg in ipairs(tracy_defines) do
        add_configs(cfg.key, {description = cfg.desc, default = false, type = "boolean"})
    end

    add_deps("cmake")

    on_install("windows|x64", "macosx", "linux|x86_64", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        
        for _, cfg in ipairs(tracy_defines) do
            if package:config(cfg.key) then
                table.insert(configs, "-DTRACY_" .. cfg.key:upper() .. "=ON")
                package:add("defines", "TRACY_" .. cfg.key:upper())
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
