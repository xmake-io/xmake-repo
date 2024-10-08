add_rules("mode.debug", "mode.release")
set_languages("c++17")
add_requires("capstone", "keystone")
add_packages("capstone", "keystone")

target("libmem")
    set_kind("$(kind)")

    add_includedirs("include")
    add_includedirs(
        "external/llvm/include",
        "src/common",
        "internal",
        "src"
    )

    add_files(
        "src/common/*.c",
        "src/common/*.cpp",
        "src/common/arch/*.c",
        "internal/demangler/*.cpp",
        "external/llvm/lib/Demangle/*.cpp"
    )

    if is_plat("linux", "bsd") then
        add_syslinks("dl", "stdc++", "m")
        if is_plat("bsd") then
            add_syslinks("kvm", "procstat", "elf")
        end

        add_files("internal/posixutils/*.c")
        add_files("internal/elfutils/*.c")

        local arch = (is_arch("x86_64", "x64") and "x64" or "x86")
        local prefix = path.join("src", is_plat("linux") and "linux" or "freebsd")
        add_files(path.join(prefix, "ptrace", "*.c"))
        add_files(path.join(prefix, "*.c"))

        add_files(path.join(prefix, "ptrace", arch, "*.c"))
    elseif is_plat("windows") then
        add_syslinks("user32", "psapi", "ntdll", "shell32")
        add_files("internal/winutils/*.c")
        add_files("src/win/*.c")
    end
    if is_plat("windows") then
        add_defines("LM_EXPORT")
    end
