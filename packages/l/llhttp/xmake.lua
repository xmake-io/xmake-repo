package("llhttp")

    set_homepage("https://github.com/nodejs/llhttp")
    set_description("Port of http_parser to llparse")
    set_license("MIT")

    add_urls("https://github.com/nodejs/llhttp/archive/release/$(version).tar.gz")
    add_versions("v3.0.0", "02931556e69f8d075edb5896127099e70a093c104a994a57b4d72c85b48d25b0")
    add_versions("v8.1.0", "9da0d23453e8e242cf3b2bc5d6fb70b1517b8a70520065fcbad6be787e86638e")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("llhttp")
                set_kind("$(kind)")
                if is_kind("shared") and is_plat("windows") then
                    local funcs = {"llhttp_init",
                                   "llhttp_settings_init",
                                   "llhttp_execute",
                                   "llhttp_finish",
                                   "llhttp_message_needs_eof",
                                   "llhttp_should_keep_alive",
                                   "llhttp_pause",
                                   "llhttp_resume",
                                   "llhttp_resume_after_upgrade",
                                   "llhttp_get_errno",
                                   "llhttp_get_error_reason",
                                   "llhttp_set_error_reason",
                                   "llhttp_get_error_pos",
                                   "llhttp_errno_name",
                                   "llhttp_method_name",
                                   "llhttp_set_lenient_headers",
                                   "llhttp_set_lenient_chunked_length"}
                    for _, func in ipairs(funcs) do
                        add_shflags("/export:" .. func)
                    end
                end
                add_files("src/*.c")
                add_includedirs("include")
                add_headerfiles("include/llhttp.h")
        ]])
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("llhttp_init", {includes = "llhttp.h"}))
    end)