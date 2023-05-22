package("workspace")

    set_homepage("https://github.com/CodingHanYa/workspace")
    set_description("workspace是基于C++11的轻量级异步执行框架")
    set_license("Apache-2.0")

    set_urls("https://github.com/CodingHanYa/workspace.git")

    add_versions("2023_5_8", "d53b4f6a2900db328168ca7b496edc976308e4e6")

    add_deps("cmake")

    on_load("linux", "macosx", "mingw", function(package) 
        package:add("links", "pthread")
    end)

    on_install("windows", "linux", "macosx", "mingw", function (package)
        import("package.tools.cmake").install(package, configs)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <workspace/workspace.h>

            int main() {
                // 2 threads
                wsp::workbranch br("My First BR", 2);
                // return void
                br.submit([]{ std::cout<<"hello world"<<std::endl; });  
                // return std::future<int>
                auto result = br.submit([]{ return 2023; });  
                std::cout<<"Got "<<result.get()<<std::endl;   
                // wait for tasks done (timeout: 1000 milliseconds)
                br.wait_tasks(1000); 
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
