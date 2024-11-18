package("watcher")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/e-dant/watcher")
    set_description("Filesystem watcher. Works anywhere. Simple, efficient and friendly.")
    set_license("MIT")

    set_urls("https://github.com/e-dant/watcher/archive/refs/tags/release/$(version).tar.gz",
             "https://github.com/e-dant/watcher.git")

    add_versions("0.13.2", "b037b4717a292892d61f619f9a2497ac0a49e8fd73d2c6bf4f9a6bef320718b2")
    add_versions("0.12.2", "1423b16734e588bce2a79e0ed205c8c2d651eea891b915862d7270873c72ca54")
    add_versions("0.11.0", "dd92496d77b6bc27e27ed28253faae4d81bc58b19407d154bb49504b2af73664")
    add_versions("0.9.5", "41b74d138eec106c35a99e7544def599453a8bf4cf4887ad627e1c9e3355287c")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    elseif is_plat("macosx") then
        add_frameworks("CoreFoundation", "CoreServices")
    end

    on_install("windows", "linux", "macosx", "mingw", "msys", "android", "cross", function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <wtr/watcher.hpp>
            void test() {
                auto cb = [](wtr::event const& ev) {};
                auto watcher = wtr::watch(".", cb);
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
