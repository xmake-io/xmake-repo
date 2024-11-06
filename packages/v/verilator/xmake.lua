package("verilator")
    set_kind("toolchain")
    set_homepage("https://verilator.org")
    set_description("Verilator open-source SystemVerilog simulator and lint system")
    set_license("LGPL-3.0")

    add_urls("https://github.com/verilator/verilator/archive/refs/tags/$(version).tar.gz",
             "https://github.com/verilator/verilator.git")

    add_versions("v5.016", "66fc36f65033e5ec904481dd3d0df56500e90c0bfca23b2ae21b4a8d39e05ef1")

    add_deps("cmake")

    on_load(function (package)
        if not package:is_precompiled() then
            package:add("deps", "flex", {kind = "library"})
            package:add("deps", "bison")
            package:add("deps", "python 3.x", {kind = "binary"})
        end
        package:mark_as_pathenv("VERILATOR_ROOT")
        package:addenv("VERILATOR_ROOT", ".")
    end)

    on_install(function (package)
        import("package.tools.cmake")

        io.replace("src/CMakeLists.txt", "MSVC_RUNTIME_LIBRARY MultiThreaded$<IF:$<CONFIG:Release>,,DebugDLL>", "", {plain = true})
        if is_subhost("msys") then
            io.replace("CMakeLists.txt", "if(WIN32)", "if(0)", {plain = true})
        end

        local configs = {
            "-DOBJCACHE_ENABLED=OFF",
            "-DDEBUG_AND_RELEASE_AND_COVERAGE=OFF",
            "-DCMAKE_CXX_STANDARD=20",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_COMPILE_PDB_OUTPUT_DIRECTORY=''")
        end

        local opt = {}
        opt.envs = cmake.buildenvs(package)
        if is_host("windows") then
            local winflexbison = package:dep("winflexbison")
            if winflexbison then
                opt.envs.WIN_FLEX_BISON = winflexbison:installdir("include")
            else
                local flex = package:dep("flex")
                table.insert(configs, "-DFLEX_INCLUDE_DIR=" .. flex:installdir("include"))
            end
        end
        cmake.install(package, configs, opt)

        local bindir = package:installdir("bin")
        local subfix = (is_host("windows") and ".exe" or "")
        local verilator = path.join(bindir, "verilator" .. subfix)
        if not os.isfile(verilator) then
            local verilator_bin = "verilator_bin"
            if package:is_debug() then
                verilator_bin = verilator_bin .. "_dbg"
            end
            verilator_bin = path.join(bindir, verilator_bin .. subfix)
            os.trycp(verilator_bin, verilator)
        end
    end)

    on_test(function (package)
        if not package:is_cross() then
            os.vrun("verilator --version")
        end
    end)
