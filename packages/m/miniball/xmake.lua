package("miniball")
    set_kind("library", {headeronly = true})
    set_homepage("https://people.inf.ethz.ch/gaertner/subdir/software/miniball.html")
    set_description("For computing the smallest enclosing balls of points in arbitrary dimensions")
    set_license("GPL-3.0")

    add_urls("https://github.com/xmake-mirror/miniball/archive/refs/tags/$(version).tar.gz",
             "https://github.com/xmake-mirror/miniball.git")
    add_versions("v3.0", "8a7eedbae5619bc2b9ca9a249539008026f274886b0aeb3bb9796698b8763ba0")

    on_install(function (package)
        os.cp("Miniball.hpp", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            using Point = std::list<std::vector<double>>;
            using Coord = std::vector<double>;
            using MB = Miniball::Miniball<Miniball::CoordAccessor<Point::const_iterator, Coord::const_iterator>>;
            void test() {
                Point p{ { 0, 0 }, { 1, 0 }, { 0, 1 } };
                MB mb{ 2, p.begin(), p.end() };
            }
        ]]}, {configs = {languages = "c++11"}, includes = {"Miniball.hpp", "list", "vector"}}))
    end)
