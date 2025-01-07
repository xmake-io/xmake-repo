package("libgit2cpp")
    set_homepage("https://github.com/AndreyG/libgit2cpp")
    set_description("C++ wrapper for libgit2")

    add_urls("https://github.com/AndreyG/libgit2cpp.git", {submodules = false})
    add_versions("2024.06.09", "e9651575e388d7e5832ff64955b2f3304bac33db")

    add_configs("boost", {description = "Use boost", default = false, type = "boolean"})
    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    add_deps("cmake")
    add_deps("libgit2")

    on_load(function (package)
        if package:config("boost") then
            package:add("deps", "boost")
        end
        if is_subhost("windows") then
            package:add("deps", "pkgconf")
        end
    end)

    on_install(function (package)
        local configs = {"-DBUNDLE_LIBGIT2=OFF", "-DBUILD_LIBGIT2CPP_EXAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_BOOST=" .. (package:config("boost") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                const char* dir = ".";
                git::Repository repo{dir};
                repo.index();
            }
        ]]}, {configs = {languages = "c++17"}, includes = "git2cpp/repo.h"}))
    end)
