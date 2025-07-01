add_rules("mode.debug", "mode.release")
add_rules("utils.install.cmake_importfiles")
set_languages("c++11")

option("exceptions", {default = true})

target("angelscript")
    set_kind("shared")
    add_files("angelscript/source/*.cpp")
    add_headerfiles("angelscript/include/*.h")
    add_includedirs("angelscript/include")

    add_defines("ANGELSCRIPT_EXPORT")
    if not has_config("exceptions") then
        add_defines("AS_NO_EXCEPTIONS")
    end

    if is_plat("windows") then
        if is_arch("x64") then
            add_files("angelscript/source/as_callfunc_x64_msvc_asm.asm")
        elseif is_arch("arm64") then
            add_files("angelscript/source/as_callfunc_arm64_msvc.asm")
        -- elseif is_arch("arm32") then
        --     add_files("angelscript/source/as_callfunc_arm_msvc.asm")
        end
    else
        if is_arch("arm32") then
            add_files("angelscript/source/as_callfunc_arm_gcc.S")
        elseif is_arch("arm64") then
            add_files("angelscript/source/as_callfunc_arm64_gcc.S")
        end

        if is_plat("linux") then
            add_syslinks("pthread")
        end
    end
