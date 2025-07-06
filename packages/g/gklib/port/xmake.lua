option("openmp", {default = false})
option("regex", {default = false})
option("rand", {default = false})

add_rules("mode.debug", "mode.release")

if has_config("openmp") then
    add_requires("openmp")
    add_packages("openmp")
end

if has_config("regex") then
    add_defines("USE_GKREGEX", {public = true})
end

if has_config("rand") then
    add_defines("USE_GKRAND")
end

includes("@builtin/check")

configvar_check_cincludes("HAVE_EXECINFO_H", "execinfo.h")
configvar_check_cfuncs("HAVE_GETLINE", "getline")

target("gklib")
    set_kind("$(kind)")
    add_files("*.c")
    add_headerfiles("*.h")

    add_includedirs(".")
    add_vectorexts("all")

    if is_plat("windows") then
        add_files("win32/*.c")
        add_headerfiles("(win32/adapt.h)")
        add_defines("_CRT_SECURE_NO_DEPRECATE", "USE_GKREGEX", "__thread=__declspec(thread)", {public = true})
        if is_kind("shared") then
            add_rules("utils.symbols.export_all")
        end
    elseif is_plat("mingw") then
        add_defines("USE_GKREGEX")
    elseif is_plat("linux") then
        add_syslinks("m")
        add_defines("_FILE_OFFSET_BITS=64")
    elseif is_plat("bsd") then
        add_syslinks("m")
    end

    on_config(function (target)
        if not target:check_csnippets({test = "extern __thread int x;"}) then
            target:add("defines", "__thread")
        end
    end)
