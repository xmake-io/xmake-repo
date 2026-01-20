package("vc-ltl5")
    set_homepage("https://github.com/Chuyu-Team/VC-LTL5")
    set_description("Shared to msvcrt.dll or ucrtbase.dll and optimize the C/C++ application file size")
    set_license("EPL-2.0")

    add_urls("https://github.com/Chuyu-Team/VC-LTL5/releases/download/$(version)", {version = function (version)
        if version:ge("5.2.1") then
            return "v" .. version .. "/VC-LTL-Binary.7z"
        else
            return "v" .. version .. "/VC-LTL-" .. version .. "-Binary.7z"
        end
    end})
    add_versions("5.3.1", "7a18799ed3aa84a225610a5447a56bc534c5c98ccb8dec05caba0e3f633431ad")
    add_versions("5.2.2", "04aa46a7d2af655bcf42c4937504525eb7e66a75910ed42fd25a1cdcec587df0")
    add_versions("5.2.1", "0b0b17b7a4ed993701208b2eaeba91f3acf2f1b5402430b52ac7bfbca2519464")
    add_versions("5.1.1", "71eb81ad7d5270cb2a247d6b1c5c01b8efb8f2c869d2e5222be8aafab2fc07de")
    add_versions("5.0.6", "e406f829f75d59c34ee1e34cb6e994eb7db0810123ae7196499f26df88bc0a6f")
    add_versions("5.0.7", "08555aca30b2f77a484534be0799cfed05bfdeb1d1e461d91576264d7123e687")
    add_versions("5.0.9", "71a3099978ff3dc83fe8e2ebddf104e2f916d13cd10fb01fe02317ebc7fb02d9")

    local default_min_version = "6.0.6000.0"
    if is_plat("windows") then
        if is_arch("x64", "x86") then
            default_min_version = "6.0.6000.0"
        elseif is_arch("arm") then
            default_min_version = "6.2.9200.0"
        elseif is_arch("arm64") then
            default_min_version = "10.0.10240.0"
        else
            raise("Unsupported architecture!")
        end
    end

    add_configs("min_version", {description = "Windows Target Platform Min Version", default = default_min_version, type = "string"})
    add_configs("subsystem", {description = "Windows xp subsystem", default = "windows", type = "string", values = {"console", "windows"}})
    add_configs("clean_import", {description = "Do not use ucrt apiset, such as api-ms-win-crt-time-l1-1-0.dll (for geeks) (Duplicated after vc-ltl 5.1 version)", default = false, type = "boolean"})
    add_configs("openmp", {description = "Use openmp library", default = false, type = "boolean", readonly = true})
    add_configs("shared", {description = "Use runtimes configs", default = true, type = "boolean", readonly = true})
    add_configs("debug", {description = "Use runtimes configs", default = false, type = "boolean", readonly = true})

    set_policy("package.precompiled", false)

    on_load(function (package)
        -- check vs version
        local vs = package:toolchain("msvc"):config("vs")
        if vs and tonumber(vs) < 2015 then
            wprint("vc-ltl5 only supports vc14.0 or later versions")
        end
        -- is xp?
        local version = package:version()
        if package:config("min_version"):startswith("5") then
            if version:ge("5.1.0") then
                package:add("deps", "yy-thunks")
                wprint([[package(vc-ltl5 >=5.1) require yy-thunks, you need to use `add_rules("yy-thunks@xp")` for windows xp target]])
            end

            if package:has_runtime("MD") then
                package:add("cxflags", "/Zc:threadSafeInit-")
            end

            local arch
            if package:is_arch("x86") then
                arch = "5.01"
            elseif package:is_arch("x64") then
                arch = "5.02"
            end

            if arch then
                local flag = format("/subsystem:%s,%s", package:config("subsystem"), arch)
                package:add("ldflags", flag)
            end

            if version:ge("5.2.1") and package:has_runtime("MD", "MDd") and package:is_arch("x64", "x86") then
                local url = format("https://github.com/Chuyu-Team/VC-LTL5/releases/download/v%s/VC-LTL.Redist.Dlls.zip", package:version_str())
                package:add("resources", package:version_str(), "dlls", url, "99d99d7df5ce1643c0e8f0aadb457ab177199db8255d7ae5e68ff9c16492cfcd")
            end
        end
    end)

    on_install("windows", function (package)
        import("core.base.semver")

        -- Automatically adapt version
        local min_version = package:config("min_version")
        local semver_min_version = semver.match(min_version)
        if semver_min_version then
            if semver_min_version:ge("10.0.19041") then
                min_version = "10.0.19041.0"
            elseif semver_min_version:ge("10.0.10240") then
                min_version = "10.0.10240.0"
            elseif semver_min_version:ge("6.2.9200") then
                min_version = "6.2.9200.0"
            elseif semver_min_version:ge("6.0.6000") then
                min_version = "6.0.6000.0"
            else
                if package:is_arch("x86") then
                    min_version = "5.1.2600.0"
                elseif package:is_arch("x64") then
                    min_version = "5.2.3790.0"
                end
            end
        else
            wprint("Invalid min_version, use default min_version")
            min_version = default_min_version
        end

        local platform
        if package:is_arch("x86") then
            platform = "Win32"
        elseif package:is_arch("x64") then
            platform = "x64"
        elseif package:is_arch("arm") then
            platform = "ARM"
        elseif package:is_arch("arm64") then
            platform = "ARM64"
        else
            raise("Unsupported architecture!")
        end

        local bindir = "TargetPlatform/" .. min_version

        os.cp("TargetPlatform/header", package:installdir("include"), {rootdir = "TargetPlatform"})
        os.cp(bindir .. "/header", package:installdir("include"), {rootdir = "TargetPlatform"})
        package:add("includedirs", path.join("include", "header"))
        package:add("includedirs", path.join("include", min_version, "header"))

        local libdir = path.join(bindir, "lib", platform)
        assert(os.isdir(libdir), "The architecture is not supported in this version")
        os.cp(libdir .. "/*.*", package:installdir("lib"))
        -- We do not need links, but xmake needs at least one links to add linkdirs
        package:add("links", "vc-ltl5")
        io.writefile("lib.cpp", "")
        io.writefile("xmake.lua", [[
            target("vc-ltl5")
                set_kind("static")
                add_files("lib.cpp")
        ]])
        import("package.tools.xmake").install(package)

        local dlls = package:resourcedir("dlls")
        if dlls then
            os.vcp(path.join(dlls, "Dlls", package:arch()), package:installdir("bin"))
        end

        -- deprecated after vc-ltl 5.1 version
        local clean_import_dir = libdir .. "/CleanImport"
        if package:config("clean_import") and os.isdir(clean_import_dir) then
            os.cp(clean_import_dir, package:installdir("lib"))
            package:add("linkdirs", "lib/CleanImport")
            package:add("linkdirs", "lib")
            -- We need at least one links in CleanImport dir
            package:add("links", "vc-ltl5-CleanImport")
            local old = os.cd(package:installdir("lib"))
            os.cp("vc-ltl5.lib", "CleanImport")
            os.mv("CleanImport/vc-ltl5.lib", "CleanImport/vc-ltl5-CleanImport.lib")
            os.cd(old)
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>

            extern "C" extern int __LTL_vcruntime_module_type;

            void test() {
                std::cout << "Hello World! LTL_vcruntime=" << __LTL_vcruntime_module_type;
            }
        ]]}))
    end)
