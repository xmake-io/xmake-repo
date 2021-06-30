package("jthread")

    set_homepage("https://research.edm.uhasselt.be/jori/page")
    set_description("C++ thread for JRTPLIB")

    add_urls("https://research.edm.uhasselt.be/jori/jthread/jthread-$(version).tar.gz", {alias = "home"})
    add_urls("https://github.com/j0r1/JThread/archive/refs/tags/$(version).tar.gz", {alias = "github"})
    add_versions("home:1.3.3", "be68d2fae9ef0da64e7ba1d89b90d59882093575b3a36a25105dd54bdecac2fa")
    add_versions("github:v1.3.3", "5e24779acff268989099a1e135f928ea4f366780d9d7466919037a1414451b95")

    add_configs("configs", {description = "Configs for this library.", default = "", type = "string"})

    add_deps("cmake")
    on_install("linux", "macosx", function (package)
        local confs = {}
        string.gsub(package:config("configs"), '[^ ]+', function(w)
            table.insert(confs, w)
        end)
        import("package.tools.cmake").install(package,confs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <jthread/jmutex.h>

            using namespace jthread;
            static void test() {
              JMutex mutex;
              mutex.IsInitialized();
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
