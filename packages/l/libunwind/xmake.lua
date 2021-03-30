package("libunwind")

    set_homepage("https://github.com/libunwind/libunwind")
    set_description("This library provides functions for manipulating Unicode strings and for manipulating C strings according to the Unicode standard.")

    add_urls("https://github.com/libunwind/libunwind/releases/download/$(version).tar.gz", {version = function (version)
        return version .. "/libunwind-" .. (version:gsub("v", "")) .. ".0"
    end})
    add_urls("http://download.savannah.nongnu.org/releases/libunwind/libunwind-$(version).tar.gz", {version = function (version)
        return (version:gsub("v", "")) .. ".0"
    end})
    add_urls("https://github.com/libunwind/libunwind.git")
    add_versions("v1.5", "90337653d92d4a13de590781371c604f9031cdb50520366aa1e3a91e1efb1017")

    add_deps("autoconf")

    add_defines("_GNU_SOURCE=1")

    on_install("android", "linux", function (package)
        local configs = {"--enable-coredump=no", "--disable-tests"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:debug() then
            table.insert(configs, "--enable-debug")
        end
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("_Unwind_Backtrace(0, 0)", {includes = "unwind.h"}))
    end)
