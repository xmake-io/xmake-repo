add_rules("mode.debug", "mode.release")
set_languages("c17", "c++20")

add_requires("capstone")
add_requires("keystone")

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

local arch = (is_arch("x86_64") and "x64" or "x86")
-- Add source files based on platform
local libmem_src = {
    path.join(common_dir, "*.c"),
    path.join(common_dir, "*.cpp"),
    path.join(common_dir, "arch/*.c"),
    path.join(internal_dir, "demangler/*.cpp"),
    path.join(llvm_dir, "lib/Demangle/*.cpp")
}

if is_plat("linux") or is_plat("freebsd") then
    table.insert(libmem_src, path.join(internal_dir, "posixutils/*.c"))
    table.insert(libmem_src, path.join(internal_dir, "elfutils/*.c"))
    table.insert(libmem_src, path.join(common_dir, "arch/x86.c"))
end


if is_plat("windows") then
    table.insert(libmem_src, path.join(libmem_dir, "src/win/*.c"))
    table.insert(libmem_src, path.join(internal_dir, "winutils/*.c"))
elseif is_plat("linux") then
    table.insert(libmem_src, path.join(libmem_dir, "src/linux/ptrace/*.c"))
    table.insert(libmem_src, path.join(libmem_dir, "src/linux/*.c"))

    table.insert(libmem_src, path.join(libmem_dir, "src/linux/ptrace/".. arch .. "/*.c"))
elseif is_plat("freebsd") then
    table.insert(libmem_src, path.join(libmem_dir, "src/freebsd/ptrace/*.c"))
    table.insert(libmem_src, path.join(libmem_dir, "src/freebsd/*.c"))

    table.insert(libmem_src, path.join(libmem_dir, "src/freebsd/ptrace/".. arch .. "/*.c"))
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

    -- Define for export symbol
    add_defines("LM_EXPORT")
