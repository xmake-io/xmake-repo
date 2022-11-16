package("simplethreadpool")
    set_homepage("https://github.com/romch007/simplethreadpool")
    set_description("Simple thread pooling library in C++")
    set_license("MIT")

    add_urls("https://github.com/romch007/simplethreadpool.git")

    on_load(function (package)
        if not package:config("shared") then
            package:add("defines", "SIMPLETHREADPOOL_STATIC")
        end
    end)

    on_install(function (package)
        local configs = {}
        configs.kind = package:config("shared") and "shared" or "static"
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
          void test() {
            simplethreadpool::pool p;
            int counter = 0;
            p.push([&] {
                counter++;
            });
            p.start();
            while (p.busy());
          }
        ]]}, {configs = {languages = "c++17"}, includes = "simplethreadpool/pool.hpp"}))
    end)
