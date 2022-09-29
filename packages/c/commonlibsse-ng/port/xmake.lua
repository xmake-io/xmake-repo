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

-- set policies
set_policy("build.optimization.lto", true)

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
    if is_plat("windows") then
        add_defines("WIN32_LEAN_AND_MEAN", "NOMINMAX", "UNICODE", "_UNICODE")
    end

    -- add flags
    if is_plat("windows") then
        add_cxflags("/permissive-", "/EHsc", "/W4", "/WX")
        add_cxflags("/MP", "/Zc:preprocessor", "/external:anglebrackets", "/external:W0", "/bigobj")
    end

    -- warnings -> errors
    add_cxflags("/we4715") -- `function` : not all control paths return a value

    -- disable warnings
    add_cxflags("/wd4005") -- macro redefinition
    add_cxflags("/wd4061") -- enumerator `identifier` in switch of enum `enumeration` is not explicitly handled by a case label
    add_cxflags("/wd4200") -- nonstandard extension used : zero-sized array in struct/union
    add_cxflags("/wd4201") -- nonstandard extension used : nameless struct/union
    add_cxflags("/wd4265") -- 'type': class has virtual functions, but its non-trivial destructor is not virtual; instances of this class may not be destructed correctly
    add_cxflags("/wd4266") -- 'function' : no override available for virtual member function from base 'type'; function is hidden
    add_cxflags("/wd4371") -- 'classname': layout of class may have changed from a previous version of the compiler due to better packing of member 'member'
    add_cxflags("/wd4514") -- 'function' : unreferenced inline function has been removed
    add_cxflags("/wd4582") -- 'type': constructor is not implicitly called
    add_cxflags("/wd4583") -- 'type': destructor is not implicitly called
    add_cxflags("/wd4623") -- 'derived class' : default constructor was implicitly defined as deleted because a base class default constructor is inaccessible or deleted
    add_cxflags("/wd4625") -- 'derived class' : copy constructor was implicitly defined as deleted because a base class copy constructor is inaccessible or deleted
    add_cxflags("/wd4626") -- 'derived class' : assignment operator was implicitly defined as deleted because a base class assignment operator is inaccessible or deleted
    add_cxflags("/wd4710") -- 'function' : function not inlined
    add_cxflags("/wd4711") -- function 'function' selected for inline expansion
    add_cxflags("/wd4820") -- 'bytes' bytes padding added after construct 'member_name'
    add_cxflags("/wd5026") -- 'type': move constructor was implicitly defined as deleted
    add_cxflags("/wd5027") -- 'type': move assignment operator was implicitly defined as deleted
    add_cxflags("/wd5045") -- compiler will insert Spectre mitigation for memory load if /Qspectre switch specified
    add_cxflags("/wd5053") -- support for 'explicit(<expr>)' in C++17 and earlier is a vendor extension
    add_cxflags("/wd5204") -- 'type-name': class has virtual functions, but its trivial destructor is not virtual; instances of objects derived from this class may not be destructed correctly
    add_cxflags("/wd5220") -- 'member': a non-static data member with a volatile qualified type no longer implies that compiler generated copy / move constructors and copy / move assignment operators are not trivial
