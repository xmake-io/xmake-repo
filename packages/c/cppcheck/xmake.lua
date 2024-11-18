package("cppcheck")
    set_kind("binary")
    set_homepage("https://cppcheck.sourceforge.io/")
    set_description("A static analysis tool for C/C++ code")

    add_urls("https://github.com/danmar/cppcheck/archive/refs/tags/$(version).tar.gz")
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
