package("libkdtree")
    set_kind("library", {
        headeronly = true
    })
    set_homepage("https://github.com/nvmd/libkdtree")
    set_description(
        "libkdtree++ is a C++ template container implementation of k-dimensional space sorting, using a kd-tree.")
    set_license("The Artistic Licence 2.0")
    
    add_urls("https://github.com/nvmd/libkdtree/archive/refs/tags/v$(version).zip", "https://github.com/nvmd/libkdtree.git")
    add_versions("0.7.1", "7bb7e830d6899214e9e896f920483ddb39c43f7b")
    
    on_install(function(package)
        os.cp("kdtree++/*.hpp", package:installdir("include"))
    end)
    
    on_test(function(package)
        assert(package:has_cxxtypes("KDTree::KDTree", {
            includes = "kdtree.hpp"
        }))
    end)
package_end()
