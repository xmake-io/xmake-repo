package("osip")
    set_homepage("https://savannah.gnu.org/projects/osip")
    set_description("oSIP is an LGPL implementation of SIP. It is used mostly with eXosip2 stack (GPL) which provides simpler API for User-Agent implementation.")
    set_license("LGPL")

    add_urls("https://www.antisip.com/download/exosip2/libosip2-$(version).tar.gz", {alias = "mirror"})
    add_urls("https://git.savannah.gnu.org/cgit/osip.git/snapshot/osip-$(version).tar.gz", {alias = "archive"})
    add_urls("https://git.savannah.gnu.org/git/osip.git", {alias = "github"})

    add_versions("mirror:5.3.0", "f4725916c22cf514969efb15c3c207233d64739383f7d42956038b78f6cae8c8")
    add_versions("archive:5.3.0", "593c9d61150b230f7e757b652d70d5fe336c84db7e4db190658f9ef1597d59ed")
    add_versions("github:5.3.0", "63846b845929236dbd4d9e51cbd256baf84b8dad")

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    if is_plat("windows") then
        add_syslinks("advapi32")
    else
        add_deps("autoconf", "automake", "libtool")
    end

    add_links("osip2", "osipparser2")

    on_install("windows", function(package)
        import("package.tools.msbuild")
        os.cp("include", package:installdir())
        local arch = package:is_arch("x64") and "x64" or "Win32"
        if package:is_arch("arm64") then
            arch = "ARM64"
            io.replace("platform/vsnet/osip.sln", "|x64", "|ARM64", {plain = true})
        end
        local mode = package:is_debug() and "Debug" or "Release"
        local configs = { "osip.sln" }
        table.insert(configs, "/property:Configuration=" .. mode)
        table.insert(configs, "/property:Platform=" .. arch)
        os.cd("platform/vsnet")
        -- Use *source* folder instead of *osip* folder
        io.replace("osip2.vcxproj", [[<ProjectReference Include="..\..\..\osip\platform\vsnet\osipparser2.vcxproj">]], [[<ProjectReference Include="..\..\..\source\platform\vsnet\osipparser2.vcxproj">]], {plain = true})
        -- Add external symbols into .def file for .DLL library
        local osip2_def_content = io.readfile("osip2.def")
        io.writefile("osip2.def", osip2_def_content .. [[
            osip_transaction_set_naptr_record @138
        ]])
        local osipparser2_def_content = io.readfile("osipparser2.def")
        io.writefile("osipparser2.def", osipparser2_def_content .. [[
            osip_realloc @417
            osip_strcasestr @418
            __osip_uri_escape_userinfo @419
            osip_list_clone @420
        ]])
        local vcxprojs = { "osip2.vcxproj", "osipparser2.vcxproj" }
        for _, vcxproj in ipairs(vcxprojs) do
            if package:is_arch("arm64") then
                io.replace(vcxproj, "|x64", "|ARM64", {plain = true})
                io.replace(vcxproj, "<Platform>x64", "<Platform>ARM64", {plain = true})
            end
            if not package:has_runtime("MT", "MTd") then
                -- Allow MD, MDd
                io.replace(vcxproj, "MultiThreadedDebug", "MultiThreadedDebugDLL", {plain = true})
                io.replace(vcxproj, "MultiThreaded", "MultiThreadedDLL", {plain = true})
            end
            if package:config("shared") then
                -- Pass .def file
                io.replace(vcxproj, "</ClCompile>",
                    "</ClCompile><Link><ModuleDefinitionFile>$(ProjectDir)/$(TargetName).def</ModuleDefinitionFile></Link>", {plain = true})
                -- Allow build shared lib
                io.replace(vcxproj, "StaticLibrary", "DynamicLibrary", {plain = true})
            end
            -- Allow use another Win SDK
            io.replace(vcxproj, "<WindowsTargetPlatformVersion>10.0.17763.0</WindowsTargetPlatformVersion>", "", {plain = true})
            -- Use *source* folder instead of *osip* folder
            io.replace(vcxproj, [[<AdditionalIncludeDirectories>..\..\..\osip\include;]], [[<AdditionalIncludeDirectories>..\..\..\source\include;]], {plain = true})
            io.replace(vcxproj, [[<ClCompile Include="..\..\..\osip\]], [[<ClCompile Include="..\..\..\source\]], {plain = true})
            io.replace(vcxproj, [[<ClInclude Include="..\..\..\osip\]], [[<ClInclude Include="..\..\..\source\]], {plain = true})
        end
        msbuild.build(package, configs)
        os.cp("**.lib", package:installdir("lib"))
        if package:config("shared") then
            os.cp("**.dll", package:installdir("bin"))
        end
    end)

    on_install("linux", "macosx", "bsd", "android@linux,macosx", "iphoneos", "cross", "wasm", function (package)
        local configs = {"--disable-trace"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if not package:debug() then
            table.insert(configs, "--disable-debug")
        end
        if package:is_plat("android") then
            table.insert(configs, "--enable-pthread=force")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("osip_cond_signal", {includes = "osip2/osip_condv.h"}))
    end)
