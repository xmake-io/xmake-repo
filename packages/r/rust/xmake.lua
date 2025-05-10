package("rust")
    set_kind("toolchain")
    set_homepage("https://rust-lang.org")
    set_description("Rust is a general-purpose programming language emphasizing performance, type safety, and concurrency.")

    add_versions("1.86.0", "")

    add_deps("ca-certificates", {host = true, private = true})
    add_deps("rustup", {host = true, private = true, system = false})

    -- required 
    add_configs("target_plat", {description = "Target platform (for cross-compilation)", default = nil, type = "string"})
    add_configs("target_arch", {description = "Target arch (for cross-compilation)", default = nil, type = "string"})

    on_check("mingw", function (package)
    end)

    on_load(function (package)
        if package:config("target_plat") == nil then
            package:config_set("target_plat", package:plat())
        end
        if package:config("target_arch") == nil then
            package:config_set("target_arch", package:arch())
        end
    end)

    on_install(function (package)
        import("private.tools.rust.target_triple")

        local rustup = assert(os.getenv("RUSTUP_HOME"), "cannot find rustup home!")
        local version = package:version():shortstr()

        local plat = package:config("target_plat")
        local arch = package:config("target_arch")

        local host_target = assert(target_triple(package:plat(), package:arch()), "failed to build target triple for plat %s and arch %s, if you think this is a bug please create an issue", package:plat(), package:arch())
        local toolchain_name = version .. "-" .. host_target
        os.vrunv("rustup", {"install", "--no-self-update", toolchain_name})

        local target = assert(target_triple(plat, arch), "failed to build target triple for target_plat %s and target_arch %s, if you think this is a bug please create an issue", plat, arch)
        if target ~= host_target then
            os.vrunv("rustup", {"target", "add", target})
        end

        os.vmv(path.join(rustup, "toolchains", toolchain_name, "*"), package:installdir())

        -- cleanup to prevent rustup to think the toolchain is still installed
        os.vrm(path.join(rustup, "toolchains", toolchain_name))
        os.vrm(path.join(rustup, "update-hashes", toolchain_name))

        package:addenv("RC", "bin/rustc" .. (is_host("windows") and ".exe" or ""))
        package:mark_as_pathenv("RC")
    end)

    on_test(function (package)
        os.vrun("cargo --version")
        os.vrun("rustc --version")
    end)
