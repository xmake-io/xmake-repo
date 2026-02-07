set_xmakever("2.5.5")

set_policy("build.across_targets_in_parallel", false)

option("nojit")
    set_default(false)
    set_showmenu(true)
    add_defines("LUAJIT_DISABLE_JIT", "LUAJIT_DISABLE_FFI")

option("fpu")
    set_default(true)
    set_showmenu(true)
    add_defines("LJ_ARCH_HASFPU=1", "LJ_ABI_SOFTFP=0")

option("gc64")
    set_default(false)
    set_showmenu(true)

-- Host Target: minilua
target("minilua")
    set_kind("binary")
    set_plat(os.host())
    if is_arch("x86", "i386") then
        set_arch("x86")
    else
        set_arch(os.arch())
    end
    add_files("src/host/minilua.c")
    if is_host("windows") then
        add_defines("_CRT_SECURE_NO_DEPRECATE")
    else
        add_syslinks("m")
    end

-- Phony Target: buildvm_headers (Generate buildvm_arch.h and luajit.h)
target("buildvm_headers")
    set_kind("phony")
    add_deps("minilua")

    on_build(function (target)
        local minilua = target:dep("minilua"):targetfile()
        if not path.is_absolute(minilua) then minilua = path.absolute(minilua) end

        local outputdir = target:objectdir()
        if not path.is_absolute(outputdir) then outputdir = path.absolute(outputdir) end
        if not os.isdir(outputdir) then os.mkdir(outputdir) end

        local defines = {}
        if target:is_plat("windows", "mingw") then
            table.insert(defines, "-D"); table.insert(defines, "WIN")
        end

        local dasc = "src/vm_x86.dasc"
        if target:is_arch("x64", "x86_64") then
            dasc = "src/vm_x64.dasc"
            table.insert(defines, "-D"); table.insert(defines, "P64")
            if has_config("gc64") then
                table.insert(defines, "-D"); table.insert(defines, "JIT")
                table.insert(defines, "-D"); table.insert(defines, "FFI")
            end
        elseif target:is_arch("arm64", "arm64-v8a") then
            dasc = "src/vm_arm64.dasc"
            table.insert(defines, "-D"); table.insert(defines, "P64")
            table.insert(defines, "-D"); table.insert(defines, "FPU")
            if target:is_plat("windows", "mingw") then
                table.insert(defines, "-D"); table.insert(defines, "ENDIAN_LE")
            end
        elseif target:is_arch("arm.*") then
            dasc = "src/vm_arm.dasc"
            if target:opt("fpu") then
                table.insert(defines, "-D"); table.insert(defines, "FPU")
                table.insert(defines, "-D"); table.insert(defines, "HFABI")
            end
        elseif target:is_arch("mips64") then
            dasc = "src/vm_mips64.dasc"
            table.insert(defines, "-D"); table.insert(defines, "P64")
        elseif target:is_arch("mips") then
            dasc = "src/vm_mips.dasc"
        elseif target:is_arch("ppc") then
            dasc = "src/vm_ppc.dasc"
        end
        
        if not target:opt("nojit") and not target:is_plat("iphoneos", "watchos") then
            table.insert(defines, "-D"); table.insert(defines, "JIT")
            table.insert(defines, "-D"); table.insert(defines, "FFI")
        end
        
        local buildvm_arch_h = path.join(outputdir, "buildvm_arch.h")
        local flags = {"dynasm/dynasm.lua", "-LN"}
        for _, d in ipairs(defines) do table.insert(flags, d) end
        table.insert(flags, "-o")
        table.insert(flags, buildvm_arch_h)
        table.insert(flags, dasc)
        
        os.vrunv(minilua, flags)

        
        if not os.isfile(buildvm_arch_h) then
            raise("Failed to generate buildvm_arch.h")
        end
        
        if os.isfile("src/host/genversion.lua") then
            local luajit_h = path.join(outputdir, "luajit.h")
            if not path.is_absolute(luajit_h) then luajit_h = path.absolute(luajit_h) end
            local olddir = os.cd("src")
            
            if not os.isfile("luajit_relver.txt") then
                local version
                if os.isdir("../.git") then
                    try { function ()
                        version = os.iorunv("git", {"show", "-s", "--format=%ct"})
                    end }
                end
                if version then
                    version = version:match("^%s*(.-)%s*$")
                end
                if not version and os.isfile("../.relver") then
                    version = io.readfile("../.relver"):match("^%s*(.-)%s*$")
                end
                if not version then
                    version = os.time()
                end
                io.writefile("luajit_relver.txt", "" .. version)
            end

            os.vrunv(path.absolute(minilua, olddir), {"host/genversion.lua", "luajit_rolling.h", "luajit_relver.txt", luajit_h})
            os.cd(olddir)
        end
    end)

