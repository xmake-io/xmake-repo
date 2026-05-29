
rule("php.ext")
    on_config(function (target)
        local php_pkg = target:pkg("php")
        assert(php_pkg, "php package not found! make sure add_packages('php') is set")

        local pkg_dir = php_pkg:installdir()
        assert(pkg_dir and os.isdir(pkg_dir), "php package install dir not found: " .. tostring(pkg_dir))

        local php_incdir = path.join(pkg_dir, "include", "php")
        assert(os.isfile(path.join(php_incdir, "main", "php.h")),
            "php.h not found in package: " .. path.join(php_incdir, "main", "php.h"))

        -- 添加头文件路径
        target:add("includedirs", php_incdir)
        for _, sub in ipairs({"main", "TSRM", "Zend"}) do
            target:add("includedirs", path.join(php_incdir, sub))
        end

        -- 编译定义
        target:add("defines", "COMPILE_DL_" .. target:name():upper())
        target:add("defines", "ZEND_ENABLE_STATIC_TSRMLS_CACHE=1")

        if target:is_plat("windows") then
            target:add("defines", "ZEND_WIN32", "PHP_WIN32", "ZEND_DLL", "PHP_DLL")
            target:add("cxflags", "/wd4996")
        else
            target:add("cflags", "-fPIC")
        end
    end)
