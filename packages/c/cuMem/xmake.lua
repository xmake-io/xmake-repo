package("cuMem")

set_homepage("https://github.com/BinhaoQin/cuMem")
set_description("CUDA Memory Management Wrapper with Type Safety")

set_urls("https://github.com/BinhaoQin/cuMem/archive/refs/tags/v$(version).tar.gz")

add_versions("1.0.0", "a3e707836a9fd4c1a8b3e57482b7f40ca123e44bbb1e1bda1ec29256b3e3400a")

on_install("windows", function(package)
	-- io.gsub("win32/Makefile.msc", "%-MD", "-" .. package:config("vs_runtime"))
	os.cp("include/*.h", package:installdir("include"))
end)

on_install("linux", "macosx", function(package)
	-- import("package.tools.autoconf").install(package, { "--static" })
	os.cp("include/*.h", package:installdir("include"))
end)

-- on_install("iphoneos", "android@linux,macosx", "mingw@linux,macosx", function(package)
-- 	import("package.tools.autoconf").configure(package, { host = "", "--static" })
-- 	io.gsub("Makefile", "\nAR=.-\n", "\nAR=" .. (package:build_getenv("ar") or "") .. "\n")
-- 	io.gsub("Makefile", "\nARFLAGS=.-\n", "\nARFLAGS=cr\n")
-- 	io.gsub("Makefile", "\nRANLIB=.-\n", "\nRANLIB=\n")
-- 	os.vrun("make install -j4")
-- end)

on_test(function(package)
	os.run("xmake run")
end)
