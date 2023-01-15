add_rules("mode.debug", "mode.release")

add_requires("fmt", "nlohmann_json", "libsodium", "libopus", "openssl", "zlib")

option("enable_coro")
    set_default(false)
option_end()

target("dpp")
    set_kind("$(kind)")
    add_headerfiles("include/(dpp/**.h)")
    if has_config("enable_coro")
        set_languages("c++20")
        add_defines("DPP_CORO", {public = true})

        if is_plat("windows") then
            add_cxxflags("/await:strict")
        else
            add_cxxflags("-fcoroutines")
        end
    else
        set_languages("c++17")
        remove_headerfiles("include/dpp/cluster_coro_calls.h")
        remove_headerfiles("include/dpp/coro.h")
    end
    add_includedirs("include")
    add_files("src/dpp/**.cpp")
    add_packages("fmt", "nlohmann_json", "libsodium", "libopus", "openssl", "zlib")

    add_defines("DPP_BUILD")

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
