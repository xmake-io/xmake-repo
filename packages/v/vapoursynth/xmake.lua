package("vapoursynth")
    set_homepage("https://www.vapoursynth.com/")
    set_description("A video processing framework with simplicity in mind")
    set_license("LGPL-2.1")

    add_urls("https://github.com/vapoursynth/vapoursynth/archive/refs/tags/R$(version).tar.gz")
    add_urls("https://github.com/vapoursynth/vapoursynth.git", {alias = "git"})

    add_versions("79", "cb7ea3c75431176f8ce1f466e1c1fff7ffdacdd2d397be8fabc2d467194ab5a6")
    add_versions("73", "1bb8ffe31348eaf46d8f541b138f0136d10edaef0c130c1e5a13aa4a4b057280")

    add_versions("git:79", "R79")
    add_versions("git:73", "R73")

    add_patches(">=75", "patches/79/meson.patch", "1b5b6035e6047e94175393f50930e6f2b6e3f30215e9cde9d9e502205baaf3ae")

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    if is_plat("windows", "mingw") then
        add_syslinks("advapi32", "shell32")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("meson", "ninja")
    if is_subhost("windows") then
        add_deps("pkgconf")
    else
        add_deps("pkg-config")
    end
    add_deps("zimg")

    on_check("android", function (package)
        local ndk = package:toolchain("ndk"):config("ndkver")
        assert(ndk and tonumber(ndk) > 22, "package(vapoursynth) require ndk version > 22")
    end)

    on_load(function (package)
        if package:version() and package:version():le("74") then
            package:add("configs", "vsscript", {description = "Build VSScript. Requires Python 3", default = false, type = "boolean"})
            package:add("configs", "vspipe", {description = "Build vspipe. Requires VSScript", default = false, type = "boolean"})
            package:add("configs", "python", {description = "Build the Python module. Requires Python and Cython", default = false, type = "boolean"})
            if package:config("vsscript") or package:config("python") then
                package:add("deps", "python 3.x", {kind = "binary"})
            end
        else
            package:add("deps", "python 3.x", {kind = "binary"})
        end
        local has_cat = try { function()
            os.vrun("cat --version")
            os.vrun("grep --version")
            return true
        end }
        if not has_cat and os.arch() == "x64" then
            local msystem = "MINGW" .. (package:is_arch64() and "64" or "32")
            package:add("deps", "msys2", {configs = {msystem = msystem, base_devel = true}})
        end
    end)

    on_install(function (package)
        if package:config("python") then
            local pytool = package:find_tool("python") or package:find_tool("python3")
            local venv_dir = path.join(os.curdir(), ".venv")
            os.vrunv(pytool.program, {"-m", "venv", venv_dir})
            local venv_bin = is_host("windows") and path.join(venv_dir, "Scripts") or path.join(venv_dir, "bin")
            local venv_python = is_host("windows") and path.join(venv_bin, "python.exe") or path.join(venv_bin, "python")
            if not os.isfile(venv_python) and is_host("windows") then
                venv_python = path.join(venv_dir, "python.exe")
                venv_bin = venv_dir
            end
            os.vrunv(venv_python, {"-m", "pip", "install", "cython"})
            os.addenv("PATH", venv_bin)
        elseif package:version() and package:version():ge("75") then
            io.replace("meson.build", "project('VapourSynth', 'c', 'cpp', 'cython',", "project('VapourSynth', 'c', 'cpp',", {plain = true})
            io.replace("meson.build", "py.extension_module(", "if false\npy.extension_module(", {plain = true})
            io.replace("meson.build", "py.install_sources(", "endif\nif false\npy.install_sources(", {plain = true})
            io.replace("meson.build", "libvsscript = library('vsscript',", "endif\nlibvsscript = library('vsscript',", {plain = true})
        else
            io.replace("meson.build", "['c', 'cpp', 'cython']", "['c', 'cpp']", {plain = true})
            io.replace("meson.build", ", 'cython'", "", {plain = true})
        end
        if package:has_tool("cxx", "cl") then
            io.replace("meson.build", "'-Wno-ignored-attributes',", "", {plain = true})
            io.replace("meson.build", "-Wno-ignored-attributes", "", {plain = true})
            io.replace("meson.build", "add_project_arguments(['-fno-math-errno', '-fno-trapping-math'], language: lang)", "", {plain = true})
        end
        if not package:config("shared") and package:is_plat("windows", "mingw") then
            io.replace("include/VapourSynth.h", "__declspec(dllexport)", "", {plain = true})
            io.replace("include/VapourSynth4.h", "__declspec(dllexport)", "", {plain = true})
        end
        local configs = {}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        table.insert(configs, "-Db_lto=" .. (package:config("lto") and "true" or "false"))
        if package:version() and package:version():le("74") then
            table.insert(configs, "-Denable_vsscript=" .. (package:config("vsscript") and "true" or "false"))
            table.insert(configs, "-Denable_vspipe=" .. (package:config("vspipe") and "true" or "false"))
            table.insert(configs, "-Denable_python_module=" .. (package:config("python") and "true" or "false"))
        elseif package:version() and package:version():ge("79") and package:has_tool("cxx", "cl") then
            table.insert(configs, "-Denable_arm_asm=false")
        end

        local opt = {}
        if package:is_plat("windows") then
            opt.cxflags = "-DNOMINMAX"
        elseif package:is_plat("mingw") and package:is_arch("i386") then
            opt.cxflags = {"-msse", "-msse2"}
        elseif package:is_plat("linux", "bsd") then
            opt.cxflags = "-pthread"
            opt.shflags = "-pthread"
        end
        import("package.tools.meson").install(package, configs, opt)

        if not package:config("shared") and package:is_plat("windows", "mingw") then
            io.replace(path.join(package:installdir("include"), "vapoursynth/VapourSynth.h"), "__declspec(dllimport)", "", {plain = true})
            io.replace(path.join(package:installdir("include"), "vapoursynth/VapourSynth4.h"), "__declspec(dllimport)", "", {plain = true})
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("getVapourSynthAPI", {includes = "vapoursynth/VapourSynth4.h"}))
    end)
