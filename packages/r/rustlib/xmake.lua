package("rustlib")
    set_kind("template")
    set_description("Template to help with Rust libraries in xrepo")
 
    on_load(function (package)
        local toolchainconfigs = {}
        toolchainconfigs.target_plat = package:plat()
        toolchainconfigs.target_arch = package:arch()

        if package:is_plat("cross") then
            -- detect cross configuration from the compiler, if possible
            local compiler, toolname = package:tool("cc")
            if toolname == "clang" or toolname == "gcc" then
                local outdata, errdata = os.iorunv(compiler, {"-v"})
                local output = #outdata:trim() > 0 and outdata or errdata
                local target = output:match("Target: ([^\r\n]*)")
                if target then
                    if toolname == "gcc" then
                        target = target:replace("-none-", "-unknown-", {plain = true})
                    end
                    package:data_set("cross_target", target)
                    local parts = target:split("-", {plain = true})
                    if #parts >= 3 then
                        toolchainconfigs.target_arch = parts[1]
                        toolchainconfigs.target_system = table.concat(parts, "-", 2, #parts - 1)
                        toolchainconfigs.target_abi = parts[#parts]
                    end
                end
            end
        end

        package:add("deps", "rust", {configs = toolchainconfigs})
    end)

    on_check("mingw|i386", function (package)
        -- MinGW 32bits exception model must match rustc LLVM exception model (dwarf2)
        local mingw = package:toolchain("mingw")
        if not mingw then
            return
        end

        local compiler, toolname = mingw:tool("cc")
        if toolname ~= "gcc" then
            return
        end

        local output, errdata = os.iorunv(compiler, {"-v"})
        -- for some reason the output is in stderr
        if #output:trim() == 0 then
            output = errdata
        end
        assert(output:find("--with-dwarf2", 1, true), "rustc is only compatible with dwarf2 exception model in 32bits mode, please use dwarf2 MinGW")
    end)

    on_install(function (package)
        -- pass rust toolchain configuration
        local rust = package:dep("rust")
        local rcfile_path = os.tmpfile() .. ".lua"
        local rcfile = io.open(rcfile_path, 'w')
        rcfile:print("add_requires(\"rust\", %s)", string.serialize(rust:requireinfo(), {strip = true, indent = false}))
        local cross_target = package:data("cross_target")
        if cross_target then
            rcfile:print("add_requireconfs(\"cargo::naga\", {arch = \"%s\", override = true})", cross_target)
            rcfile:print("add_rcflags(\"--target=%s\")", cross_target)
        end
        rcfile:close()

        local envs = import("package.tools.xmake").buildenvs(package)
        table.insert(envs.XMAKE_RCFILES, rcfile_path)

        return envs
    end)
