package("newtondynamics3")
    set_homepage("http://newtondynamics.com")
    set_description("Newton Dynamics is an integrated solution for real time simulation of physics environments.")
    set_license("zlib")

    set_urls("https://github.com/MADEAPPS/newton-dynamics.git")

    add_versions("v3.14d", "e501c6d13e127a595c847d92b12ca3c7616a441d")
    
    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::newton-dynamics")
    elseif is_plat("linux") then
        add_extsources("pacman::newton-dynamics")
    end

    if is_plat("linux", "android") then
        add_syslinks("dl", "pthread")
    end

    on_load(function (package)
        wprint("newtondynamics package has been renamed to newtondynamics3 due to release of v4, please update your dependency to newtondynamics3 or newtondynamics4")
        if package:is_plat("windows") and not package:config("shared") then
            package:add("defines", "_NEWTON_STATIC_LIB")
        end
    end)

    on_install("windows", "linux", "macosx", "mingw", function (package)
        os.cd("newton-3.14")
        local configs = {}
        configs.kind = package:config("shared") and "shared" or "static"
        configs.mode = package:debug() and "debug" or "release"
        if not package:config("shared") and package:is_plat("linux", "android") and package:config("pic") ~= false then
            configs.cxflags = "-fPIC"
        end
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test(int args, char** argv) {
                NewtonWorld* world = NewtonCreate();
                NewtonDestroy(world);
            }
        ]]}, {includes = "newton/Newton.h"}))
    end)
