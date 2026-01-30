package("xent-core")

    set_homepage("https://github.com/Project-Xent/xent-core")
    set_description("A declarative C++20 layout & reactivity engine")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/Project-Xent/xent-core.git")
    add_versions("0.1.0", "cb485c8")
    
    add_configs("shared", {
        description = "Build shared library", 
        default = false, 
        type = "boolean", 
        readonly = true
    })

    add_deps("yoga")

    on_install(function (package)
        local configs = {kind = package:config("shared") and "shared" or "static"}
        import("package.tools.xmake").install(package, configs)
        os.cp("include/xent", package:installdir("include"))
        if os.isdir("lib") then
            os.cp("lib/*", package:installdir("lib"))
        end
        os.cp("README.md", package:installdir())
        os.cp("LICENSE", package:installdir())
    end)

    on_test(function (package)
        assert(package:has_header("xent/view.hpp") or package:has_header("xent/view.h"))
    end)