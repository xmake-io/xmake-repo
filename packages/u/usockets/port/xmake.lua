option("ssl", {default = nil, type = "string"})
option("uv", {showmenu = true, default = false})
option("uring", {showmenu = true, default = false})
option("quic", {showmenu = true, default = false})

add_rules("mode.debug", "mode.release")

local ssl = get_config("ssl")
if ssl then
    add_requires(ssl)
    add_packages(ssl)
    if ssl == "openssl" or ssl == "boringssl" then
        add_defines("LIBUS_USE_OPENSSL")
    elseif ssl == "wolfssl" then
        add_defines("LIBUS_USE_WOLFSSL")
    end
else
    add_defines("LIBUS_NO_SSL")
end

if is_plat("windows") or has_config("uv") then
    add_requires("libuv")
    add_packages("libuv")
    add_defines("LIBUS_USE_LIBUV")
end

if is_plat("linux") and has_config("uring") then
    add_requires("liburing")
    add_packages("liburing")
    add_defines("LIBUS_USE_IO_URING")
end

if has_config("quic") then
    add_requires("lsquic")
    add_packages("lsquic")
    add_defines("LIBUS_USE_QUIC")
end

target("usockets")
    set_kind("$(kind)")
    set_languages("c++17")

    add_files("src/**.cpp", "src/**.c")
    add_includedirs("src")
    add_headerfiles("src/libusockets.h")

    if is_plat("windows") and is_kind("shared") then
        add_rules("utils.symbols.export_all", {export_classes = true})
    end
