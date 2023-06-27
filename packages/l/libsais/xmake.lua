package("libsais")
    set_homepage("https://github.com/IlyaGrebnov/libsais")
    set_description("libsais is a library for linear time suffix array, longest common prefix array and burrows wheeler transform construction based on induced sorting algorithm.")
    set_license("Apache-2.0")

    add_urls("https://github.com/IlyaGrebnov/libsais/archive/refs/tags/$(version).tar.gz",
             "https://github.com/IlyaGrebnov/libsais.git")
    add_versions("v2.7.1", "5f459ad90cd007c30aaefb7d122bba2a4307ea02915c56381be4b331cca92545")

    on_install(function (package)
        local configs = {}
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("libsais")
               set_kind("$(kind)")
               add_files("src/*.c")
               add_headerfiles("src/(*.h)")
        ]])
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("libsais_create_ctx", {includes = "libsais.h"}))
    end)
