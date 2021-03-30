package("nvtx")

    set_homepage("https://github.com/NVIDIA/NVTX/")
    set_description("The NVIDIA® Tools Extension SDK (NVTX) is a C-based Application Programming Interface (API) for annotating events, code ranges, and resources in your applications.")

    add_deps("cuda")
    on_fetch(function (package, opt)
        if opt.system then
            return find_package("nvtx")
        end
    end)
