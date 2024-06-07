package("libspng")

    set_homepage("https://libspng.org")
    set_description("Simple, modern libpng alternative")

    set_urls("https://github.com/randy408/libspng/archive/refs/tags/$(version).tar.gz",
             "https://github.com/randy408/libspng.git")
    add_versions("v0.7.4", "47ec02be6c0a6323044600a9221b049f63e1953faf816903e7383d4dc4234487")
    add_versions("v0.7.1", "0726a4914ad7155028f3baa94027244d439cd2a2fbe8daf780c2150c4c951d8e")

    add_deps("zlib")

    on_load(function (package)
        if not package:config("shared") then
            package:add("defines", "SPNG_STATIC")
        end
    end)

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            add_requires("zlib")
            target("spng")
                set_kind("$(kind)")
                add_files("spng/*.c")
                add_headerfiles("spng/*.h")
                add_packages("zlib")
                if is_kind("static") then
                    add_defines("SPNG_STATIC")
                end
        ]])
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        elseif not package:is_plat("windows", "mingw") and package:config("pic") ~= false then
            configs.cxflags = "-fPIC"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("spng_decode_image", {includes = "spng.h"}))
    end)
