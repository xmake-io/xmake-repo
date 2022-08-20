package("matlab")
    set_homepage("https://www.mathworks.com/help/matlab/ref/mex.html")
    set_description("Build MEX function or engine application in matlab")
    on_fetch(function (package)
    	import("detect.sdks.find_matlab")
    	local matlab = find_matlab()
    	if matlab then
            local result = {}
            if package:is_plat("mingw") then
                result.linkdirs = matlab.linkdirs.mingw64
                result.links = matlab.links.mingw64
                result.shflags = path.join(matlab.linkdirs.mingw64, "mexFunction.def")
                result.includedirs = matlab.includedirs
            elseif package:is_plat("windows") then
                result.linkdirs = matlab.linkdirs.microsoft
                result.links = matlab.links.microsoft
                result.shflags = "/EXPORT:mexFunction"
                result.includedirs = matlab.includedirs
            else
                wprint("Matlab MEX function do not support this platform[%s].", package:plat())
                return
            end
            return result
        else
            wprint("Can't find matlab.please check your machine.")
    	end
    end)