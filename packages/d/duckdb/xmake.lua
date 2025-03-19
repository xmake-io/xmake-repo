package("duckdb")
    set_homepage("http://duckdb.org/")
    set_description("DuckDB is an in-process SQL OLAP Database Management System")
    set_license("MIT")

    on_source(function(package)
        local precompiled = false
        if package:is_plat("windows") then
            if package:is_arch("x64", "x86_64") then
                precompiled = true
                package:add("urls", "https://github.com/duckdb/duckdb/releases/download/$(version)/libduckdb-windows-amd64.zip")
                package:add("versions", "v1.2.1", "c977230a701d6b274fe63166868c8e2bc4ec23cf42c44f08f22bdcd8ed4a8e31")
            elseif package:is_arch("arm64") then
                precompiled = true
                package:add("urls", "https://github.com/duckdb/duckdb/releases/download/$(version)/libduckdb-windows-arm64.zip")
                package:add("versions", "v1.2.1", "de02a9e3e64b41ea7844aa04ad7e72519ca131327e739cd344a6ba476fb31c0f")
            end
        elseif package:is_plat("linux") then
            if package:config("shared") then
                if package:is_arch("x64", "x86_64") then
                    precompiled = true
                    package:add("urls", "https://github.com/duckdb/duckdb/releases/download/$(version)/libduckdb-linux-amd64.zip")
                    package:add("versions", "v1.2.1", "8dda081c84ef1da07f19f953ca95e1c6db9b6851e357444a751ad45be8a14d36")
                elseif package:is_arch("arm64") then
                    precompiled = true
                    package:add("urls", "https://github.com/duckdb/duckdb/releases/download/$(version)/libduckdb-linux-arm64.zip")
                    package:add("versions", "v1.2.1", "b1fc7c892414fdc286a7d99cd374634deb586e0fcccc87cb84a2b52272f93bfd")
                end
            elseif package:config("static") then
                if package:is_arch("x64", "x86_64") then
                    precompiled = true
                    package:add("urls", "https://github.com/duckdb/duckdb/releases/download/$(version)/static-lib-linux-amd64.zip")
                    package:add("versions", "v1.2.1", "be614d4b36621bce1da8ad545fd0fc46c6094232ce5fe8a135bf69455110bfa1")
                elseif package:is_arch("arm64") then
                    precompiled = true
                    package:add("urls", "https://github.com/duckdb/duckdb/releases/download/$(version)/static-lib-linux-arm64.zip")
                    package:add("versions", "v1.2.1", "ab5d43238972cfb7ae1852f8890103a056d09ff5ce60623a8515729c49e1d6c0")
                end
            end
        elseif package:is_plat("macos") then
            if package:config("shared") then
                precompiled = true
                package:add("urls", "https://github.com/duckdb/duckdb/releases/download/$(version)/libduckdb-osx-universal.zip")
                package:add("versions", "v1.2.1", "5045ad331e6e738ba4d2299e8726f200be82f6da961f208973f48df7a4532ce1")
            elseif package:config("static") then
                if package:is_arch("x64", "x86_64") then
                    precompiled = true
                    package:add("urls", "https://github.com/duckdb/duckdb/releases/download/$(version)/static-lib-osx-amd64.zip")
                    package:add("versions", "v1.2.1", "be614d4b36621bce1da8ad545fd0fc46c6094232ce5fe8a135bf69455110bfa1")
                elseif package:is_arch("arm64") then
                    precompiled = true
                    package:add("urls", "https://github.com/duckdb/duckdb/releases/download/$(version)/static-lib-osx-arm64.zip")
                    package:add("versions", "v1.2.1", "ab5d43238972cfb7ae1852f8890103a056d09ff5ce60623a8515729c49e1d6c0")
                end
            end
        end

        if not precompiled then
             package:add("urls", "https://github.com/duckdb/duckdb/releases/download/$(version)/libduckdb-src.zip",
                                 "https://github.com/duckdb/duckdb.git")
            package:add("versions", "v1.2.1", "c7f21c12039e951dbb74e064ba218a4ca8b4b0a612d40c62d95a858ecaf2fb53")
            package:add("versions", "v1.1.3", "66beec9f299c56f508fec3d647faa86a596d39b2d4e26bd6991b29d07b818f83")
            package:add("versions", "v1.1.2", "8b30ec65addfe423fc18f8403bd958953d01a3193ec8b3bc2e43073433d94e47")
            package:add("versions", "v1.1.1", "48f1ca566ae0f73fb536aec22d599917f47c26ea7ae300380e7ae3f39e29af4d")
            package:add("versions", "v1.0.0", "482c7f090cac4408eed5b02708b6a54168c1875c2c6d8042d8344edee3f70eb7")
            package:add("versions", "v0.10.3", "f22ed5058188c81886dfdda80c6c46b7df2ed0a623a348c78ac8372451c84497")
            package:add("versions", "v0.10.2", "6bab203dc2e10432edbefda7be7043f73f17c8898ba81ce3aa2319e7e2d5af10")
            package:add("versions", "v0.10.1", "70ec6ffefd9a04bf9fcdc1a4949611f9633f10f0e3b9cead1425b926a54d0f89")
            package:add("versions", "v0.10.0", "385e27aa67712813e4a07389465c4c5c45c431d97cddd35713b8a306d2a86f2d")
        end
        package:data_set("precompiled", precompiled)
    end)

    on_install(function (package)
        if package:data("precompiled") then
            os.trycp("*.dll", package:installdir("lib"))
            os.trycp("*.lib", package:installdir("lib"))
            os.trycp("*.a", package:installdir("lib"))
            os.trycp("*.dylib", package:installdir("lib"))
            os.trycp("*.so", package:installdir("lib"))
            os.trycp("*.h", package:installdir("include"))
            os.trycp("*.hpp", package:installdir("include"))
            return
        end
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "duckdb.hpp"
            using namespace duckdb;

            void test() {
                DuckDB db(nullptr);
                Connection con(db);
            }
        ]]}, {configs = {languages = "cxx17"}}))
    end)
