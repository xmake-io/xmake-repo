package("mallocvis")
    set_homepage("https://github.com/archibate/mallocvis")
    set_description("allocation visualization in svg graph")

    add_urls("https://github.com/archibate/mallocvis.git")
    
    add_versions("2024.07.17", "371e8dc21fec00adf2b45d7c7bb1b7cce8ac75ff")
    add_patches("2024.07.17", "patches/2024.07.17/fix-build-mingw-bsd.diff", "84276afcc85c3b4256b8a2e124300579c7ecd1587a6ae3680cdfc36d94fa7d66")

    if is_plat("windows", "mingw") then
        add_syslinks("dbghelp")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    on_install("!wasm and !macosx and !iphoneos", function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("addr2sym", {configs = {languages = "c++17"}, includes = "addr2sym.hpp"}))
    end)
