add_rules("mode.debug", "mode.release")
set_languages("c17", "c++20")

add_requires("capstone", {configs = {shared = true}})
add_requires("keystone", {configs = {shared = true}})

add_headerfiles("include/(libmem/**.h)")
add_headerfiles("include/(libmem/**.hpp)")
if is_plat("windows") then
    set_toolset("make", "nmake") -- Use NMAKE as the make tool
end

set_arch(os.arch())

-- Set Capstone, Keystone, and LLVM directories (adjust as needed)
local external_dependencies_dir = path.join(os.projectdir(), "external")
local llvm_dir = path.join(external_dependencies_dir, "llvm")

-- Set external dependencies
add_includedirs(path.join(llvm_dir, "include"))

-- Define source directories
local libmem_dir = os.projectdir()
local internal_dir = path.join(libmem_dir, "internal")
local common_dir = path.join(libmem_dir, "src", "common")

-- Add source files based on platform
local libmem_src = {}

if is_plat("windows") then
    libmem_src = {
        path.join(libmem_dir, "src/win/*.c"),
        path.join(common_dir, "*.c"),
        path.join(common_dir, "*.cpp"),
        path.join(common_dir, "arch/*.c"),
        path.join(internal_dir, "winutils/*.c"),
        path.join(internal_dir, "demangler/*.cpp"),
        path.join(llvm_dir, "lib/Demangle/*.cpp")
    }
elseif is_plat("linux") then
    if is_arch("x86_64") then
        libmem_src = {
            path.join(common_dir, "arch/x86.c"),
            path.join(libmem_dir, "src/linux/ptrace/x64/*.c"),
            path.join(libmem_dir, "src/linux/*.c"),
            path.join(common_dir, "*.c"),
            path.join(common_dir, "*.cpp"),
            path.join(internal_dir, "posixutils/*.c"),
            path.join(internal_dir, "elfutils/*.c"),
            path.join(internal_dir, "demangler/*.cpp")
        }
    elseif is_arch("i386") then
        libmem_src = {
            path.join(common_dir, "arch/x86.c"),
            path.join(libmem_dir, "src/linux/ptrace/x86/*.c"),
            path.join(libmem_dir, "src/linux/*.c"),
            path.join(common_dir, "*.c"),
            path.join(common_dir, "*.cpp"),
            path.join(internal_dir, "posixutils/*.c"),
            path.join(internal_dir, "elfutils/*.c"),
            path.join(internal_dir, "demangler/*.cpp")
        }
    end
elseif is_plat("freebsd") then
    if is_arch("x86_64") then
        libmem_src = {
            path.join(common_dir, "arch/x86.c"),
            path.join(libmem_dir, "src/freebsd/ptrace/x64/*.c"),
            path.join(libmem_dir, "src/freebsd/*.c"),
            path.join(common_dir, "*.c"),
            path.join(common_dir, "*.cpp"),
            path.join(internal_dir, "posixutils/*.c"),
            path.join(internal_dir, "elfutils/*.c"),
            path.join(internal_dir, "demangler/*.cpp")
        }
    elseif is_arch("i386") then
        libmem_src = {
            path.join(common_dir, "arch/x86.c"),
            path.join(libmem_dir, "src/freebsd/ptrace/x86/*.c"),
            path.join(libmem_dir, "src/freebsd/*.c"),
            path.join(common_dir, "*.c"),
            path.join(common_dir, "*.cpp"),
            path.join(internal_dir, "posixutils/*.c"),
            path.join(internal_dir, "elfutils/*.c"),
            path.join(internal_dir, "demangler/*.cpp")
        }
    end
end

-- Add target for libmem
target("libmem")
    
    set_kind("$(kind)")
    add_packages("capstone", "keystone")
    add_files(libmem_src)
    
    -- Correct the include directory to point to "include"
    add_includedirs(path.join(libmem_dir, "include"), { public = true })
    add_includedirs(path.join(libmem_dir, "src"))
    add_includedirs(internal_dir)
    add_includedirs(common_dir)

    -- Platform-specific dependencies
    if is_plat("windows") then
        add_syslinks("user32", "psapi", "ntdll", "shell32")
    elseif is_plat("linux") then
        add_syslinks("dl", "stdc++", "m")
    elseif is_plat("freebsd") then
        add_syslinks("dl", "kvm", "procstat", "elf", "stdc++", "m")
    end

    -- Link against external libraries
    add_links("capstone", "keystone")

    -- Define for export symbol
    add_defines("LM_EXPORT")
