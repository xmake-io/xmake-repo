add_rules("mode.debug", "mode.release")
set_languages("c++17")
add_requires("capstone", "keystone")

function get_libmem_arch()
    if is_arch("x86_64", "x64", "amd64") then
        return "x64"
    elseif is_arch("x86", "i386", "i686") then
        return "x86"
    elseif is_arch("arm64", "aarch64", "arm64-v8a") then
        return "aarch64"
    elseif is_arch("arm.*") then
        return "arm"
    else
        return "generic"
    end
end

local LIBMEM_ARCH = get_libmem_arch()

target("libmem")
    set_kind("$(kind)")

    add_packages("capstone", "keystone")

    add_headerfiles("include/(libmem/*.h)")
    add_headerfiles("include/(libmem/*.hpp)")
    add_includedirs("include", {public = true})

    add_includedirs(
        "external/llvm/include",
        "src/common",
        "internal",
        "src"
    )

    add_files(
        "src/common/*.c",
        "src/common/*.cpp",
        "internal/demangler/*.cpp",
        "external/llvm/lib/Demangle/*.cpp"
    )

    if is_arch("x86_64", "x64", "amd64", "x86", "i386", "i686") then
        add_files("src/common/arch/x86.c")
    elseif LIBMEM_ARCH == "aarch64" then
        add_files("src/common/arch/aarch64.c")
    elseif LIBMEM_ARCH == "arm" then
        add_files("src/common/arch/arm.c")
    else
        add_files("src/common/arch/generic.c")
    end
    
    if is_plat("windows", "mingw") then
        add_defines("alloca=_alloca")

        add_files("internal/winutils/*.c")
        add_files("src/win/*.c")

        add_syslinks("user32", "psapi", "ntdll", "shell32", "ole32")

        if is_plat("windows") and is_kind("shared") then
            add_rules("utils.symbols.export_all", {
                export_classes = true,
                export_filter = function(symbol)
                    return symbol:find("libmem", 1, true) ~= nil
                end
            })
        end

        if is_plat("mingw") then
            add_syslinks("uuid")
            add_cflags("-Wno-int-conversion", "-Wno-incompatible-pointer-types")
        end

    elseif is_plat("linux", "android") then
        add_files("internal/posixutils/*.c")
        add_files("internal/elfutils/*.c")
        add_files("src/linux/*.c")
        add_files("src/linux/ptrace/*.c")

        local ptrace_arch_map = {
            ["x64"] = "x64",
            ["x86"] = "x86", 
            ["aarch64"] = "aarch64",
        }
        local ptrace_arch = ptrace_arch_map[LIBMEM_ARCH] or "generic"

        add_files("src/linux/ptrace/" .. ptrace_arch .. "/*.c")

        if is_plat("linux") then
            add_syslinks("dl", "m")
        end
    
    elseif is_plat("bsd") then        
        add_files("internal/posixutils/*.c")
        add_files("internal/elfutils/*.c")
        add_files("src/freebsd/*.c")
        add_files("src/freebsd/ptrace/*.c")

        local ptrace_arch_map = {
            ["x64"] = "x64",
            ["x86"] = "x86",
        }
        local ptrace_arch = ptrace_arch_map[LIBMEM_ARCH] or "generic"
        add_files("src/freebsd/ptrace/" .. ptrace_arch .. "/*.c")

        add_syslinks("dl", "stdc++", "m", "kvm", "procstat", "elf")
    end

    if is_kind("static") then
        set_policy("build.merge_archive", true)
    end

    add_defines("LM_EXPORT")
