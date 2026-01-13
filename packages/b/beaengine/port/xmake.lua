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

add_requires("zlib")

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
        local suffix = ""
        local kind = target:kind()

        if kind == "shared" then
            target:add("defines", "BUILD_BEA_ENGINE_DLL")
        else
            target:add("defines", "BEA_ENGINE_STATIC")
            suffix = suffix .. "_s"
        end

        if is_mode("debug") then 
            suffix = suffix .. "_d"
        end

        if not has_config("lite") then 
            suffix = suffix .. "_l" 
        end

        if has_config("stdcall") then 
            suffix = suffix .. "_stdcall" 
        end

        if target:is_arch("x64", "x86_64") then 
            suffix = suffix .. "_64" 
        end

        target:set("suffixname", suffix)
    end)
