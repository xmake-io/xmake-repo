package("libc++")

    set_homepage("https://libcxx.llvm.org/")
    set_description("libc++ is a new implementation of the C++ standard library, targeting C++11 and above.")

    on_fetch(function (package, opt)
        if opt.system then
            return package:find_package("system::c++")
        end
    end)
