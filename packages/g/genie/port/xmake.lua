add_rules("mode.release")
target("genie")
    set_kind("binary")
    on_load(function (target)
        local lua_ver
        for _, dir in ipairs(os.dirs("src/host/*")) do
            if dir:find("lua-", 1, true) then
                lua_ver = dir:match("lua%-(%d+%.%d+%.%d+)")
                break
            end
        end
        assert(lua_ver, "lua directory not found!")
        local lua_src = "src/host/lua-" .. lua_ver .. "/src"
        target:add("includedirs", lua_src)
        target:add("files", lua_src .. "/*.c|lua.c|luac.c")
    end)
    add_files("src/host/*.c")
    add_defines("LUA_COMPAT_MODULE")
    if is_plat("windows", "mingw") then
        add_syslinks("ole32")
    elseif is_plat("macosx") then
        add_defines("LUA_USE_MACOSX")
        add_frameworks("CoreServices")
    elseif is_plat("linux") then
        add_defines("LUA_USE_POSIX", "LUA_USE_DLOPEN", "_FILE_OFFSET_BITS=64")
        add_syslinks("dl", "m")
    elseif is_plat("bsd") then
        add_defines("LUA_USE_POSIX", "LUA_USE_DLOPEN")
        add_syslinks("m")
    end
