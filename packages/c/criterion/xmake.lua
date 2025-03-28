package("criterion")
    set_homepage("https://github.com/Snaipe/Criterion")
    set_description("A cross-platform C and C++ unit testing framework for the 21st century")
    set_license("MIT")

    add_urls("https://github.com/Snaipe/Criterion/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Snaipe/Criterion.git")

    add_versions("v2.4.2", "83e1a39c8c519fbef0d64057dc61c8100b3a5741595788c9f094bba2eeeef0df")

    add_configs("i18n", {description = "Enable i18n", default = false, type = "boolean"})

    add_deps("meson", "ninja")

    if is_subhost("windows") then
        add_deps("pkgconf", "wingetopt")
    else
        add_deps("pkg-config")
    end

    if is_plat("windows") then
        add_syslinks("ws2_32", "mswsock")
    elseif is_plat("linux", "bsd") then
        add_syslinks("m", "pthread", "rt")
    end

    add_deps("debugbreak", "klib")
    add_deps("nanomsg", {configs = {shared = true}})
    add_deps("libgit2", {configs = {shared = true}})
    add_deps("boxfort", {configs = {shared = false}})
    add_deps("libffi", {configs = {shared = false}})
    add_deps("nanopb", {configs = {shared = true, generator = true}})
    add_deps("python 3.x", {kind = "binary"})

    on_check("windows", function (package)
        if package:is_arch("x86") and package:has_runtime("MD", "MDd") and package:config("shared") then
            raise("package(criterion) unsupported x86 & MD & shared")
        end
    end)

    on_install("windows|!arm*", "linux", "macosx", "cross", "mingw@windows,msys", "msys", function (package)
        io.replace("src/meson.build", [[libcriterion = both_libraries]], [[libcriterion = library]], {plain = true})
        local opt = {}
        os.rm("subprojects")
        --    Gather protoc-gen-nanopb, protoc comes from protobuf-cpp xmake package since we need to escape issue of 
        --    ModuleNotFoundError: No module named 'google.protobuf.text_format' and place nanopb's bin folder to PATH
        local python = package:is_plat("windows") and "python" or "python3"
        os.vrun(python .. " -m pip install protobuf==5.29.3 nanopb==0.4.9.1")
        io.replace("meson.build", "git = find_program('git', required: false)", "", {plain = true})
        io.replace("meson.build", "if git.found() and is_git_repo", "if false", {plain = true})
        -- Swap from cmake to pkg-config
        io.replace("meson.build",
            [[nanopb = dependency('nanopb', required: get_option('wrap_mode') == 'nofallback', method: 'cmake',]],
            [[nanopb = dependency('nanopb', method: 'pkg-config')]], {plain = true})
        io.replace("meson.build", "modules: ['nanopb::protobuf-nanopb-static'])", "", {plain = true})
        io.replace("meson.build",
            [[libgit2 = dependency('libgit2', required: get_option('wrap_mode') == 'nofallback')]],
            [[libgit2 = dependency('libgit2', method: 'pkg-config')]], {plain = true})
        if is_plat("windows", "mingw") then
            opt.packagedeps = {"wingetopt"}
            if package:has_tool("cl") then
                table.insert(opt.cxflags, "/utf-8")
            end
            io.replace("src/compat/path.c", "defined (HAVE_GETCWD)", "0", {plain = true})
            io.replace("src/compat/path.c", "defined (HAVE_GETCURRENTDIRECTORY)", "1", {plain = true})
            if not package:config("shared") then
                io.replace("include/criterion/internal/common.h", "__declspec(dllimport)", "", {plain = true})
            end
            io.replace("src/entry/params.c", "#ifdef HAVE_ISATTY", "#if 0", {plain = true})
            io.replace("src/entry/params.c", "opts[]", "opts[28]", {plain = true})
        else
            io.replace("src/compat/path.c", "defined (HAVE_GETCWD)", "1", {plain = true})
            io.replace("src/compat/path.c", "defined (HAVE_GETCURRENTDIRECTORY)", "0", {plain = true})
        end
        local configs = {"-Dtests=false", "-Dsamples=false", "-Dc_std=c11"}
        table.insert(configs, "-Di18n=" .. (package:config("i18n") and "enabled" or "disabled"))
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        import("package.tools.meson").install(package, configs, opt)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("criterion_handle_args", {includes = "criterion/criterion.h"}))
    end)
