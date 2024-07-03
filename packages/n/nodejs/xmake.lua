package("nodejs")

    set_homepage("https://nodejs.org/")
    set_description("Cross-platform JavaScript runtime environment.")

    on_fetch("linux", function (package, opt)
        if opt.system then
            import("lib.detect.find_path")

            local headers_path = find_path("node.h", { "/usr/**", "/usr/local/**"})
            if headers_path then
                return {includedirs = {headers_path}}
            end
        end
    end)
