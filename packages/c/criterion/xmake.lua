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

    --FIXUP for unres symbols
    add_deps("nanomsg", {configs = {shared = true}})
    add_deps("libgit2", {configs = {shared = true}})

    add_deps("boxfort", {configs = {shared = false}})
    add_deps("libffi", {configs = {shared = false}})
    add_deps("nanopb", {configs = {generator = true}})
    add_deps("python 3.x", {kind = "binary"})

     -- Try pass getopt to Windows

    on_install(function (package)
        io.replace("src/meson.build", [[libcriterion = both_libraries]], [[libcriterion = library]], {plain = true})
        local opt = {}
        -- Remove debugbreak & klib
        os.rm("subprojects")

        -- Gather protoc-gen-nanopb, protoc comes from protobuf-cpp xmake package
        local python = package:is_plat("windows") and "python" or "python3"
        os.vrun(python .. " -m pip install protobuf==5.29.3 nanopb==0.4.9.1")

        io.replace("meson.build", "git = find_program('git', required: false)", "", {plain = true})
        io.replace("meson.build", "if git.found() and is_git_repo", "if false", {plain = true})

        -- Swap from CMakeConfig to pkgconfig
        -- io.replace("meson.build",
            -- [[nanomsg = dependency('nanomsg', required: get_option('wrap_mode') == 'nofallback')]],
            -- [[nanomsg = dependency('nanomsg', method: 'pkg-config')]])

        io.replace("meson.build",
            [[nanopb = dependency('nanopb', required: get_option('wrap_mode') == 'nofallback', method: 'cmake',]],
            [[nanopb = dependency('nanopb', method: 'pkg-config')]], {plain = true})
        io.replace("meson.build", "modules: ['nanopb::protobuf-nanopb-static'])", "", {plain = true})

        -- io.cat("meson.build")

        -- io.replace("src/criterion.pb.h", "#include <pb.h>", "#include <nanopb/pb.h>", {plain = true})
        -- for _, file in ipairs(os.files("src/**pb.h")) do
        --     io.replace(file, "#include <pb.h>", "#include <nanopb/pb.h>", {plain = true})
        -- end
        -- for _, file in ipairs(os.files("src/**.h")) do
        --     io.replace(file, "#include <pb.h>", "#include <nanopb/pb.h>", {plain = true})
        -- end

        -- io.replace("src/io/event.h", "#include <pb.h>", "#include <nanopb/pb.h>", {plain = true})
        -- io.replace("src/protocol/protocol.h", "#include <pb.h>", "#include <nanopb/pb.h>", {plain = true})
        -- io.replace("src/protocol/criterion.pb.h", "#include <pb.h>", "#include <nanopb/pb.h>", {plain = true})
        -- io.replace("meson.build", [['-DWIN32_LEAN_AND_MEAN',]], [['-DWIN32_LEAN_AND_MEAN', '-D_WIN32', '-DCRITERION_BUILDING_DLL', ]], {plain = true})
        if is_plat("windows", "mingw") then -- HAVE WINDOWS.H
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
        else                                -- DO NOT HAVE WINDOWS.H
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
