package("duktape")
    set_homepage("https://github.com/svaarala/duktape")
    set_description("Duktape - embeddable Javascript engine with a focus on portability and compact footprint")
    set_license("MIT")

    add_urls("https://github.com/svaarala/duktape.git")

    add_versions("29.01.2024", "50af773b1b32067170786c2b7c661705ec7425d4")

    on_install(function (package)
        local configs = {}
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("duktape")
                set_kind("$(kind)")
                add_files("src-input/*.c")
                add_headerfiles("src-input/(*.h)")
                set_configdir("build/config")
                add_headerfiles("build/config/(*.h)")
                add_configfiles("src-input/duktape.h.in", {pattern = "@(.-)@"})
                add_includedirs("src-input", "build/config")
                set_configvar("DUK_SINGLE_FILE", "")
                set_configvar("DUK_VERSION_FORMATTED", "")
                set_configvar("GIT_BRANCH", "")
                set_configvar("GIT_DESCRIBE", "")
                set_configvar("LICENSE_TXT", "")
                set_configvar("GIT_DESCRIBE_CSTRING", "")
                set_configvar("AUTHORS_RST", "")
                set_configvar("GIT_COMMIT_CSTRING", "")
                set_configvar("GIT_BRANCH_CSTRING", "")
                
                
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("duk_push_c_function", {includes = "duktape.h"}))
    end)
