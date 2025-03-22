package("sqrat")
    set_homepage("http://scrat.sourceforge.net/")
    set_description("Sqrat is a C++ library for Squirrel that facilitates exposing classes and other native functionality to Squirrel scripts.")
    set_license("zlib")

    add_urls("https://downloads.sourceforge.net/project/scrat/Sqrat/Sqrat%20$(version).tar.gz", {version = function (version)
        return version:major() .. "." .. version:minor() .. "/sqrat-" .. version
    end})

    add_versions("0.9.2", "b22ec2edc5cc5fba13280c6372e92a37fe31e74f0db924a41119f10c1130d725")

    add_configs("headeronly", {description = "Install headerfiles only.", default = false, type = "boolean"})

    add_deps("squirrel")

    add_includedirs("include", "include/sqrat")

    on_load(function (package)
        if package:config("headeronly") then
            package:set("kind", "library", {headeronly = true})
        end
    end)

    on_install("!wasm and !iphoneos", function (package)
        if not package:config("headeronly") then
            if not package:is_cross() then
                package:addenv("PATH", "bin")
            end

            -- Adapt existing code to squirrel 3.2 recent changes https://github.com/albertodemichelis/squirrel/blob/f77074bdd6152d230609146a3d424c6f49e3770f/sq/sq.c#L279
            io.replace("sq/sq.c",
                [[scfprintf(stdout,_SC("%s %s (%d bits)\n"),SQUIRREL_VERSION,SQUIRREL_COPYRIGHT,sizeof(SQInteger)*8);]],
                [[scfprintf(stdout,_SC("%s %s (%d bits)\n"),SQUIRREL_VERSION,SQUIRREL_COPYRIGHT,((int)(sizeof(SQInteger)*8)));]],
            {plain = true})
            io.replace("sq/sq.c",
                [[scsprintf(sq_getscratchpad(v,MAXINPUT),_SC("return (%s)"),&buffer[1]);]], 
                [[scsprintf(sq_getscratchpad(v,MAXINPUT),(size_t)MAXINPUT,_SC("return (%s)"),&buffer[1]);]], {plain = true})
        end

        -- Adapt existing code to squirrel 3.2 dependency https://sourceforge.net/p/scrat/code/ci/6b75212d14fbf312c059e09cde3400035835c9dc/
        io.replace("include/sqmodule.h",
            "(*getclosureinfo)(HSQUIRRELVM v,SQInteger idx,SQUnsignedInteger *nparams,SQUnsignedInteger *nfreevars);",
            "(*getclosureinfo)(HSQUIRRELVM v,SQInteger idx,SQInteger *nparams,SQInteger *nfreevars);", {plain = true})
        io.replace("include/sqmodule.h",
            "(*getinstanceup)(HSQUIRRELVM v, SQInteger idx, SQUserPointer *p,SQUserPointer typetag);",
            "(*getinstanceup)(HSQUIRRELVM v, SQInteger idx, SQUserPointer *p,SQUserPointer typetag, SQBool throwerror);", {plain = true})

        io.replace("include/sqrat/sqratFunction.h", "SQUnsignedInteger nparams;", "SQInteger nparams;", {plain = true})
        io.replace("include/sqrat/sqratFunction.h", "SQUnsignedInteger nfreevars;", "SQInteger nfreevars;", {plain = true})

        io.replace("include/sqrat/sqratClassType.h",
                        [[if (SQ_FAILED(sq_getinstanceup(vm, idx, (SQUserPointer*)&instance, classType))) {]],
                        [[if (SQ_FAILED(sq_getinstanceup(vm, idx, (SQUserPointer*)&instance, classType, SQTrue))) {]], {plain = true})
        io.replace("include/sqrat/sqratClassType.h",
                        [[sq_getinstanceup(vm, idx, (SQUserPointer*)&instance, 0);]],
                        [[sq_getinstanceup(vm, idx, (SQUserPointer*)&instance, 0, SQFalse);]], {plain = true})

        os.cp("include", package:installdir())

        if not package:config("headeronly") then
            io.writefile("xmake.lua", [[
                add_rules("mode.debug", "mode.release")
                add_requires("squirrel")
                set_languages("c11", "c++11")

                target("sqratthread")
                    set_enabled(is_plat("windows"))
                    set_kind("$(kind)")
                    add_defines("SQRATTHREAD_EXPORTS")
                    add_files("sqratthread/sqratThread.cpp")
                    add_headerfiles("sqratthread/sqratThread.h")
                    add_includedirs("include")
                    add_packages("squirrel")
                    if is_plat("windows") and is_kind("shared") then
                        add_rules("utils.symbols.export_all", {export_classes = true})
                    end

                target("sqratimport")
                    set_kind("$(kind)")
                    add_files("sqimport/sqratimport.cpp")
                    add_headerfiles("include/sqmodule.h", "include/sqratimport.h")
                    add_includedirs("include")
                    add_packages("squirrel")
                    if is_plat("windows") and is_kind("shared") then
                        add_rules("utils.symbols.export_all", {export_classes = true})
                    end

                target("sq")
                    set_kind("binary")
                    add_deps("sqratimport")
                    add_includedirs("include")
                    add_files("sq/sq.c")
                    add_packages("squirrel")
                    if is_plat("linux", "bsd") then
                        add_syslinks("m", "dl")
                    end
            ]])
            import("package.tools.xmake").install(package)
        end
    end)

    on_test(function (package)
        if not package:config("headeronly") and not package:is_cross() then
            os.vrun("sq -v")
        end

        assert(package:check_cxxsnippets({test = [[
            void test() {
                Sqrat::string str = Sqrat::string("sq");
            }
        ]]}, {configs = {languages = "c++11"}, includes = "sqrat.h"}))
    end)
