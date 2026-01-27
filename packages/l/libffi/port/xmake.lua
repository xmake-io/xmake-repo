set_project("libffi")

add_rules("mode.debug", "mode.release")

add_rules("utils.install.cmake_importfiles")

set_configvar("PACKAGE", "libffi")
set_configvar("PACKAGE_NAME", "libffi")
set_configvar("PACKAGE_TARNAME", "libffi")
set_configvar("PACKAGE_BUGREPORT", "")
set_configvar("PACKAGE_URL", "")

option("vers")
    set_default("3.4.2")
    set_showmenu(true)
option_end()
if has_config("vers") then
    set_version(get_config("vers"))
    set_configvar("VERSION", get_config("vers"))
    set_configvar("PACKAGE_VERSION", get_config("vers"))
    set_configvar("PACKAGE_STRING", "libffi " .. get_config("vers"))
end

local targetarch = is_plat("windows") and "X86_WIN64" or "X86_64"
if is_plat("windows") then
    if is_arch("x86") then
        targetarch = "X86_WIN32"
    elseif is_arch("x64") then
        targetarch = "X86_WIN64"
    elseif is_arch("arm") then
        targetarch = "ARM_WIN32"
    elseif is_arch("arm64") then
        targetarch = "ARM_WIN64"
    end
elseif is_plat("macosx") and is_arch("i386", "x86") then
    targetarch = "X86_DARWIN"
elseif is_plat("bsd") and is_arch("i386", "x86") then
    targetarch = "X86_FREEBSD"
else
    if is_arch("i386", "x86") then
        targetarch = "X86"
    elseif is_arch("x64") then
        targetarch = "X86_64"
    elseif is_arch("arm") then
        targetarch = "ARM"
    elseif is_arch("arm64") then
        targetarch = "ARM64"
    elseif is_arch("mips64") then
        targetarch = "MIPS64"
    elseif is_arch("riscv") then
        targetarch = "RISCV"
    end
end
set_configvar("TARGET", targetarch)

includes("@builtin/check")

set_configvar("STDC_HEADERS", 1)
set_configvar("LT_OBJDIR", ".libs/")
configvar_check_cincludes("HAVE_INTTYPES_H", "inttypes.h")
configvar_check_cincludes("HAVE_MEMORY_H", "memory.h")
configvar_check_cincludes("HAVE_STDINT_H", "stdint.h")
configvar_check_cincludes("HAVE_STDLIB_H", "stdlib.h")
configvar_check_cincludes("HAVE_STRINGS_H", "strings.h")
configvar_check_cincludes("HAVE_STRING_H", "string.h")
configvar_check_cincludes("HAVE_SYS_STAT_H", "sys/stat.h")
configvar_check_cincludes("HAVE_SYS_TYPES_H", "sys/types.h")
configvar_check_cincludes("HAVE_ALLOCA_H", "alloca.h")
configvar_check_cfuncs("HAVE_ALLOCA", "alloca", {includes = "alloca.h"})
configvar_check_csnippets("HAVE_LONG_DOUBLE", [[assert(sizeof(long double) > sizeof(double));]], {includes = "assert.h", tryrun = true, default = 0})
configvar_check_csnippets("SIZEOF_DOUBLE", [[printf("%d", sizeof(double));]], {tryrun = true, output = true, number = true})
configvar_check_csnippets("SIZEOF_LONG_DOUBLE", [[printf("%d", sizeof(long double));]], {tryrun = true, output = true, number = true})
configvar_check_csnippets("SIZEOF_SIZE_T", [[printf("%d", sizeof(size_t));]], {tryrun = true, output = true, number = true})
if not is_plat("windows") then
    set_configvar("HAVE_AS_X86_PCREL", 1)
end
if is_plat("macosx") then
    set_configvar("SYMBOL_UNDERSCORE", 1)
end
if is_plat("linux", "android") then
    set_configvar("HAVE_HIDDEN_VISIBILITY_ATTRIBUTE", 1)
    set_configvar("EH_FRAME_FLAGS", "a")
end
if is_plat("macosx") and is_arch("arm64") then
    set_configvar("FFI_EXEC_TRAMPOLINE_TABLE", 1)
else
    set_configvar("FFI_EXEC_TRAMPOLINE_TABLE", 0)
end

