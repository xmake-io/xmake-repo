package("osip")
    set_homepage("https://savannah.gnu.org/projects/osip")
    set_description("oSIP is an LGPL implementation of SIP. It is used mostly with eXosip2 stack (GPL) which provides simpler API for User-Agent implementation.")
    set_license("LGPL")

    add_urls("https://git.savannah.gnu.org/cgit/osip.git/snapshot/osip-$(version).tar.gz",
             "https://git.savannah.gnu.org/git/osip.git")

    add_versions("5.3.0", "593c9d61150b230f7e757b652d70d5fe336c84db7e4db190658f9ef1597d59ed")

    if is_plat('wasm') then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    if is_plat("windows") then
        add_syslinks("advapi32")
    else
        add_deps("autoconf", "automake", "m4", "libtool")
    end

    add_links("osip2", "osipparser2")

    on_install("windows", function(package)
        import("package.tools.msbuild")

        os.cp("include", package:installdir())

        -- rename *source* directory to *osip* directory
        local curdir = os.curdir()
        os.cd("..")
        os.mv(curdir, "osip")
        os.cd("osip")

        local arch = package:is_arch("x64") and "x64" or "Win32"
        if package:is_arch("arm64") then
            arch = "ARM64"
            io.replace("platform/vsnet/osip.sln", "|x64", "|ARM64", {plain = true})
        end
        local mode = package:debug() and "Debug" or "Release"
        local configs = { "osip.sln" }
        table.insert(configs, "/property:Configuration=" .. mode)
        table.insert(configs, "/property:Platform=" .. arch)
        os.cd("platform/vsnet")

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

        local files = {
            "osip2.vcxproj",
            "osipparser2.vcxproj"
        }

        for _, vcxproj in ipairs(files) do
            if package:is_arch("arm64") then
                io.replace(vcxproj, "|x64", "|ARM64", {plain = true})
                io.replace(vcxproj, "<Platform>x64", "<Platform>ARM64", {plain = true})
            end
            if not package:has_runtime("MT", "MTd") then
                -- Allow MD, MDd
                io.replace(vcxproj, "MultiThreaded", "MultiThreadedDLL", {plain = true})
                io.replace(vcxproj, "MultiThreadedDebug", "MultiThreadedDebugDLL", {plain = true})
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
        end

        msbuild.build(package, configs)

        os.cp("**.lib", package:installdir("lib"))
        if package:config("shared") then
            os.cp("**.dll", package:installdir("bin"))
        end
    end)

    on_install("!mingw and !android@windows", function (package)
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
