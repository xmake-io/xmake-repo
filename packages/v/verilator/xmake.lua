package("verilator")
    set_kind("toolchain")
    set_homepage("https://verilator.org")
    set_description("Verilator open-source SystemVerilog simulator and lint system")
    set_license("LGPL-3.0")

    add_urls("https://github.com/verilator/verilator/archive/refs/tags/$(version).tar.gz",
             "https://github.com/verilator/verilator.git")

    add_versions("v5.032", "5a262564b10be8bdb31ff4fb67d77bcf5f52fc1b4e6c88d5ca3264fb481f1e41")
    add_versions("v5.016", "66fc36f65033e5ec904481dd3d0df56500e90c0bfca23b2ae21b4a8d39e05ef1")
    add_versions("v5.032", "5a262564b10be8bdb31ff4fb67d77bcf5f52fc1b4e6c88d5ca3264fb481f1e41")

    add_deps("cmake")

    if on_check then
        on_check(function (package)
            if is_subhost("msys") and xmake:version():lt("2.9.7") then
                raise("package(verilator) requires xmake >= 2.9.7 on msys")
            end
        end)
    end

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

        if is_subhost("msys") then
            io.replace("CMakeLists.txt", "if(WIN32)", "if(0)", {plain = true})
        end

        local version = package:version()
        if version then
            if version:ge("5.024") then
                io.replace("bin/verilator", "$verilator_root ne realpath($ENV{VERILATOR_ROOT})", "true")
            end
            
            if version:ge("5.030") then
                io.replace("src/CMakeLists.txt", "MSVC_RUNTIME_LIBRARY MultiThreaded$<IF:$<CONFIG:Release>,,DebugDLL>", "", {plain = true})
            else
                io.replace("src/CMakeLists.txt", "MSVC_RUNTIME_LIBRARY  MultiThreaded$<IF:$<CONFIG:Release>,,DebugDLL>", "", {plain = true})
                if version:lt("5.028") then
                    if is_host("linux", "bsd") then
                        io.replace("src/CMakeLists.txt", "install(TARGETS ${verilator})",
                            "target_link_libraries(${verilator} PRIVATE pthread)\ninstall(TARGETS ${verilator})", {plain = true})
                    end

                    if version:lt("5.020") then
                        if is_host("windows") and not package:has_tool("cxx", "cl") then
                            io.replace("src/CMakeLists.txt", "INTERPROCEDURAL_OPTIMIZATION_RELEASE  TRUE", "", {plain = true})
                            io.replace("src/CMakeLists.txt", "/bigobj", "-Wa,-mbig-obj", {plain = true})
                            io.replace("src/CMakeLists.txt", "YY_NO_UNISTD_H", "", {plain = true})
                            io.replace("src/CMakeLists.txt", "/STACK:10000000", "-Wl,--stack,10000000 -mconsole -lcomctl32 -DWIN_32_LEAN_AND_MEAN", {plain = true})
                        end
                    end
                end
            end
        end

        local configs = {
            "-DOBJCACHE_ENABLED=OFF",
            "-DDEBUG_AND_RELEASE_AND_COVERAGE=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if not is_host("linux") then
            table.insert(configs, "-DCMAKE_CXX_STANDARD=20")
        end

        local opt = {}
        opt.envs = cmake.buildenvs(package)
        local winflexbison = package:dep("winflexbison")
        if winflexbison then
            opt.envs.WIN_FLEX_BISON = winflexbison:installdir("include")
        else
            local flex = package:dep("flex")
            -- https://github.com/verilator/verilator/issues/3487
            if is_subhost("msys") or not flex:is_system() then
                local includedir = flex:installdir("include")
                if version and version:lt("5.026") then
                    opt.cxflags = "-I" .. includedir
                else
                    table.insert(configs, "-DFLEX_INCLUDE_DIR=" .. includedir)
                end
            end
        end
        cmake.install(package, configs, opt)

        if is_host("linux") then
            if package:is_debug() then
                local bindir = package:installdir("bin")
                os.ln(path.join(bindir, "verilator_bin_dbg"), path.join(bindir, "verilator_bin"))
            end
        elseif is_host("windows") then
            local bindir = package:installdir("bin")
            local verilator = path.join(bindir, "verilator.exe")
            if not os.isfile(verilator) then
                local verilator_bin = "verilator_bin"
                if package:is_debug() then
                    verilator_bin = verilator_bin .. "_dbg"
                end
                verilator_bin = path.join(bindir, verilator_bin .. ".exe")
                os.trycp(verilator_bin, verilator)
            end
        end
    end)

    on_test(function (package)
        os.vrun("verilator --version")
    end)
