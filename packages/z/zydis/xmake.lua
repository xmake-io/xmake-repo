package("zydis")
    set_homepage("https://zydis.re")
    set_description("Fast and lightweight x86/x86-64 disassembler and code generation library")
    set_license("MIT")

    add_urls("https://github.com/zyantific/zydis/archive/refs/tags/$(version).tar.gz",
             "https://github.com/zyantific/zydis.git")

    add_versions("v4.1.0", "31f23de8abb4cc2efa0fd0e827bbabcaa0f3d00fcaed8598e05295ba7b3806ad")
    add_versions("v4.0.0", "14e991fd97b021e15c77a4726a0ae8a4196d6521ab505acb5c51fc2f9be9530a")
    add_versions("v3.2.1", "349a2d27270e54499b427051dd45f7b6064811b615588414b096cdeeaeb730ad")

    add_patches("v3.2.1", path.join(os.scriptdir(), "patches", "v3.2.1", "cmake.patch"), "8464810921f507206b8c21618a20de0f5b96cbef7656ebc549079f941f8718fc")

    add_configs("tools", {description = "Build tools.", default = false, type = "boolean"})
    add_configs("decoder", {description = "Enable instruction decoding functionality", default = true, type = "boolean"})
    add_configs("encoder", {description = "Enable instruction encoding functionality", default = true, type = "boolean"})
    add_configs("formatter", {description = "Enable instruction formatting functionality", default = true, type = "boolean"})
    add_configs("avx512", {description = "Enable support for AVX-512 instructions", default = true, type = "boolean"})
    add_configs("knc", {description = "Enable support for KNC instructions", default = true, type = "boolean"})
    add_configs("segment", {description = "Enable instruction segment API", default = true, type = "boolean"})

    add_deps("cmake")

    on_load(function (package)
        local zycore_c_vers = {
            ["v3.2.1"] = "v1.1.0",
            ["v4.0.0"] = "v1.4.0",
            ["v4.1.0"] = "v1.5.0",
        }
        package:add("deps", "zycore-c " .. zycore_c_vers[package:version_str()])

        if package:is_plat("android") then
            package:add("patches", "4.0.0", "patches/v4.0.0/cmake.patch", "061b2286e8e96178294f8b25e0c570bf65f8739848ea1de57dd36be710001da4")
            package:add("patches", "4.1.0", "patches/v4.1.0/cmake.patch", "68f0b5d8e043503f26be441cf2f920a215cf1eb1b59205933c3653468f3ccd94")
        end
    end)

    on_install("!wasm and !iphoneos", function (package)
        if package:is_plat("mingw") and package:version():ge("3.2.1") then
            local rc_str = io.readfile("resources/VersionInfo.rc", {encoding = "utf16le"})
            io.writefile("resources/VersionInfo.rc", rc_str, {encoding = "utf8"})
        elseif package:is_plat("macosx") then
            if package:version():eq("3.2.1") then
                io.replace("include/Zydis/ShortString.h", "#pragma pack(push, 1)","", {plain = true})
                io.replace("include/Zydis/ShortString.h", "#pragma pack(pop)","", {plain = true})
            elseif package:version():eq("4.0.0") then
                io.replace("include/Zydis/ShortString.h", "#   pragma pack(push, 1)","", {plain = true})
                io.replace("include/Zydis/ShortString.h", "#   pragma pack(pop)","", {plain = true})
            end
        elseif package:is_plat("windows") and package:version():ge("4.0.0") and (not package:config("shared")) then
            package:add("defines", "ZYDIS_STATIC_BUILD")
        end

        if package:version():ge("4.1.0") then
            io.replace("CMakeLists.txt", "set(ZYDIS_ROOT_PROJECT ON)", "", {plain = true})
        end

        local configs = {"-DZYAN_SYSTEM_ZYCORE=ON"}
        table.insert(configs, "-DZYDIS_BUILD_EXAMPLES=OFF")
        table.insert(configs, "-DZYDIS_BUILD_SHARED_LIB=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DZYDIS_BUILD_TOOLS=" .. (package:config("tools") and "ON" or "OFF"))

        local configs_macro = {
            "ZYDIS_DISABLE_DECODER",
            "ZYDIS_DISABLE_ENCODER",
            "ZYDIS_DISABLE_FORMATTER",
            "ZYDIS_DISABLE_AVX512",
            "ZYDIS_DISABLE_KNC",
            "ZYDIS_DISABLE_SEGMENT",
        }

        for _, macro in ipairs(configs_macro) do
            local config = macro:gsub("ZYDIS_DISABLE_", "")
            if package:config(config:lower()) then
                table.insert(configs, "-DZYDIS_FEATURE_" .. config  .. "=ON")
            else
                table.insert(configs, "-DZYDIS_FEATURE_" .. config  .. "=OFF")
                package:add("defines", macro)
            end
        end
        import("package.tools.cmake").install(package, configs, {packagedeps = "zycore-c"})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ZydisDecoderInit", {includes = "Zydis/Zydis.h"}))
    end)
