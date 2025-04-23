function _patch_for_llvm_rc(package, opt)
    if package:is_plat("mingw") and package:has_tool("mrc", "llvm_rc", "llvm-rc", "rc") then
        local cc = package:build_getenv("cc")
        local cflags = opt.buildenvs.CFLAGS
        local tmpfile = path.unix(os.tmpfile() .. ".c")
        io.writefile(tmpfile, "int main(void) { return 0; }\n")
        local compile_out, compile_err = try {function() return os.iorun(format("%s -v %s %s", cc, cflags, tmpfile)) end}
        os.tryrm(tmpfile)
        local include_dirs = {}
        local in_include_section = false
        for _, verbose_command in ipairs({compile_out, compile_err}) do
            if verbose_command then
                for line in verbose_command:gmatch("[^\r\n]+") do
                    if line:find("#include.*search") then
                        in_include_section = true
                    elseif line:find("End.*search") then
                        in_include_section = false
                    elseif in_include_section and not line:find("#include.*search") then
                        table.insert(include_dirs, line:match("^%s*(.-)%s*$"))
                    end
                end
            end
        end
        local include_directive = ""
        for _, include_dir in ipairs(include_dirs) do
            include_directive = include_directive .. format([[ -I "%s"]], include_dir)
        end
        -- $(RC)  $(RCFLAGS)  -o $@ libcrypto.rc =>  $(RC) -I inc_dir -I inc_dir -FO $@ libcrypto.rc
        io.gsub("Makefile", [[%$%(RC%).-%$@%s+(%S+)]], format("$(RC) %s -FO $@ ", include_directive).."%1")
        io.gsub("Makefile", "(%S+).res.o", "%1.res")
    end
end

function main(package, opt)
    try {function() return _patch_for_llvm_rc(package, opt) end}
end
