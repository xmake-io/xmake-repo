option("boost_asio", {showmenu = true, default = false})

add_rules("mode.debug", "mode.release")
set_languages("c++11")

if has_config("boost_asio") then
    add_requires("boost")
    add_packages("boost")
end

target("promise-cpp")
    set_kind("$(kind)")
    add_files("src/*.cpp")
    add_includedirs(".", "include")
    add_headerfiles("include/(**.hpp)", "(add_ons/**.hpp)")

    if is_plat("windows") and is_kind("shared") then
        add_defines("PROMISE_BUILD_SHARED")
    end
