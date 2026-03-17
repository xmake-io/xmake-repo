package("gpm")
    set_homepage("https://www.nico.schottelius.org/software/gpm/")
    set_description("general purpose mouse")
    set_license("GPL-2.0-or-later")

    add_urls("https://github.com/telmich/gpm.git")
    add_versions("2020.06.17", "e82d1a653ca94aa4ed12441424da6ce780b1e530")

    add_deps("autotools", "bison", "texinfo")
    add_deps("ncurses")

    on_install("linux", "cross", function (package)
        local configs = {}
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))

        -- fix gcc15
        local opt = {cxflags = "-std=c11"}
        import("package.tools.autoconf").install(package, configs, opt)

        os.cd(package:installdir("lib"))
        if package:config("shared") then
            local files = os.files("libgpm.so.*")
            if #files > 0 then
                os.ln(path.filename(files[1]), "libgpm.so")
            end
        else
            os.tryrm("libgpm.so*")
        end
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            #include <gpm.h>
            void test() {
                Gpm_Connect conn = {
                    .eventMask = GPM_DOWN | GPM_UP | GPM_DRAG | GPM_MOVE,
                    .defaultMask = 0,
                    .minMod = 0,
                    .maxMod = (unsigned short) ~(1 << 0)
                };
                Gpm_Open(&conn, 0);
            }
        ]]}, {configs = {languages = "c11"}}))
    end)
