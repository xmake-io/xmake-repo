package("backward-cpp")

    set_homepage("https://github.com/bombela/backward-cpp")
    set_description("Backward is a beautiful stack trace pretty printer for C++.")
    set_license("MIT")

    add_configs("bfd", {description = "Get stack trace with details about your sources by using libbfd from binutils.", default = false, type = "boolean"})

    add_urls("https://github.com/bombela/backward-cpp/archive/refs/tags/$(version).zip",
             "https://github.com/bombela/backward-cpp.git")
    add_versions("v1.6", "9b07e12656ab9af8779a84e06865233b9e30fadbb063bf94dd81d318081db8c2")

    if is_plat("mingw") then
        add_patches("v1.6", path.join(os.scriptdir(), "patches", "v1.6", "link_to_imagehlp.patch"), "0a135b6d68970ff6609a3eb4deb2b10c317eee15ba980eb178b93402a97c957c")

        if is_arch("i386") then
            add_patches("v1.6", path.join(os.scriptdir(), "patches", "v1.6", "fix_32bit_ssize_t_typedef.patch"), "fb372fe5934984aecb00b3153f737f63a542ff9359d159a9bcb79c5d54963b42")
        end
    end

    add_deps("cmake")

    on_load("linux", "mingw@msys", "macos", function (package)
        if package:config("bfd") then
            package:add("deps", "binutils")
        end
    end)

    on_install("linux", "mingw", "macosx", "windows|!arm*", function (package)
        if package:config("bfd") and package:is_plat("linux", "mingw@msys", "macos") then
            package:add("syslinks", "bfd")
            package:add("defines", "BACKWARD_HAS_BFD=1")
        end
        local configs = {"-DBACKWARD_TESTS=OFF"}
        table.insert(configs, "-DBACKWARD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
        os.mv(package:installdir("include/*.hpp"), package:installdir("include/backward"))
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("backward::SignalHandling", {configs = {languages = "c++11"}, includes = "backward/backward.hpp"}))
    end)

