package("gpm")
    set_homepage("http://www.nico.schottelius.org/software/gpm/")
    set_description("general purpose mouse")
    set_license("GPL-2.0-or-later")

    add_urls("https://github.com/telmich/gpm.git")
    add_versions("2020.06.17", "e82d1a653ca94aa4ed12441424da6ce780b1e530")

    add_deps("autotools", "bison")
    add_deps("ncurses")

    on_install("linux", "cross", function (package)
        os.mkdir(path.join(package:installdir(), "bin"))
        os.mkdir(path.join(package:installdir(), "sbin"))
        os.mkdir(path.join(package:installdir(), "lib"))
        os.mkdir(path.join(package:installdir(), "include"))
        os.mkdir(path.join(package:installdir(), "etc"))
        io.replace("src/Makefile.in",
            [[gpm lib/libgpm.so.@abi_lev@ lib/libgpm.so @LIBGPM_A@ $(PROG)]],
            [[gpm lib/libgpm.so.@abi_lev@ lib/libgpm.so lib/libgpm.a $(PROG)]], {plain = true})
        local libtool = package:dep("libtool")
        local envs = {}
        if libtool then
            envs.ACLOCAL_PATH = path.join(libtool:installdir("share"), "aclocal")
        end
        local configs = {}
        table.insert(configs, "--enable-static")
        table.insert(configs, "--enable-shared")
        if package:is_debug() then
            table.insert(configs, "--enable-debug")
        end
        local envs = import("package.tools.autoconf").buildenvs(package)
        envs.CFLAGS = (envs.CFLAGS or "") .. " -std=c11"
        import("package.tools.autoconf").install(package, configs, {
            envs = envs,
            makeconfigs = {
                "-C", "src",
                "install",
                "PREFIX=" .. path.unix(package:installdir())
            }
        })
        local libdir = path.join(package:installdir(), "lib")
        os.cd(libdir)
        if package:config("shared") then
            local files = os.files("libgpm.so.*")
            if #files > 0 then
                os.ln(path.filename(files[1]), "libgpm.so")
            end
            os.tryrm("libgpm.a")
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
