package("sqrat")
    set_homepage("http://scrat.sourceforge.net/")
    set_description("Sqrat is a C++ library for Squirrel that facilitates exposing classes and other native functionality to Squirrel scripts.")
    set_license("zlib")

    add_urls("https://downloads.sourceforge.net/project/scrat/Sqrat/Sqrat%20$(version).tar.gz", {version = function (version)
        return version:major() .. "." .. version:minor() .. "/sqrat-" .. version
    end})

    add_versions("0.9.2", "b22ec2edc5cc5fba13280c6372e92a37fe31e74f0db924a41119f10c1130d725")

    add_deps("squirrel")

    add_includedirs("include", "include/sqrat")

    on_install("!wasm and !iphoneos", function (package)
        if not package:is_cross() then
            package:addenv("PATH", "bin")
        end

        io.replace("sq/sq.c",
            [[scfprintf(stdout,_SC("%s %s (%d bits)\n"),SQUIRREL_VERSION,SQUIRREL_COPYRIGHT,sizeof(SQInteger)*8);]],
            [[scfprintf(stdout,_SC("%s %s (%d bits)\n"),SQUIRREL_VERSION,SQUIRREL_COPYRIGHT,((int)(sizeof(SQInteger)*8)));]],
        {plain = true})
        -- Adapt existing code to squirrel dependency
        io.replace("include/sqmodule.h",
            "(*getclosureinfo)(HSQUIRRELVM v,SQInteger idx,SQUnsignedInteger *nparams,SQUnsignedInteger *nfreevars);",
            "(*getclosureinfo)(HSQUIRRELVM v,SQInteger idx,SQInteger *nparams,SQInteger *nfreevars);", {plain = true})

        io.replace("include/sqmodule.h",
            "(*getinstanceup)(HSQUIRRELVM v, SQInteger idx, SQUserPointer *p,SQUserPointer typetag);",
            "(*getinstanceup)(HSQUIRRELVM v, SQInteger idx, SQUserPointer *p,SQUserPointer typetag, SQBool throwerror);", {plain = true})

        io.replace("include/sqrat/sqratFunction.h", "SQUnsignedInteger nparams;", "SQInteger nparams;", {plain = true})
        io.replace("include/sqrat/sqratFunction.h", "SQUnsignedInteger nfreevars;", "SQInteger nfreevars;", {plain = true})

        os.cp("include/*.h", package:installdir("include"))
        os.cp("include/sqrat/*.h", package:installdir("include/sqrat"))

        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            add_requires("squirrel")
            set_languages("c11", "c++11")

            target("sqratthread")
                set_kind("$(kind)")
                add_defines("SQRATTHREAD_EXPORTS")
                add_files("sqratthread/sqratThread.cpp")
                add_headerfiles("sqratthread/sqratThread.h")
                add_includedirs("include")
                add_packages("squirrel")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end

            target("sqimport")
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
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        if not package:is_cross() then
            os.vrun("sq -v")
        end

        assert(package:check_cxxsnippets({test = [[
            void test() {
                Sqrat::string str = Sqrat::string("sq");
            }
        ]]}, {configs = {languages = "c++11"}, includes = "sqrat.h"}))
    end)
