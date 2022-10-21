-- project
set_project("CommonLibSSE")

-- set architecture
set_arch("x64")

-- set languages
set_languages("c++20")

-- add rules
add_rules("mode.debug", "mode.release")

-- set warnings
set_warnings("allextra", "error")

-- set optimization
set_optimize("faster")

-- add options
option("skyrim_se")
    set_default(true)
    set_description("Enable runtime support for Skyrim SE")
    add_defines("ENABLE_SKYRIM_SE=1")
option_end()

option("skyrim_ae")
    set_default(true)
    set_description("Enable runtime support for Skyrim AE")
    add_defines("ENABLE_SKYRIM_AE=1")
option_end()

option("skyrim_vr")
    set_default(true)
    set_description("Enable runtime support for Skyrim VR")
    add_defines("ENABLE_SKYRIM_VR=1")
option_end()

option("skse_xbyak")
    set_default(false)
    set_description("Enable trampoline support for Xbyak")
    add_defines("SKSE_SUPPORT_XBYAK=1")
option_end()

-- add packages
add_requires("fmt", "spdlog", "rapidcsv")

if has_config("skse_xbyak") then
    add_requires("xbyak")
end

-- targets
target("CommonLibSSE")
    set_kind("static")

    -- add packages
    add_packages("fmt", "spdlog", "rapidcsv")

    if has_config("skse_xbyak") then
        add_packages("xbyak")
    end

    -- add options
    add_options("skyrim_se", "skyrim_ae", "skyrim_vr", "skse_xbyak")

    -- add system links
    add_syslinks("version", "user32", "shell32", "ole32", "advapi32")

    -- add source files
    add_files("src/**.cpp")

    -- add header files
    add_includedirs("include", { public = true })
    add_headerfiles(
        "include/(RE/**.h)",
        "include/(REL/**.h)",
        "include/(SKSE/**.h)"
    )

    -- set precompiled header
    set_pcxxheader("include/SKSE/Impl/PCH.h")

    -- add defines
    add_defines("WIN32_LEAN_AND_MEAN", "NOMINMAX", "UNICODE", "_UNICODE")

    -- add flags
    add_cxxflags("/permissive-")

    on_config(function(target)
        if target:has_tool("cxx", "cl") then
            target:add("cxxflags", "/Zc:preprocessor", "/external:W0", "/bigobj")

            -- warnings -> errors
            target:add("cxxflags", "/we4715") -- `function` : not all control paths return a value

            -- disable warnings
            target:add("cxxflags", "/wd4005") -- macro redefinition
            target:add("cxxflags", "/wd4061") -- enumerator `identifier` in switch of enum `enumeration` is not explicitly handled by a case label
            target:add("cxxflags", "/wd4200") -- nonstandard extension used : zero-sized array in struct/union
            target:add("cxxflags", "/wd4201") -- nonstandard extension used : nameless struct/union
            target:add("cxxflags", "/wd4265") -- 'type': class has virtual functions, but its non-trivial destructor is not virtual; instances of this class may not be destructed correctly
            target:add("cxxflags", "/wd4266") -- 'function' : no override available for virtual member function from base 'type'; function is hidden
            target:add("cxxflags", "/wd4371") -- 'classname': layout of class may have changed from a previous version of the compiler due to better packing of member 'member'
            target:add("cxxflags", "/wd4514") -- 'function' : unreferenced inline function has been removed
            target:add("cxxflags", "/wd4582") -- 'type': constructor is not implicitly called
            target:add("cxxflags", "/wd4583") -- 'type': destructor is not implicitly called
            target:add("cxxflags", "/wd4623") -- 'derived class' : default constructor was implicitly defined as deleted because a base class default constructor is inaccessible or deleted
            target:add("cxxflags", "/wd4625") -- 'derived class' : copy constructor was implicitly defined as deleted because a base class copy constructor is inaccessible or deleted
            target:add("cxxflags", "/wd4626") -- 'derived class' : assignment operator was implicitly defined as deleted because a base class assignment operator is inaccessible or deleted
            target:add("cxxflags", "/wd4710") -- 'function' : function not inlined
            target:add("cxxflags", "/wd4711") -- function 'function' selected for inline expansion
            target:add("cxxflags", "/wd4820") -- 'bytes' bytes padding added after construct 'member_name'
            target:add("cxxflags", "/wd5026") -- 'type': move constructor was implicitly defined as deleted
            target:add("cxxflags", "/wd5027") -- 'type': move assignment operator was implicitly defined as deleted
            target:add("cxxflags", "/wd5045") -- compiler will insert Spectre mitigation for memory load if /Qspectre switch specified
            target:add("cxxflags", "/wd5053") -- support for 'explicit(<expr>)' in C++17 and earlier is a vendor extension
            target:add("cxxflags", "/wd5204") -- 'type-name': class has virtual functions, but its trivial destructor is not virtual; instances of objects derived from this class may not be destructed correctly
            target:add("cxxflags", "/wd5220") -- 'member': a non-static data member with a volatile qualified type no longer implies that compiler generated copy / move constructors and copy / move assignment operators are not trivial
        else
            -- disable warnings
            target:add("cxxflags", "-Wno-overloaded-virtual")
            target:add("cxxflags", "-Wno-delete-non-abstract-non-virtual-dtor")
            target:add("cxxflags", "-Wno-reinterpret-base-class")
        end
    end)
