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
        import("lib.detect.find_tool")
        local py_include_dir = ""
        if is_plat("windows") then
            local python = assert(find_tool("python", {version = true}), "python not found, please install it first! note: python version must > 3.0")
            local pydir = os.iorun("python -c \"import sys; print(sys.executable)\"")
            py_include_dir = path.directory(pydir) .. "/include"
        else
            py_include_dir = try { function () return os.iorun("python3-config --includes"):trim() end }
        end
        local old_include_env = os.getenv("INCLUDE")
        if old_include_env == nil then 
            old_include_env = ""
        end
        local new_include_env = ""
        if is_plat("windows") then 
            new_include_env = old_include_env .. ";" .. py_include_dir
        else
            new_include_env = old_include_env .. ":" .. py_include_dir
        end 
        os.setenv("INCLUDE", new_include_env)
        assert(package:has_cxxfuncs("pybind11::globals()", {includes = "pybind11/pybind11.h", configs = {languages = "c++11"}}))
        os.setenv("INCLUDE", old_include_env)
    end)
