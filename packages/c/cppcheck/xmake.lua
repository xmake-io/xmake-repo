package("cppcheck")
    set_kind("binary")
    set_homepage("https://cppcheck.sourceforge.io/")
    set_description("A static analysis tool for C/C++ code")

    add_urls("https://github.com/danmar/cppcheck/archive/refs/tags/$(version).tar.gz")
    add_versions("2.19.1", "49bdf1d7826d60053575b78d3192d81d54970dbfb356590f7476de250b1a4234")
    add_versions("2.18.3", "e37c94e190cdddc65682649b02b72939761585bddd8ada595f922e190a26a2be")
    add_versions("2.18.1", "528841c0f00de5ed41428269df7a30b102af0b1f8ad50f5b7d4ee2997b54c04c")
    add_versions("2.18.0", "dc74e300ac59f2ef9f9c05c21d48ae4c8dd1ce17f08914dd30c738ff482e748f")
    add_versions("2.17.1", "bfd681868248ec03855ca7c2aea7bcb1f39b8b18860d76aec805a92a967b966c")
    add_versions("2.16.2", "521b996cb56b0c30f89e022abcb50aef85d7219cb7a7162fa81fe40fe6394206")
    add_versions("2.15.0", "98bcc40ac8062635b492fb096d7815376a176ae26749d6c708083f4637f7c0bb")
    add_versions("2.14.2", "9c3acea5f489336bd83a8ea33917a9a04a80c56d874bf270287e7de27acf2d00")
    add_versions("2.14.1", "22d1403fbc3158f35b5216d7b0a50bbaf0c80bf6663933a71f65cc4fc307ff3d")
    add_versions("2.13.4", "d6ea064ebab76c6aa000795440479767d8d814dd29405918df4c1bbfcd6cb86c")
    add_versions("2.13.0", "8229afe1dddc3ed893248b8a723b428dc221ea014fbc76e6289840857c03d450")

    add_deps("cmake")

    on_install("windows|x64", "macosx", "linux", "msys", function (package)
        io.replace("cmake/findDependencies.cmake", "find_program(LIBXML2_XMLLINT_EXECUTABLE xmllint)", "", {plain = true})

        local configs = {"-DLIBXML2_XMLLINT_EXECUTABLE=OFF"}
        if package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_COMPILE_PDB_OUTPUT_DIRECTORY=''")
        end

        io.replace("cmake/compileroptions.cmake", "add_compile_options($<$<NOT:$<CONFIG:Debug>>:/MD>)", "", {plain = true})
        io.replace("cmake/compileroptions.cmake", "add_compile_options($<$<NOT:$<CONFIG:Debug>>:/MDd>)", "", {plain = true})
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        os.vrun("cppcheck --version")
    end)
