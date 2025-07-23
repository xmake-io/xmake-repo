package("peloader")
    set_kind("binary")
    set_homepage("https://github.com/Hagrid29/PELoader")
    set_description("PE loader with various shellcode injection techniques")

    add_urls("https://github.com/Hagrid29/PELoader.git")

    add_versions("2022.10.17", "bb0fdb546abc670fa5a600fe6f35e988d38ff9fe")

    add_deps("libpeconv")

    on_install("@windows", "@mingw", "@msys", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            add_requires("libpeconv")
            target("PELoader")
                set_kind("binary")
                add_files("PELoader/PELoader/*.cpp")
                add_headerfiles("PELoader/PELoader/*.h")
                add_syslinks("ktmw32")
                add_packages("libpeconv")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        os.vrun("PELoader")
    end)
