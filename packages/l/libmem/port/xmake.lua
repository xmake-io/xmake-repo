add_rules("mode.debug", "mode.release")
set_languages("c++17")

add_requires("capstone", "keystone")

target("libmem")
    set_kind("$(kind)")

    if is_plat("windows") and is_kind("shared") then
        add_rules("utils.symbols.export_all", {export_classes = true, export_filter = function (symbol)
            if symbol:find("libmem", 1, true) then
                return true
            end
        end})
    end
    if is_plat("windows") or is_kind("shared") then
        add_defines("LM_EXPORT")
    end

    add_packages("capstone", "keystone")
    
    add_headerfiles("include/(libmem/*.h)")
    add_headerfiles("include/(libmem/*.hpp)")

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
    
    elseif is_plat("windows", "mingw") then
        add_syslinks("user32", "psapi", "ntdll", "shell32", "ole32")
        if is_plat("mingw") then
            add_syslinks("uuid")
        end
        add_files("internal/winutils/*.c")
        add_files("src/win/*.c")
    end
