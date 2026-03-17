package("emscripten")
    set_kind("toolchain")
    set_homepage("https://emscripten.org/")
    set_description("Emscripten: An LLVM-to-WebAssembly Compiler.")
    set_license("MIT")

    add_urls("https://github.com/emscripten-core/emsdk/archive/refs/tags/$(version).tar.gz",
             "https://github.com/emscripten-core/emsdk.git")

    add_versions("5.0.3", "9a44a58bca0a3ea594ea7340d9a726cb58c772144dd37406d1c4e921823a75eb")
    add_versions("4.0.23", "a91a4c1f42dbb0345faac093161e27d43e9b6964840d8c8d80976ab8d3eaf2d3")
    add_versions("4.0.12", "d972bf0909718f155aeb5627429230471c94b2a8a3047ee696e2690ec73961cb")
    add_versions("3.1.55", "86a6af30e43d7b501772e5d2993457c924b73f1d1c0a3484a8c6c48452af549f")
    add_versions("3.1.42", "bbfb6374e2a0e49147edbfe371faa1a3280217aba301ec4674bc41c8c123942a")
    add_versions("3.1.25", "b8772e32043905b3af4b926f54ac7ca3faf5d5eb93105973c85c56ec60c832d5")
    add_versions("3.1.14", "d184dd6bc7700d5bacfa8c4b4ff7cd6bca2cbc7b5d1b19732fe8a84935e4a529")
    add_versions("1.39.8", "37b8807cad1aa0a976bbbdee5d3c5efc03e59175efdc555721793824f8c591f4")

    add_deps("python")

    on_check("macosx|arm64", "linux|arm64", function (package)
        local package_ver = package:version()
        if package:is_plat("macosx") and package_ver and package_ver:lt("2.0.21") then
            -- https://github.com/emscripten-core/emsdk/issues/671
            raise("toolchain(emscripten): macOS arm64 is only supported for emscripten >= 2.0.21")
        end
        if package:is_plat("linux") and package_ver and package_ver:lt("3.1.58") then
            -- https://github.com/emscripten-core/emsdk/issues/1500
            raise("toolchain(emscripten): Linux arm64 is not fully supported for emscripten < 3.1.58.")
        end
    end)

    on_load(function (package)
        package:addenv("PATH", "upstream/emscripten")
        package:addenv("PATH", ".")
        package:addenv("EMSDK", ".")
        package:mark_as_pathenv("EMSDK")
        package:mark_as_pathenv("EMSDK_NODE")
        if package:is_plat("windows") then
            package:mark_as_pathenv("EMSDK_PYTHON")
            package:mark_as_pathenv("JAVA_HOME")
        end
    end)

    on_install("windows|!arm*", "macosx", "linux", function (package)
        import("lib.detect.find_directory")

        -- installation
        os.cp("*", package:installdir())
        local version = package:version():rawstr()
        local installdir = package:installdir()
        local py = package:is_plat("windows") and "python" or "python3"
        os.vrunv(py, {path.join(installdir, "emsdk.py"), "install", version})

        -- activation
        os.vrunv(py, {path.join(installdir, "emsdk.py"), "activate", version})

        -- setup env
        local exe = package:is_plat("windows") and ".exe" or ""
        local node_bindir = find_directory("bin", {path.join(installdir, "node", "**")})
        if node_bindir then
            node_bindir = path.relative(node_bindir, installdir)
            package:addenv("PATH", node_bindir)
            package:addenv("EMSDK_NODE", path.join(node_bindir, "node" .. exe))
        end
        if package:is_plat("windows") then
            local python = find_directory("*", path.join(installdir, "python"))
            if python then
                python = path.relative(python, installdir)
                package:addenv("EMSDK_PYTHON", path.join(python, "python" .. exe))
            end
            local java = find_directory("*", path.join(installdir, "java"))
            if java then
                java = path.relative(java, installdir)
                package:addenv("JAVA_HOME", java)
            end
        end
        local python_dep = package:dep("python")
        if package:version() and package:version():lt("1.39.12") and python_dep and python_dep:version() then
            -- if python3 and low version emscripten, we need to change the shebang
            local py_major_ver = python_dep:version():major()
            if py_major_ver and py_major_ver == 3 then
                -- change shebang: python->python3
                for _, filepath in ipairs(os.files(path.join(installdir, "upstream", "emscripten", "*"))) do
                    io.replace(filepath, "#!/usr/bin/env python\n", "#!/usr/bin/env python3\n", {plain = true})
                end
            end
        end
    end)

    on_test(function (package)
        local emcc = is_host("windows") and "emcc.bat" or "emcc"
        os.vrunv(emcc, {"--version"})
    end)
