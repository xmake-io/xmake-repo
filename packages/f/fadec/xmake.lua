package("fadec")
    set_homepage("https://aengelke.net/fadec.html")
    set_description("A fast and lightweight decoder for x86 and x86-64 and encoder for x86-64.")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/aengelke/fadec.git")

    add_versions("2025.08.21", "3994d89500985491b1a7ccc17827a22058b3de49")

    add_configs("arch", {description = "Support only 32-bit x86, 64-bit x86 or both", default = "both", type = "string", values = {"both", "only32", "only64"}})
    add_configs("undoc", {description = "Include undocumented instructions", default = false, type = "boolean"})
    add_configs("decode", {description = "Include support for decoding", default = true, type = "boolean"})
    add_configs("encode", {description = "Include support for encoding", default = false, type = "boolean"})
    add_configs("encode2", {description = "Include support for new encoding API", default = false, type = "boolean"})

    add_deps("cmake", "python 3.x", {kind = "binary"})

    on_install(function (package)
        assert(package:config("decode") or package:config("encode") or package:config("encode2"),
            "at least one of 'decode', 'encode' or 'encode2' must be enabled")

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:config("shared") and package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end

        table.insert(configs, "-DFADEC_ARCHMODE=" .. package:config("arch"))
        table.insert(configs, "-DFADEC_UNDOC=" .. (package:config("undoc") and "ON" or "OFF"))
        table.insert(configs, "-DFADEC_DECODE=" .. (package:config("decode") and "ON" or "OFF"))
        table.insert(configs, "-DFADEC_ENCODE=" .. (package:config("encode") and "ON" or "OFF"))
        table.insert(configs, "-DFADEC_ENCODE2=" .. (package:config("encode2") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        if package:config("decode") then
            assert(package:has_cfuncs("fd_decode", {includes = "fadec.h"}))
        end
        if package:config("encode") then
            assert(package:check_csnippets({test = [[
                void test() {
                    int failed = 0;
                    uint8_t buf[64];
                    uint8_t* cur = buf;

                    // xor eax, eax
                    failed |= fe_enc64(&cur, FE_XOR32rr, FE_AX, FE_AX);
                }
            ]]}, {configs = {languages = "c11"}, includes = "fadec-enc.h"}))
        end
        if package:config("encode2") then
            assert(package:has_cfuncs("fe64_XOR32rr", {includes = "fadec-enc2.h"}))
        end
    end)
