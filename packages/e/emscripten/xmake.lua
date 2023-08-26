package("emscripten")
    set_kind("toolchain")
    set_homepage("https://emscripten.org/")
    set_description("Emscripten: An LLVM-to-WebAssembly Compiler.")
    set_license("MIT")

    set_urls("https://github.com/emscripten-core/emsdk.git")
    add_versions("3.1.42", "c2260b4f28f53b411032de0955a6fe6b6bcf3edd")
    add_versions("3.1.25", "92d9023adc4dbc66424df9483cee302c68817d3c")
    add_versions("3.1.14", "517e02fac88b48c74da14b1cf7c6d51e489a5793")

    add_deps("python")

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

    on_install("windows", "macosx", "linux", function (package)
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
    end)

    on_test(function (package)
        local emcc = is_host("windows") and "emcc.bat" or "emcc"
        os.vrunv(emcc, {"--version"})
    end)
