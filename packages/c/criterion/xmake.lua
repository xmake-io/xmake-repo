package("criterion")
    set_homepage("https://github.com/Snaipe/Criterion")
    set_description("A cross-platform C and C++ unit testing framework for the 21st century")
    set_license("MIT")

    add_urls("https://github.com/Snaipe/Criterion/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Snaipe/Criterion.git")

    add_versions("v2.4.2", "83e1a39c8c519fbef0d64057dc61c8100b3a5741595788c9f094bba2eeeef0df")

    add_configs("i18n", {description = "Enable i18n", default = false, type = "boolean"})

    if is_plat("windows", "mingw") then
        add_syslinks("ws2_32", "mswsock")
    elseif is_plat("linux", "bsd") then
        add_syslinks("m", "pthread", "rt")
    end

    add_deps("meson", "ninja")
    if is_subhost("windows") then
        add_deps("pkgconf", "wingetopt")
    else
        add_deps("pkg-config")
    end
    add_deps("debugbreak", "klib", "libffi", "nanopb", "nanomsg", "libgit2")

    on_load(function (package)
        if package:is_plat("bsd") and package:config("shared") then
            package:add("deps", "boxfort", {configs = {shared = true}})
        else
            package:add("deps", "boxfort")
        end
    end)

    on_install("windows|!arm*", "linux", "macosx", "cross", "mingw@windows,msys", "bsd", "msys", function (package)
        os.rm("subprojects")
        import("patch")(package)
        local opt = {}
        --    Gather protoc-gen-nanopb from python3 pip
        local python = package:is_plat("windows") and "python" or "python3"
        os.vrun(python .. " -m pip install protobuf==5.29.3 nanopb==0.4.9.1")
        if package:is_plat("bsd") then
            opt.cflags = {"-Wno-error=incompatible-function-pointer-types"}
            opt.packagedeps = {"llhttp", "openssl3", "pcre2"}
        elseif package:is_plat("windows", "mingw") then
            opt.packagedeps = {"wingetopt", "nanomsg", "pcre2", "libgit2"}
            if package:has_tool("cxx", "cl") then
                opt.cxflags = {"/utf-8"}
            end
        else
            opt.packagedeps = {"libgit2"}
        end
        local configs = {"-Dtests=false", "-Dsamples=false", "-Dc_std=c11"}
        table.insert(configs, "-Di18n=" .. (package:config("i18n") and "enabled" or "disabled"))
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        import("package.tools.meson").install(package, configs, opt)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("criterion_handle_args", {includes = "criterion/criterion.h"}))
    end)
