package("funchook")
    set_homepage("https://github.com/kubo/funchook")
    set_description("Hook function calls by inserting jump instructions at runtime.")
    set_license("GPL-2.0-or-later")

   add_urls("https://github.com/kubo/funchook/archive/refs/tags/$(version).tar.gz",
            "https://github.com/kubo/funchook.git")

    add_versions("v1.1.3", "4b0195e70524237e222dc34c53ac25e12677bb936e64eefe33189931688444c4")

    -- Warning: This patch cannot be used with the latest commit.
    add_patches("*", "patches/fix-build-system-deps.patch", "fe01ce372df7cb4c5c2420ed2be3486772f723007ff254fc277103a5eaf1bddc")
    add_patches("*", "patches/fix-function-visibility.patch", "5b505ad24332320f3970a6cb56b5f550b01b9c80aa14cea0fea74ac77f1fc8f3")

    add_configs("disasm", {description = "Disassembler engine.", default = nil, type = "string", values = {"capstone", "distorm", "zydis"}})

    add_deps("cmake")
    on_load(function(package)
        if package:is_plat("windows") then
            package:add("syslinks", "psapi")
        else
            -- unix
            package:add("syslinks", "dl")
        end
        package:add("links", "funchook")
        if package:config("shared") and package:is_plat("windows") then
            package:add("links", "funchook_dll")
        end
        if not package:config("disasm") then
            -- default disasm engine.
            if package:is_arch("arm64") then
                package:add("deps", "capstone")
            else
                package:add("deps", "distorm")
            end
        else
            if package:config("disasm") == "zydis" then
                -- The latest commit updated to 4.x, but we must use 3.x for the current version.
                package:add("deps", "zydis 3.2.1")
            else
                package:add("deps", package:config("disasm"))
            end
        end
    end)

    on_install("linux|x86_64", "linux|i386", "linux|arm64", "macosx|x86_64", "windows|x86", "windows|x64", function (package)
        local configs = {
            "-DFUNCHOOK_BUILD_TESTS=OFF"
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE="  .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DFUNCHOOK_BUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DFUNCHOOK_BUILD_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        if package:config("disasm") then
            if package:is_arch("arm64") then
                table.insert(configs, "-DFUNCHOOK_DISASM=capstone")
            else
                table.insert(configs, "-DFUNCHOOK_DISASM=" .. package:config("disasm"))
            end
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test() {
                funchook_t *funchook = funchook_create();
            }
        ]]}, {configs = {languages = "c99"}, includes = "funchook.h"}))
    end)
