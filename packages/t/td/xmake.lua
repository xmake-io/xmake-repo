package("td")
    set_homepage("https://core.telegram.org/tdlib/")
    set_description("Cross-platform library for building Telegram clients.")
    set_license("BSL-1.0")

    -- td doesn't seem to like tags, so we go directly to commit id.
    -- @see https://github.com/tdlib/td/commits/HEAD/example/web/tdweb/package.json
    add_urls("https://github.com/tdlib/td.git")
    add_versions("1.8.51", "bb474a201baa798784d696d2d9d762a9d2807f96")

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")
    add_deps("openssl3", "zlib", "gperf")

    on_check("@msys", function (package)
        -- @see https://github.com/xmake-io/xmake-repo/pull/7855#issuecomment-3176844746
        if is_subhost("msys") and not package:is_arch64() then
            raise("package(td): MINGW32 under MSYS will not be able to compile this package due to insufficient memory.")
        end
    end)

    on_load(function(package)
        if package:is_plat("linux", "bsd") then
            package:add("syslinks", "pthread", "dl")
        elseif package:is_plat("android") then
            package:add("syslinks", "dl", "log")
        elseif package:is_plat("windows", "mingw", "msys", "cygwin") then
            package:add("syslinks", "ws2_32", "mswsock", "crypt32", "normaliz", "psapi")
        end

        if package:is_cross() then
            package:add("deps", "tdtl " .. package:version_str())
        end

        package:add("links", "tdjson", "tdjson_static", "tdjson_private", "tdclient", "tdcore", "tdcore_part1", "tdcore_part2", "tdmtproto", "tdapi", "tddb", "tdsqlite", "tdnet", "tdactor", "tde2e", "tdutils")
        if not package:config("shared") then
            package:add("defines", "TDJSON_STATIC_DEFINE")
        end
    end)

    on_install(function (package)
        function install_header(from_dir, to_dir)
            os.cp(from_dir .. "/**.h", package:installdir("include/" .. to_dir), {rootdir = from_dir})
            os.cp(from_dir .. "/**.hpp", package:installdir("include/" .. to_dir), {rootdir = from_dir})
        end

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DTD_INSTALL_STATIC_LIBRARIES=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DTD_INSTALL_SHARED_LIBRARIES=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DTD_ENABLE_LTO=" .. (package:config("lto") and "ON" or "OFF"))
        if package:is_cross() then
            os.cd("td/generate")
            os.mkdir("auto")
            print("Generate TLO files")
            os.mkdir("auto/tlo")
            os.vrun("tl-parser -e auto/tlo/mtproto_api.tlo scheme/mtproto_api.tl")
            os.vrun("tl-parser -e auto/tlo/secret_api.tlo scheme/secret_api.tl")
            os.vrun("tl-parser -e auto/tlo/e2e_api.tlo scheme/e2e_api.tl")
            os.vrun("tl-parser -e auto/tlo/td_api.tlo scheme/td_api.tl")
            os.vrun("tl-parser -e auto/tlo/telegram_api.tlo scheme/telegram_api.tl")
            os.cd("auto")
            os.mkdir("td")
            os.mkdir("td/telegram")
            os.mkdir("td/mtproto")
            print("Generate MTProto API source files")
            os.vrun("generate_mtproto")
            print("Generate common TL source files")
            os.vrun("generate_common")
            print("Generate JSON TL source files")
            os.vrun("generate_json")
            print("Generate MIME Types source files")
            os.cd("../../../tdutils/generate")
            os.mkdir("auto")
            os.vrun("generate_mime_types_gperf mime_types.txt auto/mime_type_to_extension.gperf auto/extension_to_mime_type.gperf")
            os.vrun("gperf -m100 --output-file=auto/mime_type_to_extension.cpp auto/mime_type_to_extension.gperf")
            os.vrun("gperf -m100 --output-file=auto/extension_to_mime_type.cpp auto/extension_to_mime_type.gperf")
            os.cd("../..")
        end
        if is_plat("mingw", "msys") then
            io.replace("td/generate/tl-parser/wgetopt.h", "#ifdef __GNU_LIBRARY__", "#if 1", {plain = true})
            io.replace("td/generate/tl-parser/wgetopt.c", "extern char *getenv();", "#include <stdlib.h>", {plain = true})
        end

        import("package.tools.cmake").install(package, configs, {target = package:config("shared") and "tdjson" or "tdjson_static", builddir = "build"})

        if not package:config("shared") then
            install_header("td/mtproto", "td/mtproto")
            install_header("td/telegram", "td/telegram")
            install_header("tdnet/td/net", "td/net")
            install_header("tddb/td/db", "td/db")
            install_header("tdactor/td/actor", "td/actor")
            install_header("tde2e/td/e2e", "td/e2e")
            install_header("tdutils/td/utils", "td/utils")
            os.cp("build/tdutils/td/utils/config.h", package:installdir("include/td/utils"))
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                td_json_client_create();
            }
        ]]}, {configs = {languages = "c++17"}, includes = "td/telegram/td_json_client.h"}))
    end)
