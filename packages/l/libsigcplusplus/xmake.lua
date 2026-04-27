package("libsigcplusplus")
    set_homepage("https://libsigcplusplus.github.io/libsigcplusplus/")
    set_description("libsigc++ implements a typesafe callback system for standard C++. It allows you to define signals and to connect those signals to any callback function, either global or a member function, regardless of whether it is static or virtual.")
    set_license("LGPL-3.0")

    add_urls("https://github.com/libsigcplusplus/libsigcplusplus/releases/download/$(version)/libsigc++-$(version).tar.xz",
             "https://github.com/libsigcplusplus/libsigcplusplus.git")

    add_versions("3.8.0", "502a743bb07ed7627dd41bd85ec4b93b4954f06b531adc45818d24a959f54e36")
    add_versions("3.6.0", "c3d23b37dfd6e39f2e09f091b77b1541fbfa17c4f0b6bf5c89baef7229080e17")
    add_versions("3.4.0", "02e2630ffb5ce93cd52c38423521dfe7063328863a6e96d41d765a6116b8707e")
	add_versions("2.12.1", "a9dbee323351d109b7aee074a9cb89ca3e7bcf8ad8edef1851f4cf359bd50843")

    add_configs("deprecated_api", {description = "Build deprecated API and include it in the library", default = false, type = "boolean"})
    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("meson", "ninja")
    on_load(function (package)
        package:add("includedirs",
            "include/sigc++-" .. package:version():major() .. ".0",
            "lib/sigc++-" .. package:version():major() .. ".0/include")
    end)

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
