package("criterion")
    set_homepage("https://github.com/Snaipe/Criterion")
    set_description("A cross-platform C and C++ unit testing framework for the 21st century")
    set_license("MIT")

    add_urls("https://github.com/Snaipe/Criterion/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Snaipe/Criterion.git")

    add_versions("2.4.2", "83e1a39c8c519fbef0d64057dc61c8100b3a5741595788c9f094bba2eeeef0df")

    add_configs("i18n", {description = "Enable i18n", default = false, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("meson", "ninja")
    if is_subhost("windows") then
        add_deps("pkgconf")
    else
        add_deps("pkg-config")
    end

    add_deps("debugbreak", "klib", "libffi", "libgit2", "nanomsg", "boxfort")
    add_deps("nanopb", {configs = {generator = true}})
    if is_plat("windows") then
        add_deps("wingetopt")
    end

    on_install("!wasm", function (package)
        os.rm("subprojects")
        io.replace("src/protocol/gen-pb.py", "exit", "sys.exit", {plain = true})
        if package:is_plat("windows", "mingw") then
            io.replace("meson.build", [[{'fn': 'getcwd'},]], "", {plain = true})
            if package:is_plat("windows") then
                io.replace("meson.build", [[{'fn': 'isatty'},]], "", {plain = true})
                -- io.replace("src/entry/params.c", "opts[]", "opts[28]", {plain = true})
                if not package:config("shared") then
                    io.replace("include/criterion/internal/common.h", "__declspec(dllimport)", "", {plain = true})
                end
            end
        end

        local python = package:is_plat("windows") and "python" or "python3"
        os.vrun(python .. " -m pip install protobuf grpcio-tools")

        local configs = {"-Dtests=false", "-Dsamples=false", "-Dc_std=c99"}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        table.insert(configs, "-Di18n=" .. (package:config("i18n") and "enabled" or "disabled"))

        local opt = {
            cxflags = {},
            packagedeps = {},
        }
        if package:is_plat("windows", "mingw") then
            local nanomsg = package:dep("nanomsg")
            if not nanomsg:config("shared") then
                table.insert(opt.cxflags, "-DNN_STATIC_LIB")
            end

            table.insert(opt.cxflags, "-DHAVE_GETCURRENTDIRECTORY")
            table.join2(opt.packagedeps, {"nanomsg", "libgit2", "pcre2"})
            if package:is_plat("windows") then
                table.insert(opt.packagedeps, "wingetopt")
                if package:has_tool("cl") then
                    table.insert(opt.cxflags, "/utf-8")
                end
            end
        end
        import("package.tools.meson").install(package, configs, opt)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("criterion_initialize", {includes = "criterion/criterion.h"}))
    end)
