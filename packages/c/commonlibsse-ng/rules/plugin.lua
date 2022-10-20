rule("plugin")
    add_deps("win.sdk.resource")

    on_config(function(a_target)
        import("core.base.semver")
        import("core.project.project")

        a_target:set("kind", "shared")
        a_target:set("arch", "x64")

        local version = semver.new(a_target:version())
        local configs = a_target:extraconf("rules", "@commonlibsse-ng/plugin")
        local config_dir = path.join("$(buildir)", ".config", a_target:name())

        local file = io.open(path.join(config_dir, "version.rc"), "w")
        if file then
            file:print("#include <winres.h>")
            file:print("")
            file:print("1 VERSIONINFO")
            file:print("FILEVERSION %s, %s, %s, 0", version:major(), version:minor(), version:patch())
            file:print("PRODUCTVERSION %s, %s, %s, 0", version:major(), version:minor(), version:patch())
            file:print("FILEFLAGSMASK 0x17L")
            file:print("#ifdef _DEBUG")
            file:print("    FILEFLAGS 0x1L")
            file:print("#else")
            file:print("    FILEFLAGS 0x0L")
            file:print("#endif")
            file:print("FILEOS 0x4L")
            file:print("FILETYPE 0x1L")
            file:print("FILESUBTYPE 0x0L")
            file:print("BEGIN")
            file:print("    BLOCK \"StringFileInfo\"")
            file:print("    BEGIN")
            file:print("        BLOCK \"040904b0\"")
            file:print("        BEGIN")
            file:print("            VALUE \"FileDescription\", \"%s\"", configs.description or "")
            file:print("            VALUE \"FileVersion\", \"%s.0\"", a_target:version())
            file:print("            VALUE \"InternalName\", \"%s\"", configs.name or a_target:name())
            file:print("            VALUE \"LegalCopyright\", \"%s, %s\"", configs.author or "", a_target:license())
            file:print("            VALUE \"ProductName\", \"%s\"", project.name())
            file:print("            VALUE \"ProductVersion\", \"%s.0\"", project.version())
            file:print("        END")
            file:print("    END")
            file:print("    BLOCK \"VarFileInfo\"")
            file:print("    BEGIN")
            file:print("        VALUE \"Translation\", 0x409, 1200")
            file:print("    END")
            file:print("END")
            file:close()
        end

        file = io.open(path.join(config_dir, "plugin.cpp"), "w")
        if file then
            local struct_compat = "Independent"
            local runtime_compat = "AddressLibrary"

            if configs.options then
                local address_library = configs.options.address_library or true
                local signature_scanning = configs.options.signature_scanning or false
                if not address_library and signature_scanning then
                    runtime_compat = "SignatureScanning"
                end
            end

            file:print("#include <SKSE/SKSE.h>")
            file:print("#include <REL/Relocation.h>")
            file:print("")
            file:print("using namespace std::literals;")
            file:print("")
            file:print("SKSEPluginInfo(")
            file:print("    .Version = { %s, %s, %s, 0 },", version:major(), version:minor(), version:patch())
            file:print("    .Name = \"%s\"sv,", configs.name or a_target:name())
            file:print("    .Author = \"%s\"sv,", configs.author or "")
            file:print("    .SupportEmail = \"%s\"sv,", configs.email or "")
            file:print("    .StructCompatibility = SKSE::StructCompatibility::%s,", struct_compat)
            file:print("    .RuntimeCompatibility = SKSE::VersionIndependence::%s", runtime_compat)
            file:print(")")
            file:close()
        end

        a_target:add("files", path.join(config_dir, "version.rc"))
        a_target:add("files", path.join(config_dir, "plugin.cpp"))

        a_target:add("defines", "UNICODE", "_UNICODE")

        a_target:add("cxxflags", "/MP", "/permissive-")
        a_target:add("cxxflags",
            "/Zc:alignedNew",
            "/Zc:__cplusplus",
            "/Zc:externConstexpr",
            "/Zc:forScope",
            "/Zc:hiddenFriend",
            "/Zc:preprocessor",
            "/Zc:referenceBinding",
            "/Zc:ternary")
    end)
