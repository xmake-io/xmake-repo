option("ssl", {default = nil, type = "string"})

add_rules("mode.debug", "mode.release")

add_requires("libuv")
add_packages("libuv")

local ssl = get_config("ssl")
if ssl then
    if ssl == "openssl" or ssl == "boringssl" then
        add_defines("LIBUS_USE_OPENSSL")
        add_requires(ssl)
        add_packages(ssl)
    elseif ssl == "wolfssl" then
        add_defines("LIBUS_USE_WOLFSSL")
        add_requires(ssl)
        add_packages(ssl)
    end
else
    add_defines("LIBUS_NO_SSL")
end

target("usockets")
    set_kind("$(kind)")
    set_languages("cxx20")

    add_files("src/**.cpp", "src/**.c")
    add_includedirs("src")
    add_headerfiles("src/libusockets.h")
