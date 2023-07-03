package("emscripten")

    set_kind("toolchain")
    set_homepage("https://emscripten.org/")
    set_description("Emscripten: An LLVM-to-WebAssembly Compiler.")
    set_license("MIT")

    set_urls("https://github.com/emscripten-core/emsdk.git")
    add_versions("3.1.42", "c2260b4f28f53b411032de0955a6fe6b6bcf3edd")

    add_deps("python")

    on_install("windows", "macosx", "linux", function (package)
        import("lib.detect.find_directory")
		-- copy to installdir
        os.cp("*", package:installdir())
	
        -- installation
        local version = package:version():rawstr()
        local installdir = package:installdir()
        local py = package:is_plat("windows") and "python" or "python3"
        os.vrunv(py, {path.join(installdir, "emsdk.py"), "install", version})

        -- activation
        os.vrunv(py, {path.join(installdir, "emsdk.py"), "activate", version})

        -- setup env
        local node = find_directory("bin", {path.join(installdir, "node", "**")})
        package:addenv("PATH", node)
        package:addenv("PATH", path.join(installdir, "upstream", "emscripten"))
        package:addenv("PATH", installdir)
        package:addenv("EMSDK", installdir)
    
        local exe = package:is_plat("windows") and ".exe" or ""

        package:addenv("EMSDK_NODE", path.join(node, "node" .. exe))
        if package:is_plat("windows") then
            local python = find_directory("*", path.join(installdir, "python"))
            package:addenv("EMSDK_PYTHON", path.join(python, "python" .. exe))
            local java = find_directory("*", path.join(installdir, "java"))
            package:addenv("JAVA_HOME", java)
        end
    end)

    on_test(function (package)
        local emcc = is_host("windows") and "emcc.bat" or "emcc"
        os.vrunv(emcc, {"--version"})
    end)