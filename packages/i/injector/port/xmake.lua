target("injector")
    set_kind("$(kind)")
    set_languages("c")
    add_headerfiles("include/(*.h)")
    add_includedirs("include", {public = true})
    if is_arch("arm.*") then
        add_defines("__arm__")
        if is_arch("arm64") then
            add_defines("__arm64__", "__aarch64__", "_M_ARM64")
        elseif is_arch("arm32") then
            add_defines("_M_ARMT")
        end
    elseif is_arch("x86_64") then 
        add_defines("__x86_64__")
    elseif is_arch("x86") then
        add_defines("__i386__", "_M_IX86")
    end
    if is_plat("windows") then
        add_files("src/windows/*.c")
        add_defines("_WIN32")
    elseif is_plat("macosx") then
        add_headerfiles("src/macos/*.h")
        add_files("src/macos/*.c")
    elseif is_plat("linux") then
        add_files("src/linux/*.c", "src/linux/*.S")
        add_defines("__linux__")
    end
    on_config(function (target)
        if target:has_tool("gcc", "gxx") then
            target:add("defines", "__USE_GNU")
        end
    end)