rule("asm.preprocess")
    set_extensions(".S")
    on_buildcmd_file(function (target, batchcmds, sourcefile, opt)
        import("lib.detect.find_tool")

        local rootdir = path.join(target:autogendir(), "rules", "asm.preprocess")
        local filename = path.basename(sourcefile) .. ".asm"
        local sourcefile_or = path.absolute(sourcefile)
        local sourcefile_cx = target:autogenfile(sourcefile, {rootdir = rootdir, filename = filename})

        -- preprocessing
        local envs = target:toolchain("msvc"):runenvs()
        local cl = find_tool("cl", {envs = envs})
        batchcmds:execv(cl.program, {"/nologo", "/EP", "/Iinclude",
            "/I" .. path.directory(sourcefile_or), sourcefile_or}, {envs = envs, stdout = sourcefile_cx})

        local objectfile = target:objectfile(sourcefile_cx)
        table.insert(target:objectfiles(), objectfile)

        batchcmds:show_progress(opt.progress, "${color.build.object}compiling.$(mode) %s", sourcefile_cx)
        batchcmds:compile(sourcefile_cx, objectfile)

        batchcmds:add_depfiles(sourcefile)
        batchcmds:set_depmtime(os.mtime(objectfile))
        batchcmds:set_depcache(target:dependfile(objectfile))
    end)
rule_end()
if is_plat("windows") then
    add_rules("asm.preprocess", {override = true})
end

target("ffi")
    set_kind("$(kind)")
    if is_plat("windows") and is_kind("shared") then
        add_defines("FFI_BUILDING_DLL")
    end
    if is_kind("static") then
        add_defines("FFI_STATIC_BUILD")
    end
    set_configdir("include")
    add_configfiles("fficonfig.h.in")
    add_configfiles("include/ffi.h.in", {pattern = "@(.-)@"})
    add_includedirs("include")
    add_headerfiles("include/ffi.h")
    add_files("src/prep_cif.c", "src/types.c", "src/closures.c", "src/tramp.c")
    if not is_arch("arm") and not is_arch("arm64") then
        add_files("src/raw_api.c", "src/java_raw_api.c")
    end
    if is_plat("windows") and is_arch("x86") then
        add_asflags("/GZ")
    end
    if is_arch("i386", "x86") then
        add_files("src/x86/ffi.c")
        add_files(is_plat("windows") and "src/x86/sysv_intel.S" or "src/x86/sysv.S")
        add_includedirs("src/x86")
        add_headerfiles("src/x86/ffitarget.h")
    elseif is_arch("x86_64") then
        add_files("src/x86/ffi64.c", "src/x86/unix64.S", "src/x86/ffiw64.c", "src/x86/win64.S")
        add_includedirs("src/x86")
        add_headerfiles("src/x86/ffitarget.h")
    elseif is_arch("x64") then
        add_files("src/x86/ffi64.c", "src/x86/ffiw64.c", "src/x86/win64_intel.S")
        add_includedirs("src/x86")
        add_headerfiles("src/x86/ffitarget.h")
    elseif is_arch("arm") then
        add_files("src/arm/ffi.c")
        add_files(is_plat("windows") and "src/arm/sysv_msvc_arm32.S" or "src/arm/sysv.S")
        add_includedirs("src/arm")
        add_headerfiles("src/arm/ffitarget.h")
    elseif is_arch("arm64") then
        add_files("src/aarch64/ffi.c")
        add_files(is_plat("windows") and "src/aarch64/win64_armasm.S" or "src/aarch64/sysv.S")
        add_includedirs("src/aarch64")
        add_headerfiles("src/aarch64/ffitarget.h")
    elseif is_arch("mips64") then
        add_files("src/mips/ffi.c", "src/mips/n32.S")
        add_headerfiles("src/mips/ffitarget.h")
    elseif is_arch("riscv") then
        add_files("src/riscv/ffi.c", "src/riscv/sysv.S")
        add_headerfiles("src/riscv/ffitarget.h")
    elseif is_arch("wasm32") then
        add_files("src/wasm32/ffi.c")
        add_headerfiles("src/wasm32/ffitarget.h")
    end

    if is_plat("android") and is_arch("arm.*") then
        if is_arch("arm64.*") then
            add_files("src/aarch64/ffi.c")
            add_files(is_plat("windows") and "src/aarch64/win64_armasm.S" or "src/aarch64/sysv.S")
            add_includedirs("src/aarch64")
            add_headerfiles("src/aarch64/ffitarget.h")
        else
            add_files("src/arm/ffi.c")
            add_files(is_plat("windows") and "src/arm/sysv_msvc_arm32.S" or "src/arm/sysv.S")
            add_includedirs("src/arm")
            add_headerfiles("src/arm/ffitarget.h")
        end
    end

    before_build(function (target)
        import("core.base.semver")
        if semver.compare(target:version(), "v3.4.4") <= 0 then
            io.replace("include/ffi.h", "!defined FFI_BUILDING", target:is_static() and "0" or "1", {plain = true})
        end
    end)
