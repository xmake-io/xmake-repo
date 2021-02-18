package("libffi")

    set_homepage("https://sourceware.org/libffi/")
    set_description("Portable Foreign Function Interface library.")

    set_urls("https://sourceware.org/pub/libffi/libffi-$(version).tar.gz",
             "https://deb.debian.org/debian/pool/main/libf/libffi/libffi_$(version).orig.tar.gz",
             "https://github.com/atgreen/libffi.git")
    add_versions("3.2.1", "d06ebb8e1d9a22d19e38d63fdb83954253f39bedc5d46232a05645685722ca37")

    on_load(function (package)
        if package:gitref() then
            package:add("deps", "autoconf", "automake", "libtool")
        else
            package:add("includedirs", "lib/libffi-" .. package:version_str() .. "/include")
        end
    end)

    on_install("macosx", "linux", "iphoneos", function (package)
        local configs = {"--disable-silent-rules", "--disable-dependency-tracking"}
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
        assert(package:has_cfuncs("ffi_closure_alloc", {includes = "ffi.h"}))
    end)
