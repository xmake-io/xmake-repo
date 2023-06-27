add_rules("mode.debug", "mode.release")
set_allowedplats("macosx", "iphoneos", "android", "linux", "windows", "bsd")

add_requires("quickcpplib", "outcome", "ntkernel-error-category")
if has_config("openssl") then
    add_requires("openssl")
end

option("experimental_status_code")
    set_default(false)
    set_description("Use experimental_status_code.")
    add_defines("LLFIO_EXPERIMENTAL_STATUS_CODE")
    set_showmenu(true)
option_end()

option("enable_openssl")
    set_default(false)
    set_description("Enable OpenSSL")
    set_showmenu(true)
option_end()

option("cpp20")
    set_default(false)
    set_description("Use C++20 version.")
    set_languages("c++20")
    add_defines("QUICKCPPLIB_USE_STD_SPAN")
    set_showmenu(true)
option_end()

target("llfio")
    set_kind("$(kind)")
    set_languages("c++17")
    add_packages("quickcpplib", "outcome", "ntkernel-error-category")
    add_headerfiles("include/(llfio/**.hpp)")
    add_headerfiles("include/(llfio/**.ixx)")
    add_headerfiles("include/(llfio/**.h)")
    add_includedirs("include")

    on_config(function(target)
        if target:has_tool("cxx", "clang", "clangxx") then
            target:add("cxxflags", "-fsized-deallocation")
        end
    end)

    if not has_config("enable_openssl") then
        add_defines("LLFIO_DISABLE_OPENSSL=1")
    else
        add_packages("openssl")
    end

    add_options("cpp20", "experimental_status_code", "enable_openssl")

    if is_plat("windows") then
        add_syslinks("advapi32", "user32", "wsock32", "ws2_32", "ole32", "shell32")
        add_defines("LLFIO_LEAN_AND_MEAN")
    end
    if is_plat("android") then
        add_defines("QUICKCPPLIB_DISABLE_EXECINFO")
    end
    add_defines("QUICKCPPLIB_USE_STD_BYTE", "QUICKCPPLIB_USE_STD_OPTIONAL")

    if not is_kind("headeronly") then
        if is_kind("shared") then
            add_defines("LLFIO_DYN_LINK=1")
        else
            add_defines("LLFIO_STATIC_LINK=1")
        end
        add_defines("LLFIO_SOURCE=1")
        add_files("src/*.cpp")
    else
        add_defines("LLFIO_HEADERS_ONLY=1")
        add_headerfiles("include/(llfio/**.ipp)")
    end

    remove_headerfiles("include/llfio/ntkernel-error-category/**")