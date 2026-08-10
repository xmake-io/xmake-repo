package("libpg_query")
    set_homepage("https://github.com/pganalyze/libpg_query")
    set_description("PostgreSQL parser C API library")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/pganalyze/libpg_query/archive/refs/tags/$(version).tar.gz",
             "https://github.com/pganalyze/libpg_query.git", {
        version = function (version)
            local m = {
                ["17.6.2"] = "17-6.2.2",
                ["16.5.2"] = "16-5.2.0",
            }
            return m[tostring(version)] or version
        end
    })

    add_versions("18.0.0", "6ad7783f272acfd116455c66a03298a0cac9a9168281df547969219112f0260f")
    add_versions("17.6.2", "e68962c18dbf5890821511be6c5c42261170bf8bfd51a82ea9176069f3d0df8b")
    add_versions("16.5.2", "92bbc9a628655df3de86db51de97446d8ed18b5d23b17039809364d5bc6a4a38")

    if is_plat("linux", "macosx") then
        add_deps("make")
    end

    on_load(function (package)
        package:add("links", "pg_query")
    end)

    on_check("windows", function (package)
        if package:version():lt("16.5.1") then
            raise("package(libpg_query): Windows is supported since version 16.5.1 (16-5.1.0)")
        end

        if package:config("shared") then
            raise("package(libpg_query): Windows only supports static build (--kind=static)")
        end
    end)

    on_install("windows", "linux", "macosx|!x86_64", function (package)
        local configs = {}

        if package:config("shared") then
            table.insert(configs, "build_shared")
        else
            table.insert(configs, "build")
        end

        if package:is_plat("windows") then
            table.insert(configs, "-f")
            table.insert(configs, "Makefile.msvc")
            import("package.tools.nmake").build(package, configs)
        else
            import("package.tools.make").build(package, configs)
        end

        os.cp("*.h", package:installdir("include"))
        os.cp("protobuf/pg_query.proto", package:installdir("include/pg_query"))
        if not package:config("shared") then
            os.trycp("*.a", package:installdir("lib"))
            os.trycp("*.lib", package:installdir("lib"))
        else
            os.trycp("*.dll", package:installdir("bin"))
            os.trycp("*.so*", package:installdir("lib"))
            os.trycp("*.dylib", package:installdir("lib"))
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("pg_query_parse", {includes = "pg_query.h"}))
        assert(package:has_cfuncs("pg_query_free_parse_result", {includes = "pg_query.h"}))
        assert(package:has_cfuncs("pg_query_split_with_scanner", {includes = "pg_query.h"}))
        assert(package:has_cfuncs("pg_query_free_split_result", {includes = "pg_query.h"}))

        assert(package:check_cxxsnippets({test = [[
            void test() {
                PgQueryFingerprintResult result;
                result = pg_query_fingerprint("SELECT 1");
                printf("%s\n", result.fingerprint_str);
                pg_query_free_fingerprint_result(result);
            }
        ]]}, {includes = {"pg_query.h", "stdio.h"}}))
    end)
