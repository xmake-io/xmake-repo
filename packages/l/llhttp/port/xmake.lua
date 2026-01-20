option("export_symbol", {default = false})

add_rules("mode.debug", "mode.release")

target("llhttp")
    set_kind("$(kind)")
    add_files("src/*.c")
    add_includedirs("include")
    add_headerfiles("include/llhttp.h")

    if has_config("export_symbol") and is_kind("shared") and is_plat("windows") then
        local funcs = {
            "llhttp_init",
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
            "llhttp_set_lenient_chunked_length"
        }
        for _, func in ipairs(funcs) do
            add_shflags("/export:" .. func)
        end
    end

    if is_plat("cross") then
        add_cflags("-flax-vector-conversions")
    end
