package("jrtplib")

    set_homepage("https://research.edm.uhasselt.be/jori/page")
    set_description("C++ RTP library")

    add_urls("https://research.edm.uhasselt.be/jori/jrtplib/jrtplib-$(version).tar.gz", {alias = "home"})
    add_urls("https://github.com/j0r1/JRTPLIB/archive/refs/tags/$(version).tar.gz", {alias = "github"})
    add_versions("home:3.11.2", "7a7c7f547c8ee661b0fe4d2ad9b36d7f4655d646141c035d62a000c05a8d4f02")
    add_versions("github:v3.11.2", "591bf6cddd0976a4659ed4dd2fada43140e5f5f9c9dbef56b137a3023549673f")

    add_deps("jthread")

    add_configs("configs", {description = "Configs for this library.", default = "", type = "string"})

    add_deps("cmake")
    on_install("linux", "macosx", function (package)
        local confs = {}
        local jthread_dir = package:dep("jthread"):installdir("lib") .. "/cmake/JThread"
        table.insert(confs, "-DJThread_DIR=" .. jthread_dir)
        string.gsub(package:config("configs"), '[^ ]+', function(w)
            table.insert(confs, w)
        end)
        import("package.tools.cmake").install(package, confs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <jrtplib3/rtpsession.h>

            using namespace jrtplib;
            static void test() {
              RTPSession sess;
              sess.IsActive();
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
