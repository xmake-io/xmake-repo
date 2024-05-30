package("crashpad")
    set_homepage("https://chromium.googlesource.com/crashpad/crashpad/+/refs/heads/main/README.md")
    set_description("Crashpad is a crash-reporting system.")
    set_license("Apache-2.0")

    if is_host("linux") then
        add_deps("depot_tools")
        if linuxos.name() == "ubuntu" or linuxos.name() == "debian" then
            add_deps("apt::libcurl4-openssl-dev")
        end
        if linuxos.name() == "archlinux" or linuxos.name() == "manjaro" then
            add_deps("pacman::curl","pacman::clang")
        end
        if linuxos.name() == "fedora" then
            add_deps("dnf::libcurl-devel")
        end
    end
    
    if is_host("windows") then
        local map = {
            ["2021.8.1"] = "stable",
            ["2022.4.16"] = "latest"
        }

        function map_version(version)
            return map[tostring(version)]
        end

        if is_arch("x64", "x86_64") then
            set_urls("http://get.backtrace.io/crashpad/builds/crashpad-release-x86-64-$(version).zip", {
                version = map_version
            })
            add_versions("2021.8.1", "b3facf8a802dfd12daf4d9fba416f4d4b5df0ae544afa14080662fa978aa18cb")
            add_versions("2022.4.16", "7705073dfff89c376303cacea3a6f8c63322f77566ad5cdbe37060cf3cef9f8b")
        else
            set_urls("http://get.backtrace.io/crashpad/builds/crashpad-release-x86-$(version).zip", {
                version = map_version
            })
            add_versions("2021.8.1", "699fdf741f39da1c68069820ce891b6eb8b48ef29ab399fc1bcf210b67ff8547")
            add_versions("2022.4.16", "c3bffb64d1087198946739dfb30d24b2355e49ddfe90d8e2a75ed373ed6e3377")
        end
        add_includedirs("include", "include/mini_chromium")
    end

    on_install("windows", function(package)
        os.cp("include", package:installdir())
        os.cp("bin", package:installdir())
        if package:config("shared") then
            os.cp("lib_md/*", package:installdir("lib"))
        else
            os.cp("lib_mt/*", package:installdir("lib"))
        end
    end)

    on_install("linux", function(package)
        print("build start...")
        local installeddir = os.curdir()
        os.mkdir("tmp")
        os.cd("tmp")
        local currentdir = os.curdir()
        print("currentdir:" .. currentdir)
        if not os.exists("crashpad") then
            os.vrunv("fetch", {"crashpad"})
        end
        os.cd("crashpad")
        os.vrunv("gclient", {"sync"})
        os.vrunv("gn", {"gen", "out/Default"})
        os.vrunv("ninja", {"-C", "out/Default"})
        print("build end...")
        local mbindir = path.join(installeddir, "bin")
        local mlibdir = path.join(installeddir, "lib")
        local mincludedir = path.join(installeddir, "include")
        os.mkdir(mbindir)
        os.mkdir(mlibdir)
        os.mkdir(mincludedir)
        print("make inclide/*.h files")
        -- can not run whth os.vrunv,os.runv
        os.run("rsync -av --include='*.h' --include='*/' --exclude='*'  ./ ../../include/")
        -- os.runv("rsync",{"-av","--include='*.h'","--include='*/'","--exclude='*'","./","../../include/"})
        print("make lib/* files")
        os.cp("out/Default/obj/third_party/mini_chromium/mini_chromium/base/libbase.a", "../../lib/")
        os.cp("out/Default/obj/client/libcommon.a", "../../lib/")
        os.cp("out/Default/obj/client/libclient.a", "../../lib/")
        os.cp("out/Default/obj/util/libutil.a", "../../lib/")

        os.cp("out/Default/crashpad_handler", mbindir)
        os.cp("out/Default/crashpad_http_upload", mbindir)
        os.cp("out/Default/crashpad_database_util", mbindir)
        os.cp("out/Default/generate_dump", mbindir)
        os.cp("out/Default/dump_minidump_annotations", mbindir)
        os.cp("out/Default/base94_encoder", mbindir)

        os.cd(installeddir)
        -- os.rm("tmp")
        os.cp("include/*", package:installdir("include"))
        os.cp("lib/*", package:installdir("lib"))
        os.cp("bin/*", package:installdir("bin"))
        package:addenv("PATH", "bin")
    end)
    

    if is_host("linux") then
        add_includedirs("include", "include/third_party/mini_chromium/mini_chromium", "include/out/Default/gen")
        add_links("common", "client", "util", "base")
    end

    on_test(function(package)
        if package:is_plat("linux") or package:is_plat("windows") then
            os.runv("crashpad_handler --help")
            assert(package:check_cxxsnippets({
                test = [[
                            #include <stdio.h>
                            #include <unistd.h>
                            #include <string.h>
                            #include "client/crashpad_client.h"
                            #include "client/crash_report_database.h"
                            #include "client/settings.h"
                            using namespace crashpad;
                            void test() {
                                CrashpadClient *client = new CrashpadClient();
                            }
                        ]]
            }, {
                configs = {
                    languages = "cxx17"
                }
            }))
        end

    end)
