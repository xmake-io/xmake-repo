package("verilator")
    set_kind("toolchain")
    set_homepage("https://verilator.org")
    set_description("Verilator open-source SystemVerilog simulator and lint system")
    set_license("LGPL-3.0")

    add_urls("https://github.com/verilator/verilator/archive/refs/tags/$(version).tar.gz",
             "https://github.com/verilator/verilator.git")

    add_versions("v5.030", "b9e7e97257ca3825fcc75acbed792b03c3ec411d6808ad209d20917705407eac")

    add_deps("cmake")

    on_load(function (package)
        if not package:is_precompiled() then
            if package:is_plat("windows") then
                package:add("deps", "winflexbison", {kind = "library"})
            else
                package:add("deps", "flex", {kind = "library"})
                package:add("deps", "bison")
            end
            package:add("deps", "python 3.x", {kind = "binary"})
        end
        package:mark_as_pathenv("VERILATOR_ROOT")
        package:addenv("VERILATOR_ROOT", ".")
    end)

    on_install(function (package)
        import("package.tools.cmake")

        io.replace("src/CMakeLists.txt", "MSVC_RUNTIME_LIBRARY MultiThreaded$<IF:$<CONFIG:Release>,,DebugDLL>", "", {plain = true})

        local configs = {"-DOBJCACHE_ENABLED=OFF", "-DDEBUG_AND_RELEASE_AND_COVERAGE=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        local opt = {}
        opt.envs = cmake.buildenvs(package)
        if package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_COMPILE_PDB_OUTPUT_DIRECTORY=''")
            opt.envs.WIN_FLEX_BISON = package:dep("winflexbison"):installdir("include")
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
        os.vrun("verilator --version")
    end)
