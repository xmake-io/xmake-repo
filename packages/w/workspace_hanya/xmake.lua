package("workspace_hanya")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/CodingHanYa/workspace")
    set_description("Workspace is a lightweight asynchronous execution framework based on C++11")
    set_license("Apache-2.0")

    set_urls("https://github.com/CodingHanYa/workspace.git")

    add_versions("2023.5.8", "d53b4f6a2900db328168ca7b496edc976308e4e6")

    add_deps("cmake")

    if is_plat("linux") then
        add_syslinks("pthread")
    end

    on_install("windows", "linux", "macosx", "mingw", function (package)
        if is_plat("linux") then
            io.replace("CMakeLists.txt", "install(DIRECTORY ${LIB_HEADER} DESTINATION ${INSTALL_INCLUDEDIR}/${LIB_NAME})", "install(DIRECTORY ${LIB_HEADER} DESTINATION ${LIB_NAME})", {plain = true})
        end
        import("package.tools.cmake").install(package, configs)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <workspace/workspace.h>

            int main() {
                wsp::workbranch br("My First BR", 2);
                br.submit([]{ std::cout<<"hello world"<<std::endl; });  
                auto result = br.submit([]{ return 2023; });  
                std::cout<<"Got "<<result.get()<<std::endl;   
                br.wait_tasks(1000); 
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
