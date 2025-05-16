package("replxx")
    set_homepage("https://github.com/AmokHuginnsson/replxx")
    set_description("A readline and libedit replacement that supports UTF-8, syntax highlighting, hints and Windows and is BSD licensed.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/AmokHuginnsson/replxx.git")
    add_versions("2021.11.25", "1f149bfe20bf6e49c1afd4154eaf0032c8c2fda2")

    add_deps("cmake")
    add_configs("shared",  {description = "Build shared library", default = false, type = "boolean", readonly = true})
    
    on_load(function(package)
        if package:is_plat("linux", "bsd") then
            package:add("syslinks", "pthread")
        end
        if not package:config("shared") then
            package:add("defines", "REPLXX_STATIC")
        end
    end)

    on_install("windows", "linux", "macosx", "bsd", function (package)
        local configs = {"-DCMAKE_CXX_STANDARD=11"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({
            test = [[
                #include <replxx.hxx>
                int main() {
                    replxx::Replxx rx;
                    rx.invoke(replxx::Replxx::ACTION::CLEAR_SELF, 0);
                }
            ]]
        }, {configs = {languages = "c++11"}}))
    end)
