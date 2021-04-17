package("rply")

    set_homepage("http://w3.impa.br/~diego/software/rply/")
    set_description("RPly is a library that lets applications read and write PLY files.")
    set_license("MIT")

    add_urls("http://w3.impa.br/~diego/software/rply/rply-$(version).tar.gz")
    add_versions("1.1.4", "daf0b060fe701adf72aab0d525323d2e2e1bde9aa6aa9713ff1a5ef1e768d703")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("rply")
                set_kind("$(kind)")
                add_files("rply.c")
                add_headerfiles("rply.h", "rplyfile.h")
        ]])
        local configs = {kind = "static"}
        if package:config("shared") then
            configs.kind = "shared"
        elseif package:is_plat("linux") and package:config("pic") ~= false then
            configs.cxflags = "-fPIC"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ply_create", {includes = "rply.h"}))
    end)
