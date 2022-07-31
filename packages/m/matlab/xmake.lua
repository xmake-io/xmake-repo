package("matlab")
    set_homepage("https://www.mathworks.com/help/matlab/ref/mex.html")
    set_description("Build MEX function or engine application in matlab")
    
    on_fetch(function (package)
    	import("detect.sdks.find_matlab")
    	import("core.project.config")
    	local matlab = find_matlab()
    	local result = {}

    	if matlab.Matlab_FOUND ~= true then
    		-- just return,if not find
            return result
    	end

    	result.includedirs = matlab.Matlab_INCLUDE_DIRS
        if config.get("vs") then
            result.linkdirs = matlab.MATLAB_LIB_DIRS.microsoft
            result.links = matlab.Matlab_LIBRARIES.microsoft
            result.shflags = "/EXPORT:mexFunction"
        else
            result.linkdirs = matlab.MATLAB_LIB_DIRS.mingw64
            result.links = matlab.Matlab_LIBRARIES.mingw64
            result.shflags = matlab.MATLAB_LIB_DIRS.mingw64 .. "\\mexFunction.def"
        end
        return result
    end)