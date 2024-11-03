package("zbar")
    set_homepage("https://github.com/mchehab/zbar")
    set_description("Library for reading bar codes from various sources")
    set_license("LGPL-2.1")

    add_urls("https://github.com/mchehab/zbar/archive/refs/tags/$(version).tar.gz",
             "https://github.com/mchehab/zbar.git")
    add_versions("0.23.93", "212dfab527894b8bcbcc7cd1d43d63f5604a07473d31a5f02889e372614ebe28")

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::zbar")
    elseif is_plat("linux") then
        add_extsources("pacman::zbar", "apt::libzbar-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::zbar")
    end

    add_configs("symbologies", {description = "Select symbologies to compile", default = {"ean", "databar", "code128", "code93", "code39", "codabar", "i25", "qrcode", "sqcode"}, type = "table"})

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    elseif is_plat("windows") then
        add_syslinks("winmm")
    end

    add_deps("libiconv")

    on_install(function (package)
        os.cp(path.join(package:scriptdir(), "port", "config.h.in"), "include/config.h.in")
        io.gsub("include/config.h.in", "# ?undef (.-)\n", "${define %1}\n")
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")

        io.replace("zbar/processor.h", "#include <unistd.h>", "", {plain = true})
        
        local configs = {   vers = package:version_str(),
                            symbologies = table.concat(package:config("symbologies"), ",")}

        -- get LIB_VERSION from configure.ac
        -- format: AC_SUBST([LIB_VERSION], [3:0:3])
        local configure_ac = io.readfile("configure.ac")
        for _, key in ipairs({"LIB_VERSION"}) do
            local value = configure_ac:match("AC_SUBST%(%[" .. key .. "%]%s*,%s*%[(.-)%]%)")
            if value then
                configs[key] = value
            end
        end

        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test() {
                zbar_image_scanner_t *scanner ;
                scanner = zbar_image_scanner_create();
                zbar_image_scanner_set_config(scanner, 0, ZBAR_CFG_ENABLE, 1);
                zbar_image_scanner_destroy(scanner);
            }
        ]]}, {includes = "zbar.h"}))
    end)
