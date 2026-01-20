package("libsigcplusplus")
    set_homepage("https://libsigcplusplus.github.io/libsigcplusplus/")
    set_description("libsigc++ implements a typesafe callback system for standard C++. It allows you to define signals and to connect those signals to any callback function, either global or a member function, regardless of whether it is static or virtual.")
    set_license("LGPL-3.0")

    add_urls("https://github.com/libsigcplusplus/libsigcplusplus/archive/refs/tags/$(version).tar.gz",
             "https://github.com/libsigcplusplus/libsigcplusplus.git")

    add_versions("3.8.0", "fb2356847434c2cef8fc6093b2fd571cf9de9ba795d3b8ffe4ab70d1b8553cd9")
    add_versions("3.6.0", "bbe81e4f6d8acb41a9795525a38c0782751dbc4af3d78a9339f4a282e8a16c38")
    add_versions("3.4.0", "445d889079041b41b368ee3b923b7c71ae10a54da03bc746f2d0723e28ba2291")

    add_configs("deprecated_api", {description = "Build deprecated API and include it in the library", default = false, type = "boolean"})
    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("meson", "ninja")
    add_includedirs("include/sigc++-3.0", "lib/sigc++-3.0/include")

    on_install("windows", "linux", "macosx", "mingw", "msys", "iphoneos", "cross", "wasm", function (package)
        local configs = {"-Dvalidation=false", "-Dbuild-examples=false", "-Dbuild-tests=false"}
        table.insert(configs, "-Dbuild-deprecated-api=" .. (package:config("deprecated_api") and "true" or "false"))

        local shflags = {}
        if package:config("shared") then
            table.insert(configs, "-Ddefault_library=shared")

            if package:is_plat("linux", "macosx") then
                shflags = "-lstdc++"
            end
        else
            table.insert(configs, "-Ddefault_library=static")
            if package:is_plat("windows") then
                package:add("defines", "SIGC_BUILD")
            end
        end
        import("package.tools.meson").install(package, configs, {shflags = shflags})
    end)

    on_test(function (package) 
         assert(package:check_cxxsnippets({test = [[ 
            #include <string> 
            #include <sigc++/sigc++.h> 
            void on_print(const std::string& str) {} 
            void test() { 
                sigc::signal<void(const std::string&)> signal_print; 
                signal_print.connect(sigc::ptr_fun(&on_print)); 
                signal_print.emit("hello world\n"); 
            } 
         ]]}, {configs = {languages = "c++17"}}))
    end)
