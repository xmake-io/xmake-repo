package("libuuid")

    set_homepage("https://sourceforge.net/projects/libuuid")
    set_description("Portable uuid C library")

    set_urls("https://sourceforge.net/projects/libuuid/files/libuuid-$(version).tar.gz",
             "https://git.code.sf.net/p/libuuid/code.git")

    add_versions("1.0.3", "46af3275291091009ad7f1b899de3d0cea0252737550e7919d17237997db5644")

    on_install("linux", "macosx", "wasm", function(package)
        local configs = {}
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

    on_test(function(package)
        assert(package:check_csnippets({
            test = [[
                void test() {
                    uuid_t buf;
                    char str[100];
                    uuid_generate(buf);
	                uuid_unparse(buf, str);
                }
            ]]
        }, {configs = {languages = "c11"}, includes = "uuid/uuid.h"}))
    end)
