package("rust")
    set_kind("toolchain")
    set_homepage("https://rust-lang.org")
    set_description("Rust is a general-purpose programming language emphasizing performance, type safety, and concurrency.")

    add_versions("1.86.0", "")

    add_deps("ca-certificates", {host = true, private = true})
    add_deps("rustup", {host = true, private = true, system = false})

    add_configs("target_plat", {description = "Target platform (for cross-compilation)", default = nil, type = "string"})
    add_configs("target_arch", {description = "Target arch (for cross-compilation)", default = nil, type = "string"})
    if is_plat("cross") then
        add_configs("target_system", {description = "Target system (for cross-compilation)", default = "unknown-linux", type = "string"})
        add_configs("target_abi", {description = "Target ABI (for cross-compilation)", default = "gnu", type = "string"})
    end

    on_load(function (package)
        if package:config("target_plat") == nil then
            package:config_set("target_plat", package:plat())
        end
        if package:config("target_arch") == nil then
            package:config_set("target_arch", package:arch())
        end
    end)

    on_install(function (package)
        import("core.tools.rustc.target_triple", {try = true}) -- introduced in xmake 3.0.0

        local plat = package:config("target_plat")
        local arch = package:config("target_arch")

        if not target_triple then
            if plat == "mingw" or plat == "msys" then
                plat = "windows"
            end
            local package_plat = package:plat()
            if package_plat == "mingw" or package_plat == "msys" then
                package_plat = "windows"
            end
            if plat ~= package_plat or arch ~= package:arch() then
                os.raise("rust cross-compilation requires xmake dev or xmake 3.0.0")
            end
        end

        local rustup = assert(os.getenv("RUSTUP_HOME"), "cannot find rustup home!")
        local version = package:version():shortstr()

        local toolchain_name = version
        local toolchain_dir

        if target_triple then
            local host_target = assert(target_triple(package:plat(), package:arch()), "failed to build target triple for plat/arch, if you think this is a bug please create an issue")
            toolchain_name = toolchain_name .. "-" .. host_target
            toolchain_dir = toolchain_name
        elseif package:is_plat("msys", "mingw") and is_host("windows") then
            -- we have to handle mingw case because rustup will install a msvc toolchain by default on Windows
            toolchain_name = toolchain_name .. (package:is_arch("i386") and "-x86_64-pc-windows-gnu" or "-i686-pc-windows-gnu")
            toolchain_dir = toolchain_name
        else
            toolchain_dir = toolchain_name .. "-*"
        end
        os.vrunv("rustup", {"install", "--no-self-update", toolchain_name})

        if target_triple or package:is_plat("cross") then
            local target
            if package:is_plat("cross") then
                local system = package:config("target_system")
                local abi = package:config("target_abi")
                target = arch .. "-" .. system .. "-" .. abi
            else
                target = assert(target_triple(plat, arch), "failed to build target triple for target_plat/target_arch, if you think this is a bug please create an issue")
            end

            if target ~= host_target then
                os.vrunv("rustup", {"target", "add", target})
            end
        end

        os.vmv(path.join(rustup, "toolchains", toolchain_dir, "*"), package:installdir())

        -- cleanup to prevent rustup to think the toolchain is still installed
        os.vrm(path.join(rustup, "toolchains", toolchain_dir))
        os.vrm(path.join(rustup, "update-hashes", toolchain_dir))

        package:addenv("RC", "bin/rustc" .. (is_host("windows") and ".exe" or ""))
        package:mark_as_pathenv("RC")
    end)

    on_test(function (package)
        os.vrun("cargo --version")
        os.vrun("rustc --version")
    end)
