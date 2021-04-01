package("gr")

    set_homepage("https://gr-framework.org/")
    set_description("GR framework: a graphics library for visualisation applications")
    set_license("MIT")

    if is_plat("windows") then
        if is_arch("x64") then
            add_urls("https://github.com/sciapp/gr/releases/download/v$(version)/gr-$(version)-Windows-x86_64-msvc.tar.gz")
            add_versions("0.57.0", "5e62a425e60885835fa8177ab5311c131bab0bb484722866ee931e81b77a6a5a")
        end
    elseif is_plat("macosx") then
        if is_arch("arm64") then
            add_urls("https://github.com/sciapp/gr/releases/download/v$(version)/gr-$(version)-Darwin-aarch64.tar.gz")
            add_versions("0.57.0", "a867a9233a26f8797f13adf2b7d9324a397a84d256750db0a29f4b5032b9a47f")
        else
            add_urls("https://github.com/sciapp/gr/releases/download/v$(version)/gr-$(version)-Darwin-x86_64.tar.gz")
            add_versions("0.57.0", "b6114420b6ffff1cc41c7a325b53fd2af90942c5d7840ff27b1217488b6fb950")
        end
    elseif is_plat("linux") then
        if is_arch("x86_64") then
            if linuxos.name() == "ubuntu" then
                add_urls("https://github.com/sciapp/gr/releases/download/v$(version)/gr-$(version)-Ubuntu-x86_64.tar.gz")
                add_versions("0.57.0", "5f157733b750be6e8e771e008bf2dab1ee786d50efcc16deb02f6cdda9d03a54")
            elseif linuxos.name() == "debian" then
                add_urls("https://github.com/sciapp/gr/releases/download/v$(version)/gr-$(version)-Debian-x86_64.tar.gz")
                add_versions("0.57.0", "f20e65b4b93df1409377355cefca0fda714f5b4f1bf0c2292c0bad4232ac0a41")
            elseif linuxos.name() == "archlinux" then
                add_urls("https://github.com/sciapp/gr/releases/download/v$(version)/gr-$(version)-ArchLinux-x86_64.tar.gz")
                add_versions("0.57.0", "3224971f16a8cc223f57ea240dea346747ea18111c91b64b38b5554f93721cf8")
            elseif linuxos.name() == "centos" then
                add_urls("https://github.com/sciapp/gr/releases/download/v$(version)/gr-$(version)-CentOS-x86_64.tar.gz")
                add_versions("0.57.0", "877d6066690c6dc071db1edb64e79d738fdde6d9a7d4562f33bb76d8b9324b1c")
            else
                add_urls("https://github.com/sciapp/gr/releases/download/v$(version)/gr-$(version)-Linux-x86_64.tar.gz")
                add_versions("0.57.0", "793fef6a18f8faa7bc4fbb2067691bc355a9111b5c2ae5ea41f3552d6c7064d5")
            end
        elseif is_arch("x86") then
            add_urls("https://github.com/sciapp/gr/releases/download/v$(version)/gr-$(version)-Linux-i386.tar.gz")
            add_versions("0.57.0", "f6ec390e1f9b2a0a83d5b7da95ebfe615aedc84075475a28c363b671353c65c5")
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
        os.cp("**", package:installdir())
        package:addenv("PATH", "bin")
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
