option("version", {default = "2.6.0"})

add_rules("mode.debug", "mode.release")

if not is_plat("windows") then
    add_defines("HAVE_STRNDUP")
end

if has_config("version") then
    add_defines("PACKAGE_VERSION=\"" .. get_config("version") .. "\"")
end

target("plist")
    set_kind("$(kind)")
    add_files("libcnary/*.c", "src/*.c")
    add_includedirs("src", "include", "libcnary/include")
    add_headerfiles("include/(plist/*.h)")
    if is_plat("windows") and is_kind("shared") then
        add_rules("utils.symbols.export_all")
    end
