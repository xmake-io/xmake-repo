package("exosip")

    set_homepage("http://savannah.nongnu.org/projects/exosip/")
    set_description("A library that hides the complexity of using the SIP protocol for mutlimedia session establishement")

    add_urls("http://download.savannah.nongnu.org/releases/exosip/libexosip2-$(version).tar.gz")
    add_versions("5.2.1", "87256b45a406f3c038e1e75e31372d526820366527c2af3bb89329bafd87ec42")
    add_versions("5.1.3", "abdee47383ee0763a198b97441d5be189a72083435b5d73627e22d8fff5beaba")

    add_deps("osip", "c-ares", "openssl")

    add_configs("configs", {description = "Configs for this library.", default = "", type = "string"})

    on_install("windows", function(package)
        import("package.tools.msbuild")
        local name = path.filename(os.curdir())
        os.cd("..")
        local cur_dir = os.curdir() .. "\\"
        os.mv(cur_dir .. name, cur_dir .. "\\exosip")
        os.cd(cur_dir .. "\\exosip")
        local arch = package:is_arch("x64") and "x64" or "x86"
        local mode = package:debug() and "Debug" or "Release"
        local configs = { "eXosip.sln" }
        table.insert(configs, "/t:eXosip")
        table.insert(configs, "/property:Configuration=" .. mode)
        table.insert(configs, "/property:Platform=" .. arch)
        table.insert(configs, "/p:BuildProjectReferences=false")
        local deps_include_dir = ""
        local deps_lib_dir = ""
        for _, dep in pairs(package:deps()) do
            print("dep ", dep:name(), "include: ", dep:installdir("include"))
            deps_include_dir = deps_include_dir .. dep:installdir("include") .. ";"
            deps_lib_dir = deps_lib_dir .. dep:installdir("lib") .. ";"
        end
        for name, envv in pairs(msbuild.buildenvs()) do
            print(name, ": ", envv)
            if name == "INCLUDE" then
                deps_include_dir = deps_include_dir .. envv
            end
            if name == "LIB" then
                deps_lib_dir = deps_lib_dir .. envv
            end
        end
        table.insert(configs, "/p:IncludePath=\"" .. deps_include_dir .. "\"")
        table.insert(configs, "/p:LibPath=\"" .. deps_lib_dir .. "\"")
        local oldir = os.cd("platform/vsnet")
        msbuild.build(package, configs)
        os.cd(oldir)
        os.vcp("include/eXosip2/*.h", package:installdir("include/eXosip2"))
        if package:config("shared") then
            os.vcp(path.join("platform/vsnet/v141", arch, mode, "eXosip.lib"), package:installdir("lib"))
            os.vcp(path.join("platform/vsnet/v141", arch, mode, "eXosip.dll"), package:installdir("lib"))
        else
            os.vcp(path.join("platform/vsnet/v141", arch, mode, "eXosip.lib"), package:installdir("lib"))
        end
    end)

    on_install("linux", "macosx", function (package)
        local confs = {}
        string.gsub(package:config("configs"), '[^ ]+', function(w)
            table.insert(confs, w)
        end)
        import("package.tools.autoconf").install(package, confs)
    end)

    on_test(function (package)
        local confs = {}
        if package:plat() == "windows" then
            confs["defines"] = "WIN32"
            confs["cflags"] = "/c"
        end
        assert(package:check_cxxsnippets({test = [[
            #include <eXosip2/eXosip.h>
            #ifdef WIN32
                #include <winsock.h>
            #endif

            static void test() {
              eXosip_t* sip = eXosip_malloc();
              eXosip_quit(sip);
            }
        ]]}, {configs = confs}))
    end)