-- Host Target: buildvm
target("buildvm")
    set_kind("binary")
    set_plat(os.host())
    if is_arch("x86", "i386") then
        set_arch("x86")
    else
        set_arch(os.arch())
    end
    add_deps("minilua", "buildvm_headers")
    add_files("src/host/buildvm*.c")
    
    if is_host("windows") then
        add_defines("_CRT_SECURE_NO_DEPRECATE")
    else
        add_syslinks("m", "dl")
    end
    add_options("nojit", "fpu")
    
    on_load(function (target)
        if target:is_arch("x64", "x86_64") then
            target:add("defines", "LUAJIT_TARGET=LUAJIT_ARCH_X64")
        elseif target:is_arch("x86", "i386") then
            target:add("defines", "LUAJIT_TARGET=LUAJIT_ARCH_X86")
        elseif target:is_arch("arm64", "arm64-v8a") then
            target:add("defines", "LUAJIT_TARGET=LUAJIT_ARCH_ARM64")
        elseif target:is_arch("arm") then
            target:add("defines", "LUAJIT_TARGET=LUAJIT_ARCH_ARM")
        elseif target:is_arch("mips64") then
            target:add("defines", "LUAJIT_TARGET=LUAJIT_ARCH_MIPS64")
        elseif target:is_arch("mips") then
            target:add("defines", "LUAJIT_TARGET=LUAJIT_ARCH_MIPS")
        elseif target:is_arch("ppc") then
            target:add("defines", "LUAJIT_TARGET=LUAJIT_ARCH_PPC")
        end

        if target:is_plat("macosx", "iphoneos", "watchos") then
            target:add("defines", "LUAJIT_OS=LUAJIT_OS_OSX")
        elseif target:is_plat("windows", "mingw") then
            target:add("defines", "LUAJIT_OS=LUAJIT_OS_WINDOWS")
        elseif target:is_plat("linux", "android") then
            target:add("defines", "LUAJIT_OS=LUAJIT_OS_LINUX")
        elseif target:is_plat("bsd") then
            target:add("defines", "LUAJIT_OS=LUAJIT_OS_BSD")
        else
            target:add("defines", "LUAJIT_OS=LUAJIT_OS_OTHER")
        end
        
        target:add("includedirs", "src")
    end)

    after_load(function (target)
        -- Add buildvm_headers include dir
        local htag = target:dep("buildvm_headers")
        if htag then
            target:add("includedirs", path.absolute(htag:objectdir()))
        end
    end)

-- Phony Target: Generate LuaJIT Headers (using buildvm)
target("luajit_headers")
    set_kind("phony")
    add_deps("buildvm")
    
    on_build(function (target)
        local buildvm = target:dep("buildvm"):targetfile()
        if not path.is_absolute(buildvm) then buildvm = path.absolute(buildvm) end
        
        local outputdir = target:objectdir()
        if not os.isdir(outputdir) then os.mkdir(outputdir) end
        
        local headers = {"bcdef", "ffdef", "libdef", "recdef", "vmdef"}
        for _, m in ipairs(headers) do
            os.vrunv(buildvm, {"-m", m, "-o", path.join(outputdir, "lj_"..m..".h"), "src/lib_base.c", "src/lib_math.c", "src/lib_bit.c", "src/lib_string.c", "src/lib_table.c", "src/lib_io.c", "src/lib_os.c", "src/lib_package.c", "src/lib_debug.c", "src/lib_jit.c", "src/lib_ffi.c", "src/lib_buffer.c"})
        end
        
        -- lj_folddef.h
        os.vrunv(buildvm, {"-m", "folddef", "-o", path.join(outputdir, "lj_folddef.h"), "src/lj_opt_fold.c"})

        -- Generate VM assembly/obj
        if target:is_plat("windows", "mingw") then
            local lj_vm_obj = path.join(outputdir, "lj_vm.obj")
            os.vrunv(buildvm, {"-m", "peobj", "-o", lj_vm_obj})
        else
            local lj_vm_asm = path.join(outputdir, "lj_vm.S")
            local mode = "elfasm"
            if target:is_plat("macosx", "iphoneos") then mode = "machasm" end
            os.vrunv(buildvm, {"-m", mode, "-o", lj_vm_asm})
        end
    end)


