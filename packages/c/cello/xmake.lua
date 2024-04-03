package("cello")
    set_homepage("http://libcello.org/")
    set_description("Higher level programming in C")

    add_urls("https://github.com/orangeduck/Cello/archive/refs/tags/v$(version).tar.gz",
             "https://github.com/orangeduck/Cello.git")

    add_versions("2.0.3", "1afcae06f5efc10ea161737a862073ff5679c964540bca7cd719539609d0633c")

    on_install(function(package)
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("Cello")
                set_kind("$(kind)")
                set_languages("gnu99")
                add_links("m", "pthread")
                add_files("src/*.c")
                add_headerfiles("include/Cello.h")
                add_includedirs("include")
                on_config(function(target)
                    if is_plat("windows") and target:has_cincludes("Dbghelp.h") then
                        target:add("links", "Dbghelp")
                    elseif is_plat("linux") target:has_cincludes("execinfo.h") then
                        target:add({ links = "execinfo", ldflags = "-rdynamic" })
                    else
                        target:add("defines", "CELLO_NSTRACE")
                    end
                end)
        ]])
        import("package.tools.xmake").install(package, { kind = package:config("shared") and "shared" or "static" })
    end)

    on_test(function(package)
        assert(package:check_csnippets({
            test = [[
                void test_fn(var arr1, var arr2)
                {
                    concat(arr1, arr2);
                    show(arr1);
                }
                
                void test_main()
                {
                    var integer_num = $I(1);
                    var float_num = $F(1.0);
                    var arr1 = new(Array, Int, $I(1), $I(3));
                    var arr2 = new(Array, Int, $I(3), $I(7));
                    test_fn(arr1, arr2);
                    show($S("Hello World!"));
                }
            ]]
        }, { configs = { languages = "gnu99" }, includes = "Cello.h" }))
    end)
