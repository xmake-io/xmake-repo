package("openjdk")
    set_homepage("https://jdk.java.net")
    set_description("Java Development Kit builds, from Oracle")
    set_license("GPL-2.0")

    if is_host("windows", "mingw") then
        add_urls("https://download.java.net/java/GA/jdk$(version)/6e380f22cbe7469fa75fb448bd903d8e/9/GPL/openjdk-$(version)_windows-x64_bin.zip")
        add_versions("20.0.2", "7e5870fd2e19b87cbd1981c4ff7203897384c2eb104977f40ce4951b40ab433e")
    elseif is_host("linux") then
        if is_arch("x86_64") then
            add_urls("https://download.java.net/java/GA/jdk$(version)/6e380f22cbe7469fa75fb448bd903d8e/9/GPL/openjdk-$(version)_linux-x64_bin.tar.gz")
            add_versions("20.0.2", "beaf61959c2953310595e1162b0c626aef33d58628771033ff2936609661956c")
        elseif is_arch("arm64") then
            add_urls("https://download.java.net/java/GA/jdk$(version)/6e380f22cbe7469fa75fb448bd903d8e/9/GPL/openjdk-$(version)_linux-aarch64_bin.tar.gz")
            add_versions("20.0.2", "3238c93267c663dbca00f5d5b0e3fbba40e1eea2b4281612f40542d208b6dd9a")
        end
    elseif is_host("macosx") then
        if is_arch("x86_64") then
            add_urls("https://download.java.net/java/GA/jdk$(version)/6e380f22cbe7469fa75fb448bd903d8e/9/GPL/openjdk-$(version)_macos-x64_bin.tar.gz")
            add_versions("20.0.2", "c65ba92b73d8076e2a10029a0674d40ce45c3e0183a8063dd51281e92c9f43fc")
        elseif is_arch("arm64") then
            add_urls("https://download.java.net/java/GA/jdk$(version)/6e380f22cbe7469fa75fb448bd903d8e/9/GPL/openjdk-$(version)_macos-x64_bin.tar.gz")
            add_versions("20.0.2", "2e6522bb574f76cd3f81156acd59115a014bf452bbe4107f0d31ff9b41b3da57")
        end
    end

    add_configs("shared", {description = "Download shared binaries.", default = true, type = "boolean", readonly = true})

    if is_plat("linux") then
        add_deps("alsa-lib", {configs = {shared = true, versioned = false}})
        add_deps("freetype", "libxtst", "libxi", "libxrender")
        add_extsources("pacman::jdk-openjdk", "apt::default-jdk")
    elseif is_plat("macosx") then
        add_extsources("brew::openjdk")
    end

    on_fetch("windows", "mingw", function (package, opt)
        if opt.system then
            local sdkdir = os.getenv("JAVA_HOME")
            if os.isdir(sdkdir) then
                local result = {}
                result.includedirs = {path.join(sdkdir, "include"), path.join(sdkdir, "include", "win32")}
                result.linkdirs = path.join(sdkdir, "lib")
                result.links = {"jvm", "jawt"}
                package:addenv("PATH", path.join(sdkdir, "bin"), path.join(sdkdir, "bin", "server"))
                return result
            end
        end
    end)

    on_install("windows|x64", "linux|x86_64", "macosx|x86_64", "macosx|arm64", "mingw|x86_64", function (package)
        local plat
        if package:is_plat("windows", "mingw") then
            plat = "win32"
            package:addenv("PATH", "bin/server")
        else
            package:add("linkdirs", "lib", "lib/server")
            if package:is_plat("linux") then
                plat = "linux"
            elseif package:is_plat("macosx") then
                plat = "darwin"
                os.cd("Contents/Home")
            end
        end

        os.cp("bin", package:installdir())
        os.cp("include", package:installdir())
        os.cp("lib", package:installdir())
        os.cp("jmods", package:installdir("lib"))
        os.cp("conf", package:installdir())

        package:add("includedirs", "include", path.join("include", plat))
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        os.vrun("java -version")
        assert(package:has_cfuncs("JNI_CreateJavaVM", {includes = "jni.h"}))
    end)
