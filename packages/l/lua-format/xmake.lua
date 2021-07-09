package("lua-format")
    set_kind("binary")
    set_homepage("https://github.com/Koihik/LuaFormatter")
    set_description("Code formatter for Lua")
    add_urls("https://github.com/Koihik/LuaFormatter.git")
    add_versions("1.3.5", "638ec8a7c114a0082ce60481afe8f46072e427e5")
    add_deps("cmake")

    on_install("@linux", "@macosx", "@windows", "@bsd", "@msys", function (package)
        local configs = {"-DBUILD_TESTS=OFF", "-DCOVERAGE=OFF"}
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        os.run("lua-format --help")
    end)
