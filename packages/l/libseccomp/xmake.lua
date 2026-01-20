package("libseccomp")
    set_homepage("https://github.com/seccomp/libseccomp")
    set_description("The libseccomp library provides an easy to use, platform independent, interface to the Linux Kernel's syscall filtering mechanism.")
    set_license("LGPL-2.1")

    add_urls("https://github.com/seccomp/libseccomp/releases/download/v$(version)/libseccomp-$(version).tar.gz",
             "https://github.com/seccomp/libseccomp.git")
    add_versions("2.6.0", "83b6085232d1588c379dc9b9cae47bb37407cf262e6e74993c61ba72d2a784dc")

    add_configs("tools", {description = "Build tools.", default = false, type = "boolean"})

    add_deps("gperf")
    on_load(function (package)
        if package:gitref() then
            package:add("deps", "autotools")
        end
    end)

    on_install("linux", function (package)
        local configs = {
            "--disable-dependency-tracking",
            "--disable-python"
        }

        local subdirs = {"include", "src"}
        if package:config("tools") then
            table.insert(subdirs, "tools")
        end
        io.replace("Makefile.in", "include src tools tests doc", table.concat(subdirs, " "), {plain = true})

        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("seccomp_version", {includes = "seccomp.h"}))
    end)
