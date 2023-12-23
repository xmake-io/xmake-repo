target("libgpiod")
    set_kind("$(kind)")

    add_headerfiles("include/(gpiod.h)")
    add_files("lib/*.c")
    add_files("lib/uapi/*.h")

    add_headerfiles("bindings/cxx/(gpiod.hpp)")
    add_headerfiles("bindings/cxx/(gpiodcxx/**.hpp)")
    add_files("bindings/cxx/**.cpp")
   
    add_includedirs("include", {public = true})
    add_includedirs("bindings/cxx", {public = true})

target("gpiod")
    set_kind("binary")
    add_files("tools/*.c")
    add_deps("libgpiod")