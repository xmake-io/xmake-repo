add_rules("mode.debug", "mode.release")

option("stdcall")
    set_default(false)
    set_description("Build using stdcall")
    add_defines("BEA_USE_STDCALL")
option_end()

option("lite")
    set_default(false)
    set_description("Build without text disassembly")
    add_defines("BEA_LIGHT_DISASSEMBLY")
option_end()

add_requires("zlib", {optional = true})

target("BeaEngine")
    set_languages("c99")
    set_kind("$(kind)")

    add_files("src/BeaEngine.c")
    add_includedirs("include", "src")
    add_headerfiles("include/(beaengine/*.h)")

    add_packages("zlib")

    set_warnings("all", "extra")

    if is_plat("windows") then
        add_defines("_CRT_SECURE_NO_WARNINGS")
        add_defines("BEA_LACKS_SNPRINTF")
    end

    on_config(function (target)
        local name = "BeaEngine"
        local kind = target:kind()

        if kind == "shared" then
            target:add("defines", "BUILD_BEA_ENGINE_DLL")
        else
            target:add("defines", "BEA_ENGINE_STATIC")
            name = name .. "_s"
        end

        if is_mode("debug") then 
            name = name .. "_d" 
        end

        if not has_config("lite") then 
            name = name .. "_l" 
        end

        if has_config("stdcall") then 
            name = name .. "_stdcall" 
        end

        if target:is_arch("x64", "x86_64") then 
            name = name .. "_64" 
        end

        target:set("basename", name)
    end)
