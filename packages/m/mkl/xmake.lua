package("mkl")

    set_homepage("https://software.intel.com/content/www/us/en/develop/tools/oneapi/components/onemkl.html")
    set_description("Intel® oneAPI Math Kernel Library")

    on_fetch(function (package, opt)
        if opt.system then
            return find_package("mkl")
        end
    end)
