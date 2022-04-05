package("ifort")

    set_kind("toolchain")
    set_homepage("https://www.intel.com/content/www/us/en/developer/tools/oneapi/fortran-compiler.html")
    set_description("The Fortran Compiler provided by Intel®")

    if is_host("linux") then
        add_urls("https://registrationcenter-download.intel.com/akdlm/irc_nas/18210/l_fortran-compiler_p_$(version).sh", {version = function(version)
            return version:gsub("%+", ".")
        end})
        add_versions("2021.4.0+3224", "7fef4c98a86db04061634a462e8e4743d9a073f805c191db2a83ee161cea5313")
    elseif is_host("windows") then
        add_urls("https://registrationcenter-download.intel.com/akdlm/irc_nas/18215/w_fortran-compiler_p_$(version).exe", {version = function(version)
            return version:gsub("%+", ".")
        end})
        add_versions("2021.4.0+3208", "942e2f466ec70198a6137a60e3a96880a09cddce3a4a89c449dce20cad5d7a5a")
    elseif is_host("macosx") then
        add_urls("https://registrationcenter-download.intel.com/akdlm/irc_nas/18341/m_HPCKit_p_$(version)_offline.dmg", {version = function(version)
            return version:gsub("%+", ".")
        end})
        add_versions("2022.1.0+86", "c215cc7be7530fe0a60f4bda43923226d41f88a296134852252076a740a205c0")
    end

    on_fetch("@linux", function(package, opt)
        if opt.system then
            local ifortenv = import("detect.sdks.find_ifortenv")()
            if ifortenv then
                package:addenv("PATH", ifortenv.bindir)
                package:addenv("LD_LIBRARY_PATH", ifortenv.libdir)
                return true
            end
        end
    end)

    on_install("@linux", function(package)
        local arch = package:is_arch("x86_64") and "intel64" or "ia32"
        local plat = package:plat()
        local version = package:version():shortstr()
        local installdir = package:installdir()
        local homedir = path.absolute("home")
        if package:is_plat("windows") then
            -- windows is starting 'bootstrapper.exe' in another process
            -- and therefore xmake thinks it is done, so currently we need
            -- to disable it
            -- We could wait until the 'bootstrapper.exe' is done and then continue, maybe.
            os.execv(package:originfile(), {"-a", "-s", "--eula", "accept", "-p=NEED_VS2017_INTEGRATION=0", "--install-dir", installdir}, {envs = {HOME = homedir}})
        elseif package:is_plat("macosx") then
            -- this will cause the user permissions of the installation directory to
            -- be modified to root, so we can only temporarily disable the installation
            -- under macosx.
            plat = "macos"
            local mountdir
            local result = os.iorunv("hdiutil", {"attach", package:originfile()})
            if result then
                for _, line in ipairs(result:split("\n", {plain = true})) do
                    local pos = line:find("/Volumes", 1, true)
                    if pos then
                        mountdir = line:sub(pos):trim()
                        break
                    end
                end
            end
            assert(mountdir and os.isdir(mountdir), "cannot mount %s", package:originfile())
            os.cp(path.join(mountdir, "bootstrapper.app"), "bootstrapper.app")
            os.execv("hdiutil", {"detach", mountdir})
            os.execv("sh", {"bootstrapper.app/Contents/MacOS/install.sh",
                "-s", "--eula", "accept", "--install-dir", installdir}, {envs = {HOME = homedir}})
            package:addenv("DYLD_LIBRARY_PATH", path.join(installdir, "compiler", version, plat, "compiler/lib", arch))
        else
            os.execv("sh", {package:originfile(), "-a", "-s", "--eula", "accept", "--install-dir", installdir}, {envs = {HOME = homedir}})
            package:addenv("LD_LIBRARY_PATH", path.join(installdir, "compiler", version, plat, "compiler/lib", arch))
        end
        package:addenv("PATH", path.join(installdir, "compiler", version, plat, "bin", arch))
    end)

    on_test(function (package)
        os.runv("ifort --version")
    end)
