package("pedeps")
    set_homepage("https://github.com/brechtsanders/pedeps")
    set_description("Cross-platform C library to read data from PE/PE+ files (the format of Windows .exe and .dll files)")
    set_license("MIT")

    add_urls("https://github.com/brechtsanders/pedeps/releases/download/$(version)/pedeps-$(version).tar.xz",
             "https://github.com/brechtsanders/pedeps.git")

    add_versions("0.1.15", "41e6239ff27deed21ad435567f3f8f1c049d072c86a37c2005fd74aea906f1d3")

    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})

    on_install(function (package)
        if not package:config("shared") and package:is_plat("windows", "mingw", "msys") then
            package:add("defines", "STATIC")
        end

        io.writefile("xmake.lua", [[
            option("tools", {default = false})
            add_rules("mode.debug", "mode.release")
            rule("tools")
                on_load(function (target)
                    if not get_config("tools") then
                        target:set("enabled", false)
                        return
                    end

                    target:add("kind", "binary")
                    target:add("deps", "pedeps")
                end)
            target("pedeps")
                set_kind("$(kind)")
                add_files("lib/*.c")
                add_headerfiles("lib/*.h")
                add_includedirs("lib", {public = true})
                if is_kind("static") then
                    add_defines("BUILD_PEDEPS_STATIC")
                elseif is_kind("shared") then
                    add_defines("BUILD_PEDEPS_DLL")
                end
            for _, file in ipairs(os.files("src/*.c")) do
                target(path.basename(file))
                    add_rules("tools")
                    add_files(file)
            end
        ]])
        import("package.tools.xmake").install(package, {tools = package:config("tools")})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("pefile_create", {includes = "pedeps.h"}))
    end)
