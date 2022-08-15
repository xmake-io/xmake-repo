package("luau")

    set_homepage("https://luau-lang.org/")
    set_description("A fast, small, safe, gradually typed embeddable scripting language derived from Lua.")
    set_license("MIT")

    add_urls("https://github.com/Roblox/luau.git")
    add_versions("0.538", "d3b566c258bee3bdccb655c034a11bfc48a586e3")

    add_configs("extern_c", { description = "Use extern C for all APIs.", default = false, type = "boolean" })
    add_configs("build_web", { description = "Build web module.", default = false, type = "boolean" })

    add_deps("cmake")

    on_install("linux", "windows", "mingw|x86_64", "macosx", function(package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "RelWithDebInfo"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DLUAU_BUILD_TESTS=OFF")
        table.insert(configs, "-DLUAU_BUILD_WEB=" .. (package:config("build_web") and "ON" or "OFF"))
        table.insert(configs, "-DLUAU_EXTERN_C=" .. (package:config("extern_c") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs, { buildir = "build" })
        os.trycp("VM/include/*.h", package:installdir("include"))
        os.trycp("Ast/include/*", package:installdir("include"))
        os.trycp("Common/include/*", package:installdir("include"))
        os.trycp("Compiler/include/*", package:installdir("include"))
        -- need to link with Ast last
        local libs = { "Luau.VM", "Luau.Compiler", "Luau.Ast" }
        for _, link in ipairs(libs) do
            package:add("links", link)
        end
        os.trycp("build/*.a", package:installdir("lib"))
        os.trycp("build/*.so", package:installdir("lib"))
        os.trycp("build/*.dylib", package:installdir("lib"))
        os.trycp("build/*.lib", package:installdir("lib"))
        os.trycp("build/*.dll", package:installdir("bin"))
        os.trycp("build/luau*", package:installdir("bin"))
        package:addenv("PATH", "bin")
    end)

    on_test(function(package)
        assert(package:check_cxxsnippets({ test = [[
            #include <lua.h>
            #include <luacode.h>
            #include <lualib.h>

            void test() {
                auto L = luaL_newstate();
                luaL_openlibs(L);
                lua_close(L);
            }
        ]]})
    )
    end)


