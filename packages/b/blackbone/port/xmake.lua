add_rules("mode.debug", "mode.release")

target("BlackBone")
    set_kind("static")
    set_languages("c++17")
    add_defines("BLACKBONE_STATIC", "UNICODE", "_UNICODE", "WIN32_LEAN_AND_MEAN",
                "_CRT_SECURE_NO_WARNINGS", "_SCL_SECURE_NO_WARNINGS")
    -- Some upstream comments use a legacy encoding.
    add_cxflags("/utf-8", "/wd4828", "/FS")
    add_includedirs("src")
    add_files("src/BlackBone/**.cpp", "src/BlackBone/Asm/LDasm.c")
    remove_files("src/BlackBone/DllMain.cpp")
    add_files("src/3rd_party/AsmJit/base/*.cpp", "src/3rd_party/AsmJit/x86/*.cpp")
    add_files("src/3rd_party/rewolf-wow64ext/src/wow64ext.cpp")
    add_headerfiles("src/(BlackBone/**.h)", "src/(BlackBone/**.hpp)", "src/(3rd_party/**.h)")
    add_headerfiles("src/(BlackBoneDrv/BlackBoneDef.h)")

    if is_arch("x64") then
        add_files("src/BlackBone/Syscalls/Syscall64.asm")
        add_installfiles("src/3rd_party/DIA/lib/amd64/diaguids.lib", {prefixdir = "lib"})
        add_installfiles("DIA/x64/*.dll", {prefixdir = "bin"})
    else
        add_files("src/BlackBone/Syscalls/Syscall32.asm")
        add_asflags("/safeseh")
        add_installfiles("src/3rd_party/DIA/lib/diaguids.lib", {prefixdir = "lib"})
        add_installfiles("DIA/Win32/*.dll", {prefixdir = "bin"})
    end
