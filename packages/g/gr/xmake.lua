package("gr")

    set_homepage("https://gr-framework.org/")
    set_description("GR framework: a graphics library for visualisation applications")
    set_license("MIT")

    if is_plat("windows") then
        if is_arch("x64") then
            add_urls("https://github.com/sciapp/gr/releases/download/v$(version)/gr-$(version)-Windows-x86_64-msvc.tar.gz")
            add_versions("0.57.0", "5e62a425e60885835fa8177ab5311c131bab0bb484722866ee931e81b77a6a5a")
            add_versions("0.58.0", "a8152c15613c8b8e02f57d2b19632576f133e353057d2d824e9b85c203c3aa90")
            add_versions("0.62.0", "749ea7757f967720c27990a55c26774d0683dacd81169b12033e4084e0483a85")
        end
    elseif is_plat("macosx") then
        if is_arch("arm64") then
            add_urls("https://github.com/sciapp/gr/releases/download/v$(version)/gr-$(version)-Darwin-aarch64.tar.gz")
            add_versions("0.57.0", "a867a9233a26f8797f13adf2b7d9324a397a84d256750db0a29f4b5032b9a47f")
            add_versions("0.58.0", "3c0132bc7c26665ed812381e103091273999352a3cda8d9e664759c143387755")
            add_versions("0.62.0", "9209f18b0affdaabc77e88fc027a8877a2c7c4e06c9fe44fec0da728c8882caf")
        else
            add_urls("https://github.com/sciapp/gr/releases/download/v$(version)/gr-$(version)-Darwin-x86_64.tar.gz")
            add_versions("0.57.0", "b6114420b6ffff1cc41c7a325b53fd2af90942c5d7840ff27b1217488b6fb950")
            add_versions("0.58.0", "1c808852fec10badea7a5282bc867c5bcc86eda89e07bce7b2f0017a889f16cf")
            add_versions("0.62.0", "e2a185691ef020bddbbb3c93046813335b04df7ca97df8b73032086aca266dce")
        end
    elseif is_plat("linux") then
        if is_arch("x86_64") then
            if linuxos.name() == "ubuntu" then
                add_urls("https://github.com/sciapp/gr/releases/download/v$(version)/gr-$(version)-Ubuntu-x86_64.tar.gz")
                add_versions("0.57.0", "5f157733b750be6e8e771e008bf2dab1ee786d50efcc16deb02f6cdda9d03a54")
                add_versions("0.58.0", "c72767b2880fd561508e526286b30c3fc9bfa78f432ac966eb6455d318c1374d")
                add_versions("0.62.0", "b539903b16bae5d6b3db01314c39c65819306e9aa8ded15ba52a5aeb7674e776")
            elseif linuxos.name() == "debian" then
                add_urls("https://github.com/sciapp/gr/releases/download/v$(version)/gr-$(version)-Debian-x86_64.tar.gz")
                add_versions("0.57.0", "f20e65b4b93df1409377355cefca0fda714f5b4f1bf0c2292c0bad4232ac0a41")
                add_versions("0.58.0", "5fc6fe7b58193fbfac9fc32538d1078dd9ab5a606d38e3fdb2a1683b37ec2a76")
                add_versions("0.62.0", "ebc6901b0a3888b7e874c761728fb503029128f0646a9bd0f93e67845467454d")
            elseif linuxos.name() == "archlinux" then
                add_urls("https://github.com/sciapp/gr/releases/download/v$(version)/gr-$(version)-ArchLinux-x86_64.tar.gz")
                add_versions("0.57.0", "3224971f16a8cc223f57ea240dea346747ea18111c91b64b38b5554f93721cf8")
                add_versions("0.58.0", "f90fb2b15459d0c3075326646c31a041a61c9b84b4d4ebe015b4283a43c2fe6e")
                add_versions("0.62.0", "d8c6c01de2e566fa064836ead23ce139030e7e08961f482ff55942b6fb298e4e")
            elseif linuxos.name() == "centos" then
                add_urls("https://github.com/sciapp/gr/releases/download/v$(version)/gr-$(version)-CentOS-x86_64.tar.gz")
                add_versions("0.57.0", "877d6066690c6dc071db1edb64e79d738fdde6d9a7d4562f33bb76d8b9324b1c")
                add_versions("0.58.0", "3d403550ae440d4aac607bd61a9c4140ee98390c48ed44594eebef55308466ed")
                add_versions("0.62.0", "c83cb8c6d05877c4b4a050879a82ca6482472b8ea5dea48e608ce61544c34924")
            else
                add_urls("https://github.com/sciapp/gr/releases/download/v$(version)/gr-$(version)-Linux-x86_64.tar.gz")
                add_versions("0.57.0", "793fef6a18f8faa7bc4fbb2067691bc355a9111b5c2ae5ea41f3552d6c7064d5")
                add_versions("0.58.0", "d7350611e7bd8a3ff1034b2d13fe4c10c65f99c85c994a32e6dd6da59cb7de3c")
                add_versions("0.62.0", "99da04bda9520e99181dd28a175de3689d699e0bbe09495d328b715d17f874a2")
            end
        elseif is_arch("x86") then
            add_urls("https://github.com/sciapp/gr/releases/download/v$(version)/gr-$(version)-Linux-i386.tar.gz")
            add_versions("0.57.0", "f6ec390e1f9b2a0a83d5b7da95ebfe615aedc84075475a28c363b671353c65c5")
            add_versions("0.58.0", "681dbd0fa7cea25e189d4f58e5a4b7cf002cea2b13a663df67598f95f6a548a6")
            add_versions("0.62.0", "2a5bc4959c7254b24d37ee31d5a2294ecdd956730e8ec8abd8d17dde3cc91a01")
        end
    end

    on_load("windows|x64", "macosx", "linux|x86,x86_64", function (package)
        local libs = {"GR", "GR3", "GRM", "GKS"}
        local prefix = ""
        if package:is_plat("windows") then
            prefix = "lib"
        else
            package:add("ldflags", "-Wl,-rpath," .. package:installdir("lib"))
        end
        for _, lib in ipairs(libs) do
            package:add("links", prefix .. lib)
        end
    end)

    on_install("windows|x64", "macosx", "linux|x86,x86_64", function (package)
        os.cp("*", package:installdir())
        package:addenv("PATH", ".")
        package:addenv("PATH", "bin")
        package:addenv("GRDIR", package:installdir())
        package:addenv("GKS_WSTYPE", package:is_plat("windows") and "41" or "x11")
    end)

    on_test(function (package)
        package:check_csnippets({test = [[
            void test() {
                double x[] = {0, 0.2, 0.4, 0.6, 0.8, 1.0};
                double y[] = {0.3, 0.5, 0.4, 0.2, 0.6, 0.7};
                gr_beginprint("test.png");
                gr_polyline(6, x, y);
                gr_axes(gr_tick(0, 1), gr_tick(0, 1), 0, 0, 1, 1, -0.01);
                gr_endprint();
            }
        ]]}, {includes = "gr.h"})
    end)
