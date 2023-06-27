add_rules("mode.debug", "mode.release")

add_requires("fmt", "nlohmann_json", "libsodium", "libopus", "openssl", "zlib")

target("dpp")
    set_kind("$(kind)")
    set_languages("c++17")
    add_includedirs("include", "include/dpp")
    add_headerfiles("include/(dpp/**.h)")
    add_files("src/dpp/**.cpp")
    add_packages("fmt", "nlohmann_json", "libsodium", "libopus", "openssl", "zlib")

    add_defines("DPP_BUILD", "DPP_USE_EXTERNAL_JSON")

    if is_plat("windows", "mingw") then
        add_defines("WIN32", "_WINSOCK_DEPRECATED_NO_WARNINGS", "WIN32_LEAN_AND_MEAN")
        add_defines("_CRT_SECURE_NO_WARNINGS", "_CRT_NONSTDC_NO_DEPRECATE")
        add_defines("FD_SETSIZE=1024")
        if is_plat("windows") then
            add_cxflags("/Zc:preprocessor")
        end
        if is_kind("static") then
            add_defines("DPP_STATIC", {public = true})
        end
    end
