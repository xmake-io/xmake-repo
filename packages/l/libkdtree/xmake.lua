package("libkdtree")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/nvmd/libkdtree")
    set_description("libkdtree++ is an STL-like C++ template container implementation of k-dimensional space sorting, using a kd-tree. It sports a theoretically unlimited number of dimensions, and can store any data structure")

    add_urls("https://github.com/nvmd/libkdtree/archive/refs/tags/$(version).tar.gz",
             "https://github.com/nvmd/libkdtree.git")

    add_versions("0.7.4", "4fd726a8e8a3d759aa2c2f4ec98e6874417ed781a255f94528366506fc87a02b")

    on_install(function (package)
        os.cp("kdtree++", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            #include <functional>
            #include <kdtree++/kdtree.hpp>
            struct duplet 
            {
                inline int operator[](int const N) const { return d[N]; }
                inline bool operator==(duplet const& other) const {
                    return this->d[0] == other.d[0] && this->d[1] == other.d[1];
                }
                inline bool operator!=(duplet const& other) const {
                    return this->d[0] != other.d[0] || this->d[1] != other.d[1];
                }
                friend std::ostream& operator<<(std::ostream& o, duplet const& d) {
                    return o << "(" << d[0] << "," << d[1] << ")";
                }
                int d[2];
            };
            typedef KDTree::KDTree<2, duplet, std::function<double(duplet, int)>> duplet_tree_type;
            inline double return_dup(duplet d, int k) { return d[k]; }
            void test() {
                duplet_tree_type dupl_tree_test(std::ref(return_dup));
                dupl_tree_test.optimise();
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
