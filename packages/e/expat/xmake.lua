package("expat")

    set_homepage("https://libexpat.github.io")
    set_description("XML 1.0 parser")
    set_license("MIT")

    set_urls("https://github.com/libexpat/libexpat/releases/download/R_$(version).tar.bz2", {version = function (version) return version:gsub("%.", "_") .. "/expat-" .. version end})

    add_versions("2.2.10", "b2c160f1b60e92da69de8e12333096aeb0c3bf692d41c60794de278af72135a5")
    add_versions("2.2.6", "17b43c2716d521369f82fc2dc70f359860e90fa440bea65b3b85f0b246ea81f2")

    if is_plat("windows") then
        add_deps("cmake")
    end

    on_install("windows", function (package)
        local configs = {"-DEXPAT_BUILD_EXAMPLES=OFF", "-DEXPAT_BUILD_TESTS=OFF", "-DEXPAT_BUILD_DOCS=OFF"}
        table.insert(configs, "-DEXPAT_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_install("linux", "macosx", function (package)
        local configs = {"--without-examples", "--without-tests", "--without-docbook"}
        if package:config("shared") then
            table.insert(configs, "--enable-shared=yes")
            table.insert(configs, "--enable-static=no")
        else
            table.insert(configs, "--enable-shared=no")
            table.insert(configs, "--enable-static=yes")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        -- assert(package:has_cfuncs("XML_ParserCreate", {includes = "expat.h"}))
        assert(package:check_csnippets({test = [[
            void test() {
                XML_Parser p = XML_ParserCreate(NULL);
            }
        ]]}, {configs = {languages = "c99"}, includes = "expat.h"}))
    end)
