target("libgpiod")
    set_kind("$(kind)")

    add_headerfiles("include/(gpiod.h)")
    add_headerfiles("lib/uapi/*.h")
    add_files("lib/*.c")

    add_headerfiles("bindings/cxx/(gpiod.hpp)")
    add_headerfiles("bindings/cxx/(gpiodcxx/**.hpp)")
    add_files("bindings/cxx/**.cpp")
   
    add_includedirs("include", {public = true})
    add_includedirs("bindings/cxx", {public = true})

    before_build(function (target)
        local configure = io.readfile("configure.ac")
        local version = configure:match("AC_INIT%(%[libgpiod%], %[([0-9%.]+)%]%)")
        print("version: " .. version)
        target:add("defines", "GPIOD_VERSION_STR=" .. version)
    end)

for _, tool_file in ipairs(os.files("tools/*.c")) do
    local name = path.basename(tool_file)
    if name ~= "tools-common" then
        target(name)
            set_kind("binary")

            add_files("tools/" .. name .. ".c")
            add_headerfiles("tools/tools-common.h")
            add_files("tools/tools-common.c")

            add_defines("program_invocation_name=" .. name)
            add_deps("libgpiod")
    end
end