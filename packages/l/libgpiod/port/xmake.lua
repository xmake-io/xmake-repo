option("enable_bindings_cxx", {default = true, showmenu = true, description = "Enable C++ bindings"})
option("enable_tools", {default = true, showmenu = true, description = "Enable tools"})

target("gpiod")
    set_kind("$(kind)")
    set_languages("cxx11")

    add_headerfiles("include/(gpiod.h)")
    add_headerfiles("lib/uapi/*.h")
    add_files("lib/*.c")

    add_includedirs("include", {public = true})

    before_build(function (target)
        local configure = io.readfile("configure.ac")
        local version = configure:match("AC_INIT%(%[libgpiod%], %[?([0-9%.]+)%]?%)")
        target:add("defines", "GPIOD_VERSION_STR=\"" .. version .. "\"")
    end)

if has_config("enable_bindings_cxx") then
    target("gpiodcxx")
        set_kind("$(kind)")
        set_languages("cxx17")

        add_headerfiles("include/(gpiod.h)")
        add_headerfiles("lib/uapi/*.h")
        add_files("lib/*.c")
        
        add_includedirs("include")

        add_headerfiles("bindings/cxx/(gpiod.hpp)")
        add_headerfiles("bindings/cxx/(gpiodcxx/**.hpp)")
        add_files("bindings/cxx/*.cpp")

        add_includedirs("bindings/cxx", {public = true})

        before_build(function (target)
            local configure = io.readfile("configure.ac")
            local version = configure:match("AC_INIT%(%[libgpiod%], %[?([0-9%.]+)%]?%)")
            target:add("defines", "GPIOD_VERSION_STR=\"" .. version .. "\"")
        end)
end

if has_config("enable_tools") then
    for _, tool_file in ipairs(os.files("tools/*.c")) do
        local name = path.basename(tool_file)
        if name ~= "tools-common" then
            target(name)
                set_kind("binary")
                set_languages("cxx11")

                add_files("tools/" .. name .. ".c")
                add_headerfiles("tools/tools-common.h")
                add_files("tools/tools-common.c")

                add_defines("program_invocation_short_name=\"" .. name .. "\"")
                add_defines("program_invocation_name=\"" .. name .. "\"")
                
                add_deps("gpiod")
        end
    end
end