package("ifort")

    set_kind("toolchain")
    set_homepage("https://www.intel.com/content/www/us/en/developer/tools/oneapi/fortran-compiler.html")
    set_description("The Fortran Compiler provided by Intel®")

    -- add_resources("2021.4.0", "script", "https://registrationcenter-download.intel.com/akdlm/irc_nas/18210/l_fortran-compiler_p_2021.4.0.3224.sh", "7fef4c98a86db04061634a462e8e4743d9a073f805c191db2a83ee161cea5313")
    add_versions("2021.4.0", "")

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
	local version = package:version_str()
        os.execv("curl", {"https://registrationcenter-download.intel.com/akdlm/irc_nas/18210/l_fortran-compiler_p_" .. version .. ".3224.sh", "-o", path.join(package:cachedir(), "install_ifort.sh")})
        os.cd(package:cachedir())
        
        local script_path = "./install_ifort.sh"
        os.run("chmod +x " .. script_path) 
        local argv = {}
        table.insert(argv, "-a")
        table.insert(argv, "-s")
        table.insert(argv, "--eula")
        table.insert(argv, "accept")

        os.execv(script_path, argv)

        local arch = package:arch()
        package:addenv("PATH", path.join("~/intel/oneapi/compiler", version, "linux/bin", arch == "x86_64" and "intel64" or "ia32"))
        package:addenv("LD_LIBRARY_PATH", path.join("~/intel/oneapi/compiler", version, "linux/compiler/lib", arch == "x86_64" and "intel64" or "ia32"))
    end)

    on_test(function (package)
        os.runv("ifort --version")
    end)
