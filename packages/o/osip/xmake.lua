package("osip")
    set_homepage("https://savannah.gnu.org/projects/osip")
    set_description("oSIP is an LGPL implementation of SIP. It is used mostly with eXosip2 stack (GPL) which provides simpler API for User-Agent implementation.")
    set_license("LGPL")

    add_urls("https://git.savannah.gnu.org/cgit/osip.git/snapshot/osip-$(version).tar.gz",
             "https://git.savannah.gnu.org/git/osip.git")

    add_versions("5.3.0", "593c9d61150b230f7e757b652d70d5fe336c84db7e4db190658f9ef1597d59ed")

    if not is_plat("windows") then
        add_deps("autoconf", "automake", "m4", "libtool")
    else
        add_syslinks("advapi32")
    end

    add_links("osip2", "osipparser2")

    on_install("windows", function(package)
        os.cp("include/**.h", package:installdir("include"), {rootdir = "include"})
        -- rename *source* directory to *osip* directory
        local name = path.filename(os.curdir())
        os.cd("..")
        local cur_dir = os.curdir() .. "\\"
        os.mv(cur_dir .. name, cur_dir .. "\\osip")
        os.cd(cur_dir .. "\\osip")

        import("package.tools.msbuild")

        local arch = package:is_arch("x64") and "x64" or "Win32"
        if package:is_plat("arm.*") then
            arch = "ARM64"
        end
        local mode = package:debug() and "Debug" or "Release"

        local configs = { "osip.sln" }

        table.insert(configs, "/property:Configuration=" .. mode)
        table.insert(configs, "/property:Platform=" .. arch)

        os.cd("platform/vsnet")

        -- Add external symbols into .def file for .DLL library
        local file = io.open("osip2.def", "a")
        if file then
            file:write("     osip_transaction_set_naptr_record @138\n")
            file:close()
        end

        local filep = io.open("osipparser2.def", "a")
        if filep then
            filep:write("     osip_realloc @417\n")
            filep:write("     osip_strcasestr @418\n")
            filep:write("     __osip_uri_escape_userinfo @419\n")
            filep:write("     osip_list_clone @420\n")
            filep:close()
        end

        local files = {
            "osip2.vcxproj",
            "osipparser2.vcxproj"
        }

        for _, vcxproj in ipairs(files) do
            if package:is_plat("arm64") then
                io.replace(vcxproj, "x64", "ARM64", {plain = true})
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

    on_install("linux", "macosx", function (package)
        local configs = {"--disable-trace"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if not package:debug() then
            table.insert(configs, "--disable-debug")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("osip_cond_signal", {includes = "osip2/osip_condv.h"}))
    end)
