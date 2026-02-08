package("watcher")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/e-dant/watcher")
    set_description("Filesystem watcher. Works anywhere. Simple, efficient and friendly.")
    set_license("MIT")

    set_urls("https://github.com/e-dant/watcher/archive/refs/tags/release/$(version).tar.gz",
             "https://github.com/e-dant/watcher.git")

    add_versions("0.14.4", "26863d5fbcf241146def09da50dbcbd6c57b43350b85c9d362d58eb1c69b4293")
    add_versions("0.14.3", "ada4dd30bddc78b49f112b0310e4964710c8dcf8a16966c8e958f75bb7abde5e")
    add_versions("0.13.8", "ca415bb6e63012bb92543c2a0c76aec347fb36df48d6c1af8538018dd6584e06")
    add_versions("0.13.6", "b58b3a9f91d96d90080fd56cd998b1649633c43f92fc1bfe5562a000db472016")
    add_versions("0.13.5", "5bb0ea65b94d9444a6853eacff3a9b2121f0415d0ac895388d241f6f8be1e695")
    add_versions("0.13.2", "b037b4717a292892d61f619f9a2497ac0a49e8fd73d2c6bf4f9a6bef320718b2")
    add_versions("0.12.2", "1423b16734e588bce2a79e0ed205c8c2d651eea891b915862d7270873c72ca54")
    add_versions("0.11.0", "dd92496d77b6bc27e27ed28253faae4d81bc58b19407d154bb49504b2af73664")
    add_versions("0.9.5", "41b74d138eec106c35a99e7544def599453a8bf4cf4887ad627e1c9e3355287c")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    elseif is_plat("macosx") then
        add_frameworks("CoreFoundation", "CoreServices")
    end

    if on_check then
        on_check("android", function (package)
            if package:version() and package:version():ge("0.13.5") then
                local ndk = package:toolchain("ndk"):config("ndkver")
                assert(ndk and tonumber(ndk) > 22, "package(watcher >=0.13.5) require ndk version > 22")
            end
        end)
    end

    on_install("!wasm and !iphoneos and !bsd", function (package)
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
