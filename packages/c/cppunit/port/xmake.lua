add_rules("mode.debug", "mode.release")

set_languages("c++11")

target("cppunit")
    set_kind("$(kind)")
    add_files("src/cppunit/*.cpp|DllMain.cpp")
    add_includedirs("include", {public = true})
    add_headerfiles("include/(cppunit/**.h)")

    if is_kind("shared") then
        add_defines("CPPUNIT_BUILD_DLL")
        add_defines("CPPUNIT_DLL", {interface = true})
    end

    if is_plat("windows", "mingw", "msys", "cygwin") then
        add_files("src/cppunit/DllMain.cpp")
    end

target("DllPlugInTester")
    set_kind("binary")
    add_files(
        "src/DllPlugInTester/CommandLineParser.cpp",
        "src/DllPlugInTester/DllPlugInTester.cpp"
    )

    add_deps("cppunit")
