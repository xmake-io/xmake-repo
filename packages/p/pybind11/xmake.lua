package("pybind11")

    set_homepage("https://github.com/pybind/pybind11")
    set_description("Seamless operability between C++11 and Python.")

    set_urls("https://github.com/pybind/pybind11/archive/v$(version).zip",
             "https://github.com/pybind/pybind11.git")

    add_versions("2.5.0", "1859f121837f6c41b0c6223d617b85a63f2f72132bae3135a2aa290582d61520")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        if is_plat("windows") then
            local pydir = os.iorun("python -c \"import sys; print(sys.executable)\"")
            local py_include_dir = path.directory(pydir) .. "/include"
            assert(package:has_cxxfuncs("pybind11::globals()", {includes = "pybind11/pybind11.h", configs = {includedirs={py_include_dir, package:installdir().."/include"}, languages = "c++11"}}))
            return
        end

        py_include_dir = try { function () return os.iorun("python3-config --includes"):trim() end }
        local py_lib_dir = os.iorun("python3-config --prefix"):trim() .. "/lib"
        local out, err = os.iorun("python3 --version")
        local ver = (out .. err):trim()
        local pylib = format("python%s.%sm", string.sub(ver, 8, 8), string.sub(ver, 10, 10))
        assert(package:has_cxxfuncs("pybind11::globals()", {includes = "pybind11/pybind11.h", configs = {cxflags=py_include_dir, links = pylib, languages = "c++11"}}))
    end)
