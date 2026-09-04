add_rules("mode.debug", "mode.release")
add_requires("asmjit 2014.12.01", "beaengine", {configs = {shared = false}})
if is_arch("x86") then
    add_requires("rewolf-wow64ext 2022.09.26", {configs = {shared = false}})
end
add_requires("diasdk", {system = true})

target("BlackBone")
    set_kind("static")
    set_languages("c++17")
    add_packages("asmjit", "beaengine", "diasdk")
    if is_arch("x86") then
        add_packages("rewolf-wow64ext")
    end
    add_defines("BLACKBONE_STATIC", "UNICODE", "_UNICODE", "WIN32_LEAN_AND_MEAN",
                "_CRT_SECURE_NO_WARNINGS", "_SCL_SECURE_NO_WARNINGS")
    -- Some upstream comments use a legacy encoding.
    add_cxflags("/utf-8", "/wd4828", "/FS")
    add_includedirs("src")
    add_files("src/BlackBone/**.cpp", "src/BlackBone/Asm/LDasm.c")
    remove_files("src/BlackBone/DllMain.cpp")
    add_headerfiles("src/(BlackBone/**.h)", "src/(BlackBone/**.hpp)")
    add_headerfiles("src/(BlackBoneDrv/BlackBoneDef.h)")
    if is_arch("x64") then
        add_files("src/BlackBone/Syscalls/Syscall64.asm")
        remove_files("src/BlackBone/Subsystem/Wow64Subsystem.cpp")
    else
        add_files("src/BlackBone/Syscalls/Syscall32.asm")
        add_asflags("/safeseh")
    end
