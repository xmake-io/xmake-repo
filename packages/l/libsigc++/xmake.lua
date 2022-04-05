package("libsigc++")

    set_homepage("https://libsigcplusplus.github.io/libsigcplusplus")
    set_description("Callback framework for C++")
    set_license("LGPL-3.0-or-later")

    add_urls("https://download.gnome.org/sources/libsigc++/$(version).tar.xz", {version = function (version)
        return version:major() .. "." .. version:minor() .. "/libsigc++-" .. version
    end})
    add_versions("3.0.7", "bfbe91c0d094ea6bbc6cbd3909b7d98c6561eea8b6d9c0c25add906a6e83d733")

    add_deps("meson", "ninja")
    if is_plat("linux") then
        add_deps("m4")
    end

    add_includedirs("include/sigc++-3.0", "lib/sigc++-3.0/include")

    on_install("macosx", "linux", function (package)
        local configs = {"-Dbuild-examples=false"}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
        #include <iostream>
        #include <string>
        #include <sigc++/sigc++.h>
        void on_print(const std::string& str) {
          std::cout << str;
        }
        void test() {
          sigc::signal<void(const std::string&)> signal_print;
          signal_print.connect(sigc::ptr_fun(&on_print));
          signal_print.emit("hello world\\n");
        }
        ]]}, {configs = {languages = "c++17"}}))
    end)
