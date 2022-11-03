package("threadpool")
    set_homepage("https://github.com/romch007/threadpool")
    set_description("Simple thread pooling library in C++")
    set_license("MIT")

    add_urls("https://github.com/romch007/threadpool.git")
    add_versions("2022.11.03", "01e2d8fdad4f7e9b91237b003028e0badde8f8c6")

    on_load(function (package)
        if not package:config("shared") then
            package:add("defines", "THREADPOOL_STATIC")
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
            threadpool::pool p;
    
            int counter = 0;
    
            p.push([&] {
                counter++;
            });
    
            p.start();
    
            while (p.busy());
          }
        ]]}, {configs = {languages = "c++17"}, includes = "threadpool/pool.hpp"}))
    end)
