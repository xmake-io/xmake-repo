package("libffi")

    set_homepage("https://sourceware.org/libffi/")
    set_description("Portable Foreign Function Interface library.")

    set_urls("http://sourceware.org/pub/libffi/libffi-$(version).tar.gz",
             "https://github.com/libffi/libffi/releases/download/v$(version)/libffi-$(version).tar.gz",
             "https://github.com/libffi/libffi.git")
    add_versions("3.2.1", "d06ebb8e1d9a22d19e38d63fdb83954253f39bedc5d46232a05645685722ca37")
    add_versions("3.3", "72fba7922703ddfa7a028d513ac15a85c8d54c8d67f55fa5a4802885dc652056")

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
        if package:is_plat("linux") and package:is_arch("x86_64") then
            local lib64 = path.join(package:installdir(), "lib64")
            if os.isdir(lib64) then
                package:add("links", "ffi")
                package:add("linkdirs", "lib64")
            end
        end
        print(os.files(package:installdir("**")))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ffi_closure_alloc", {includes = "ffi.h"}))
    end)