-- Main Target: luajit
target("luajit")
    set_kind("$(kind)")
    add_deps("luajit_headers", "buildvm_headers")
    set_policy("build.fence", true)
    set_basename("luajit")
    
    on_load(function (target)
        if target:is_arch("x64", "x86_64") then
            target:add("defines", "LUAJIT_TARGET=LUAJIT_ARCH_X64")
        elseif target:is_arch("x86", "i386") then
            target:add("defines", "LUAJIT_TARGET=LUAJIT_ARCH_X86")
        elseif target:is_arch("arm64", "arm64-v8a") then
            target:add("defines", "LUAJIT_TARGET=LUAJIT_ARCH_ARM64")
        elseif target:is_arch("arm") then
            target:add("defines", "LUAJIT_TARGET=LUAJIT_ARCH_ARM")
        elseif target:is_arch("mips64") then
            target:add("defines", "LUAJIT_TARGET=LUAJIT_ARCH_MIPS64")
        elseif target:is_arch("mips") then
            target:add("defines", "LUAJIT_TARGET=LUAJIT_ARCH_MIPS")
        elseif target:is_arch("ppc") then
            target:add("defines", "LUAJIT_TARGET=LUAJIT_ARCH_PPC")
        end
        
        if target:is_plat("macosx", "iphoneos", "watchos") then
            target:add("defines", "LUAJIT_OS=LUAJIT_OS_OSX")
        elseif target:is_plat("windows", "mingw") then
            target:add("defines", "LUAJIT_OS=LUAJIT_OS_WINDOWS")
        elseif target:is_plat("linux", "android") then
            target:add("defines", "LUAJIT_OS=LUAJIT_OS_LINUX")
        elseif target:is_plat("bsd") then
            target:add("defines", "LUAJIT_OS=LUAJIT_OS_BSD")
        else
            target:add("defines", "LUAJIT_OS=LUAJIT_OS_OTHER")
        end
        
        if target:is_plat("windows") and target:kind() == "shared" then
            target:add("defines", "LUA_BUILD_AS_DLL", "_CRT_STDIO_INLINE=__declspec(dllexport)__inline")
        end
    end)

    add_options("nojit", "fpu")
    add_defines("LUAJIT_ENABLE_LUA52COMPAT")
    
    if is_plat("windows") then 
        add_defines("_CRT_SECURE_NO_DEPRECATE")
        if is_arch("arm64") then
             add_defines("LUAJIT_ENABLE_GC64")
        end
    end

    add_includedirs("src")
    add_headerfiles("src/lua.h", "src/lualib.h", "src/lauxlib.h", "src/luaconf.h", "src/lua.hpp", {prefix = "luajit"})
    add_files("src/ljamalg.c")

    if is_plat("linux", "macosx", "bsd") and is_arch("x86_64", "mips64") then
        add_defines("LUAJIT_UNWIND_EXTERNAL")
    end
    
    after_install(function (target)
        local htag = target:dep("buildvm_headers")
        local hdir = htag:objectdir()
        local luajit_h = path.join(hdir, "luajit.h")
        if os.isfile(luajit_h) then
             os.cp(luajit_h, path.join(target:installdir(), "include", "luajit", "luajit.h"))
        end
    end)

    before_build(function (target)
        import("core.tool.compiler")
        local htag = target:dep("luajit_headers")
        local hdir = htag:objectdir()
        
        if not target:is_plat("windows", "mingw") then
            local vm_s = path.join(hdir, "lj_vm.S")
            local vm_o = path.join(hdir, "lj_vm.o")
            if os.isfile(vm_s) then
                -- Force -fPIC for the assembly file to ensure it works in shared libs
                compiler.compile(vm_s, vm_o, {target = target, asflags = "-fPIC"})
                table.insert(target:objectfiles(), vm_o)
            end
        else
            local vm_o = path.join(hdir, "lj_vm.obj")
            if os.isfile(vm_o) then
                table.insert(target:objectfiles(), vm_o)
            end
        end
    end)

    after_load(function (target)
        local htag = target:dep("luajit_headers")
        local hdir = htag:objectdir()
        target:add("includedirs", path.absolute(hdir))

        local bhtag = target:dep("buildvm_headers")
        local bhdir = bhtag:objectdir()
        target:add("includedirs", path.absolute(bhdir))
    end)

target("luajit_bin")
    set_kind("binary")
    set_basename("luajit")
    add_deps("luajit")
    add_files("src/luajit.c")
    if is_plat("linux", "bsd", "android") then
        add_syslinks("m")
        if is_plat("linux", "android") then
            add_syslinks("dl")
        end
        add_ldflags("-Wl,-E")
    end
    after_load(function (target)
        local lib = target:dep("luajit")
        -- Add includedirs from headers target
        local htag = lib:dep("luajit_headers")
        local hdir = htag:objectdir()
        target:add("includedirs", path.absolute(hdir))
        local bhtag = lib:dep("buildvm_headers")
        local bhdir = bhtag:objectdir()
        target:add("includedirs", path.absolute(bhdir))
        target:add("includedirs", "src")
    end)

