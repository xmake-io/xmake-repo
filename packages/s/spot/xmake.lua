package("spot")

    set_homepage("https://spot.lrde.epita.fr/")
    set_description("Spot: a platform for LTL and ω-automata manipulation")
    set_license("GPL-3.0")

    add_urls("http://www.lrde.epita.fr/dload/spot/spot-2.10.1.tar.gz")
    add_versions("2.10.1", "38002989fc8e3725841a0537665bb2d5dfc259d2e09358100322c38f4c7481ad")

    on_install("macosx", "linux", function (package)
        local configs = {"--disable-python"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:config("pic") then
            table.insert(configs, "--with-pic")
        end
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
