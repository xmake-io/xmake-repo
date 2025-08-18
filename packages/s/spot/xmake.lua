package("spot")
    set_homepage("https://spot.lrde.epita.fr/")
    set_description("Spot: a platform for LTL and ω-automata manipulation")
    set_license("GPL-3.0")

    add_urls("https://www.lrde.epita.fr/dload/spot/spot-$(version).tar.gz")
    add_versions("2.13.2", "a412b3bbaef950215a2f71870ee24f01d722338b657cad9839f39acff1841011")
    add_versions("2.10.1", "38002989fc8e3725841a0537665bb2d5dfc259d2e09358100322c38f4c7481ad")

    if not is_subhost("windows") then
        add_deps("autotools")
    end

    if is_plat("linux") then
        add_syslinks("atomic")
    end

    if on_check then
        on_check("android", function (package)
            local ndk_sdkver = package:toolchain("ndk"):config("ndk_sdkver")
            assert(ndk_sdkver and tonumber(ndk_sdkver) > 22, "package(spot) require ndk version > 22")
        end)
    end
    on_install("linux", "macosx", "android@linux,macosx", "cross", "bsd", "mingw", "msys", function (package)
        io.replace("buddy/Makefile.am", [[SUBDIRS = src examples doc]], [[SUBDIRS = src]], {plain = true})
        local configs = {"--disable-python"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <spot/tl/parse.hh>
            void test() {
                spot::formula f = spot::parse_formula("& & G p0 p1 p2");
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
