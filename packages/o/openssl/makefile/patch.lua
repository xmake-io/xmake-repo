function main(package, opt)
    if not package:is_plat("windows") and not opt.perl.use_unix_path then
        local apps_openssl = io:readfile("Makefile"):match("APPS_OPENSSL=([^\r\n]*)")
        io.gsub("Makefile", "\\([^%s\"\\])", "/%1")
        io.replace("Makefile", "APPS_OPENSSL=([^\r\n]*)", "APPS_OPENSSL=" .. apps_openssl)
        io.replace("Makefile", "$(APPS_OPENSSL)", [["$(APPS_OPENSSL)"]], {plain = true})
    end

    if package:is_plat("windows") then
        io.replace("makefile", "PERL=([^\r\n]*)", "PERL=" .. opt.perl.program)
    else 
        io.replace("Makefile", "PERL=([^\r\n]*)", ([[PERL="%s"]]):format(opt.perl.program))
    end
end
