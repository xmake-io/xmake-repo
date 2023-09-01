package("openjdk")
    set_homepage("https://jdk.java.net")
    set_description("Java Development Kit builds, from Oracle")
    set_license("GPL-2.0")

    if is_host("windows", "mingw") then
        add_urls("https://download.java.net/java/GA/jdk$(version)/6e380f22cbe7469fa75fb448bd903d8e/9/GPL/openjdk-$(version)_windows-x64_bin.zip")
        add_versions("20.0.2", "7e5870fd2e19b87cbd1981c4ff7203897384c2eb104977f40ce4951b40ab433e")
    elseif is_host("linux") then
        if is_arch("x86_64") then
            add_urls("https://download.java.net/java/GA/jdk$(version)/6e380f22cbe7469fa75fb448bd903d8e/9/GPL/openjdk-$(version)_linux-x64_bin.tar.gz.sha256")
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
            add_versions("20.0.2", "c65ba92b73d8076e2a10029a0674d40ce45c3e0183a8063dd51281e92c9f43fc")
        end
    end

    add_configs("shared", {description = "Download shared binaries.", default = true, type = "boolean", readonly = true})

    on_fetch(function (package, opt)
        if opt.system then
            local sdkdir = os.getenv("JAVA_HOME")
            if os.isdir(sdkdir) then
                local result =
                {
                    includedirs = {path.join(sdkdir, "include")},
                    linkdirs = path.join(sdkdir, "lib"),
                    links = {"jvm", "jawt"}
                }

                if package:is_plat("windows", "mingw") then
                    package:addenv("PATH", path.join(sdkdir, "bin"))
                    table.insert(result.includedirs, path.join(sdkdir, "include", "win32"))
                end
                return result
            end
        end
    end)

    on_install("windows|x64", "linux|x86_64", "linux|arm64", "macosx|x86_64", "macosx|arm64", "mingw|x86_64", function (package)
        os.cp("bin", package:installdir())
        os.cp("include", package:installdir())
        os.cp("lib", package:installdir())
        if package:is_plat("windows", "mingw") then
            package:addenv("PATH", "bin")
            package:add("includedirs", "include", "include/win32")
        end
    end)

    on_test(function (package)
        os.vrun("java --version")
        assert(package:has_cfuncs("JNI_CreateJavaVM", {includes = "jni.h"}))
    end)
