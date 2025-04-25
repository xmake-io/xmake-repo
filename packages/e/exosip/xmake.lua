package("exosip")
    set_homepage("https://savannah.nongnu.org/projects/exosip")
    set_description("eXosip is a library that hides the complexity of using the SIP protocol for mutlimedia session establishement")
    set_license("GPL-2.0")

    add_urls("https://www.antisip.com/download/exosip2/libexosip2-$(version).tar.gz", {alias = "mirror"})
    add_urls("https://git.savannah.nongnu.org/cgit/exosip.git/snapshot/exosip-$(version).tar.gz", {alias = "archive"})
    add_urls("git://git.savannah.gnu.org/exosip.git", {alias = "github"})

    add_versions("mirror:5.3.0", "5b7823986431ea5cedc9f095d6964ace966f093b2ae7d0b08404788bfcebc9c2")
    add_versions("archive:5.3.0", "66c2b2ddcfdc8807054fa31f72a6068ef66d98bedd9aedb25b9031718b9906a2")
    add_versions("github:5.3.0", "7b0983106eaf7f9bad227922e8905bcf0a7b4f59")
    
    if is_plat("windows") then
        add_resources("5.3.0", "nameser_header", "https://raw.githubusercontent.com/c-ares/c-ares/refs/tags/curl-7_20_0/nameser.h", "8acc1a774896c0d02180b355bcb67dba4935a10e5ef54f4290600ae61bb9aa3d")
    end

    if not is_plat("windows") then
        add_deps("autotools", "pkg-config")
    end
    add_deps("osip", "c-ares", "openssl3")

    if is_plat("windows") then
        add_links("eXosip")
    else
        add_links("eXosip2", "osip2", "osipparser2")
    end

    if is_plat("windows") then
        add_syslinks("dnsapi")
    elseif is_plat("macosx") then
        add_syslinks("resolv")
        add_frameworks("CoreFoundation", "CoreServices", "Security")
    elseif is_plat("bsd", "linux") then
        add_syslinks("pthread", "resolv")
    end

    on_install("windows", function(package)
        import("package.tools.msbuild")
        os.cp("include", package:installdir())
        local headerdir = package:resourcedir("nameser_header")
        os.cp(path.join(headerdir, "../nameser.h"), "include/nameser.h")
        os.cp(path.join(package:scriptdir(), "port", "exosip2.def"), "platform/vsnet/eXosip2.def")
        local arch = package:is_arch("x64") and "x64" or "Win32"
        if package:is_arch("arm64") then
            arch = "ARM64"
            io.replace("platform/vsnet/eXosip.sln", "|x64", "|ARM64", {plain = true})
        end
        local mode = package:is_debug() and "Debug" or "Release"
        local configs = { "eXosip.sln" }
        table.insert(configs, "/t:eXosip")
        table.insert(configs, "/p:Configuration=" .. mode)
        table.insert(configs, "/p:Platform=" .. arch)
        table.insert(configs, "/p:BuildProjectReferences=false")
        local include_paths = {}
        local lib_paths = {}
        local libs = {"dnsapi.lib"}
        for _, dep in ipairs({"osip", "c-ares", "openssl3"}) do
            local packagedep = package:dep(dep)
            if packagedep then
                local fetchinfo = packagedep:fetch()
                if fetchinfo then
                    for _, includedir in ipairs(fetchinfo.includedirs or fetchinfo.sysincludedirs) do
                        table.insert(include_paths, includedir)
                    end
                    for _, linkdir in ipairs(fetchinfo.linkdirs) do
                        table.insert(lib_paths, linkdir)
                    end
                    for _, syslink in ipairs(fetchinfo.syslinks) do
                        table.insert(libs, syslink .. ".lib")
                    end
                    for _, link in ipairs(fetchinfo.libfiles) do
                        -- Exclude ossl-modules/legacy.lib
                        if not link:lower():match("legacy.dll") then
                            table.insert(libs, link)
                        end
                    end
                end
            end
        end
        os.cd("platform/vsnet")    
        io.replace("eXosip.vcxproj",
            "<AdditionalIncludeDirectories>.-</AdditionalIncludeDirectories>",
            "<AdditionalIncludeDirectories>" .. table.concat(include_paths, ";") .. "</AdditionalIncludeDirectories>")
        io.replace("eXosip.vcxproj", [[<AdditionalIncludeDirectories>]], [[<AdditionalIncludeDirectories>..\..\..\source\include;]], {plain = true})
        if package:is_arch("arm64") then
            io.replace("eXosip.vcxproj", "|x64", "|ARM64", {plain = true})
            io.replace("eXosip.vcxproj", "<Platform>x64", "<Platform>ARM64", {plain = true})
        end
        if not package:has_runtime("MT", "MTd") then
            -- Allow MD, MDd
            io.replace("eXosip.vcxproj", "MultiThreadedDebug", "MultiThreadedDebugDLL", {plain = true})
            io.replace("eXosip.vcxproj", "MultiThreaded", "MultiThreadedDLL", {plain = true})
        end
        if package:config("shared") then
            -- Pass .def file
            io.replace("eXosip.vcxproj", [[</ClCompile>]],
                [[</ClCompile><Link><ModuleDefinitionFile>$(ProjectDir)/eXosip2.def</ModuleDefinitionFile></Link>]], {plain = true})
            io.replace("eXosip.vcxproj", [[</Link>]],
                [[<AdditionalLibraryDirectories>]] .. table.concat(lib_paths, ";") .. [[</AdditionalLibraryDirectories><AdditionalDependencies>]] .. table.concat(libs, ";") .. [[</AdditionalDependencies></Link>]], {plain = true})
            -- Allow build shared lib
            io.replace("eXosip.vcxproj", "StaticLibrary", "DynamicLibrary", {plain = true})
        end
        -- Allow use another Win SDK
        io.replace("eXosip.vcxproj", "<WindowsTargetPlatformVersion>10.0.17763.0</WindowsTargetPlatformVersion>", "", {plain = true})
        -- Use *source* dir
        io.replace("eXosip.vcxproj", [[<ClCompile Include="..\..\..\exosip\]], [[<ClCompile Include="..\..\..\source\]], {plain = true})
        io.replace("eXosip.vcxproj", [[<ClInclude Include="..\..\..\exosip\]], [[<ClInclude Include="..\..\..\source\]], {plain = true})
        -- Do not use ProjectReference
        io.replace("eXosip.vcxproj", "<ProjectReference.-</ProjectReference>", "")
        msbuild.build(package, configs)
        os.cp("**.lib", package:installdir("lib"))
        if package:config("shared") then
            os.cp("**.dll", package:installdir("bin"))
        end
    end)

    on_install("linux", "macosx", "android@linux,macosx", "cross", "wasm", function (package)
        if package:is_plat("android") then
            local ndkver = tonumber(package:toolchain("ndk"):config("ndkver"))
            if ndkver > 22 then
                io.replace("src/eXutils.c", [[#elif (_POSIX_C_SOURCE >= 200112L || _XOPEN_SOURCE >= 600 || __APPLE__ || defined(ANDROID)) && !_GNU_SOURCE]],
                        [[#elif 1]], {plain = true})
            end
        end
        local configs = {"--disable-trace", "--enable-pthread=force", "--enable-tools=no"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if not package:debug() then
            table.insert(configs, "--disable-debug")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
          assert(package:has_cfuncs("eXosip_lock", {includes = "eXosip2/eXosip.h", "eXosip2.h"}))
    end)
