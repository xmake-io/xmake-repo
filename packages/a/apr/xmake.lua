package("apr")
    set_homepage("https://github.com/apache/apr")
    set_description("Mirror of Apache Portable Runtime")
    set_license("Apache-2.0")

    add_urls("https://github.com/apache/apr/archive/refs/tags/$(version).tar.gz",
             "https://github.com/apache/apr.git")
    add_versions("1.7.0", "a7e2c5e6d60f6c7b1611b31a2f914a3e58f44eded5b064f0bae43ff30b16a4e6")

    if is_plat("macosx") then 
        add_deps("autoconf", "libtool", "python")
    elseif is_plat("linux") then
        add_deps("autoconf", "libtool", "python")
        add_patches("1.7.0", path.join(os.scriptdir(), "patches", "1.7.0", "common.patch"), "bbfef69c914ca1ab98a9d94fc4794958334ce5f47d8c08c05e0965a48a44c50d")
    elseif is_plat("windows") then 
        add_deps("cmake")
    end
    
    on_install("linux", "macosx", "windows", function (package)
        if package:is_plat("linux") then 
            os.vrunv("sh", {"./buildconf"})
            io.replace("configure", "RM='$RM'", "RM='$RM -f'")
            os.vrunv("./configure", {"--prefix=" .. package:installdir()})
            import("package.tools.make").install(package)
            os.mv(package:installdir("include/apr-1/*"), package:installdir("include"))
        elseif package:is_plat("macosx") then 
            os.exec("sed -i -e 's/#error .* pid_t/#define APR_PID_T_FMT \"d\"/' configure.in")
            os.vrunv("sh", {"./buildconf"})
            os.exec("./configure CFLAGS=-DAPR_IOVEC_DEFINED --prefix=" .. package:installdir())
            import("package.tools.make").install(package)
            os.mv(package:installdir("include/apr-1/*"), package:installdir("include"))
        elseif package:is_plat("windows") then
            local vs = import("core.tool.toolchain").load("msvc"):config("vs")
            local msvc_version
            if tonumber(vs) == 2019 then
                msvc_version = "Visual Studio 16 2019"
            elseif tonumber(vs) == 2022 then
                msvc_version = "Visual Studio 17 2022"
            else
                raise("unsupported msvc version " .. vs)
            end
            local arch = os.arch()
            local configuration = package:debug() and "Debug" or "Release"
            os.vrun("cmake -G \"" .. msvc_version .. "\" -A " .. arch)
            import("package.tools.msbuild").build(package, {"apr.sln", "/p:platform=" .. arch, "/p:configuration=" .. configuration})
            os.mv("*.h", package:installdir("include"))
            os.mv("include/*.h", package:installdir("include"))
            os.mv(configuration .. "/*.lib", package:installdir("lib"))
            os.mv(configuration .. "/*.dll", package:installdir("lib"))
        end
    end)

    on_test(function (package)
        assert(package:has_cincludes("apr.h"))
    end)
