package("openjdk")
    set_homepage("https://jdk.java.net")
    set_description("Java Development Kit builds, from Oracle")
    set_license("GPL-2.0")

    if is_host("windows", "mingw") then
        add_urls("https://download.oracle.com/java/$(version)/latest/jdk-$(version)_windows-x64_bin.zip")
        add_versions("17", "c98d85c8417703b0f72ddc5757ed66f3478ea7107b0e6d2a98cadbc73a45d77b")
        add_versions("21", "776afe55020560f175d8099710d8ac07c4d40772c694385c3dd765117cbd0ac3")
    elseif is_host("linux") then
        if is_arch("x86_64") then
            add_urls("https://download.oracle.com/java/$(version)/latest/jdk-$(version)_linux-x64_bin.tar.gz")
            add_versions("17", "e4fb2df9a32a876afb0a6e17f54c594c2780e18badfa2e8fc99bc2656b0a57b1")
            add_versions("21", "9f1f4a7f25ef6a73255657c40a6d7714f2d269cf15fb2ff1dc9c0c8b56623a6f")
        elseif is_arch("arm64") then
            add_urls("https://download.oracle.com/java/$(version)/latest/jdk-$(version)_linux-aarch64_bin.tar.gz")
            add_versions("17", "745e7a387e059ddc2481ccd209d691ca926fc0f35d523051822f24b296d17df7")
            add_versions("21", "14504bcdea0d8bc3fe9f065924e9e2dc631317b023a722565c8239075f39062d")
        end
    elseif is_host("macosx") then
        if is_arch("x86_64") then
            add_urls("https://download.oracle.com/java/$(version)/latest/jdk-$(version)_macos-x64_bin.tar.gz")
            add_versions("17", "7b68b833f392aa543ba538f94c60fd477581fef96a9c1ae059fa4158e9ce75ff")
            add_versions("21", "197a923b1f7ea2b224fafdfb9c3ef5fc8eb197d9817d7631d96da02b619f5975")
        elseif is_arch("arm64") then
            add_urls("https://download.oracle.com/java/$(version)/latest/jdk-$(version)_macos-aarch64_bin.tar.gz")
            add_versions("17", "d5bec93922815e9337040678ddf3f40e50b63c2b588cf63574fa1f2010206042")
            add_versions("21", "4b94951f03efe44cb6656e43f1098db3ce254a00412f9d22dff18a8328a7efdd")
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
