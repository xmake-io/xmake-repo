package("wfrest")
    set_homepage("https://github.com/wfrest/wfrest")
    set_description("wfrest: C++ Web Framework REST API")
    set_license("Apache-2.0")

    add_urls("https://github.com/wfrest/wfrest/archive/refs/tags/$(version).tar.gz",
             "https://github.com/wfrest/wfrest.git")

    add_versions("v0.9.3", "9be3c5fb53de3e0067af78b60d312a24ac9fcae70a8f7f47b95bbe38edabbe15")

    add_deps("openssl")
    add_deps("workflow")
    add_deps("zlib")

    if is_plat("linux") then
        add_syslinks("pthread", "dl")
    end

    on_install("linux", "macosx", "android", function (package)
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        local packagedeps = {"workflow"}
        import("package.tools.xmake").install(package, configs, {packagedeps = packagedeps})
        if package:config("shared") then
            os.tryrm(path.join(package:installdir("lib"), "*.a"))
        else
            os.tryrm(path.join(package:installdir("lib"), "*.so"))
            os.tryrm(path.join(package:installdir("lib"), "*.dylib"))
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
        #include "wfrest/HttpServer.h"
        void test() {
            wfrest::HttpServer svr;
            if (svr.start(8888) == 0)
            {
                svr.stop();
            }
        }
    ]]}, {configs = {languages = "c++11"}}))
    end)
