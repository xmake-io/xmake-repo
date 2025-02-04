package("glpk")
    set_homepage("https://www.gnu.org/software/glpk/")
    set_description("The GLPK (GNU Linear Programming Kit) package is intended for solving large-scale linear programming (LP), mixed integer programming (MIP), and other related problems.")
    set_license("GPL-3.0")

    set_urls("https://ftp.gnu.org/gnu/glpk/glpk-$(version).tar.gz")

    add_versions("5.0", "4a1013eebb50f728fc601bdd833b0b2870333c3b3e5a816eeba921d95bec6f15")

    add_configs("dl", {description = "Eenable shared library support", default = nil, type = "string", values = {"ltdl", "dlfcn"}})
    add_configs("gmp", {description = "Enable gmp support", default = false, type = "boolean"})
    add_configs("mysql", {description = "enable MathProg MySQL support", default = false, type = "boolean", readonly = true})
    add_configs("odbc", {description = "enable MathProg ODBC support", default = false, type = "boolean", readonly = true})
    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    if is_plat("linux") then
        add_extsources("apt::libglpk-dev")
    end

    add_deps("zlib")

    on_load(function (package)
        if package:config("gmp") then
            package:add("deps", "gmp")
        end
        if package:config("mysql") then
            package:add("deps", "mysql")
        end
        local dl = package:config("dl")
        if dl == "ltdl" then
            package:add("deps", "libtool", {kind = "library"})
        elseif dl == "dlfcn" then
            if package:is_plat("linux", "bsd") then
                package:add("syslinks", "dl")
            end
            -- src/env/dlsup.c will use LoadLibrary/GetProcAddress/FreeLibrary
            -- if package:is_plat("windows") then
            --     package:add("deps", "dlfcn-win32")
            -- end
        end
    end)

    on_install(function (package)
        if package:is_plat("windows") and package:config("shared") then
            local def = "glpk.def"
            local version = package:version()
            local arch_dir = package:is_arch64() and "w64" or "w32"
            local basename = format("%s/glpk_%d_%d.def", arch_dir, version:major(), version:minor())
            os.vcp(basename, def)
            -- glp_netgen_prob is not defined, but should be disabled
            -- see: https://www.mail-archive.com/bug-glpk@gnu.org/msg01020.html
            io.replace(def, "glp_netgen_prob\n", "", {plain = true})
        end

        local configs = {
            dl = package:config("dl"),
            gmp = package:config("gmp"),
            mysql = package:config("mysql"),
            odbc = package:config("odbc"),
        }
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
    end)

    on_install("macosx", "linux", function (package)
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        table.insert(configs, "--enable-mysql=" .. (package:config("mysql") and "yes" or "no"))
        table.insert(configs, "--enable-odbc=" .. (package:config("odbc") and "yes" or "no"))
        local dl = package:config("dl")
        if dl then
            table.insert(configs, "--enable-dl=" .. dl)
        else
            table.insert(configs, "--disable-dl")
        end
        if package:config("gmp") then
            table.insert(configs, "--with-gmp")
        else
            table.insert(configs, "--without-gmp")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <glpk.h>
            int main() {
              glp_prob* prob = glp_create_prob();
              if (prob) {
                glp_delete_prob(prob);
              }
              return 0;
            }
        ]]}))
    end)
