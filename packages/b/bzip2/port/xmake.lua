add_rules("mode.debug", "mode.release")

target("bz2")
    set_kind("$(kind)")
    set_languages("c89")
    if is_plat("windows", "mingw") and is_kind("static") then
        add_defines("BZ_STATIC", {public = true})
    end

    add_headerfiles("bzlib.h")
    add_files("blocksort.c")
    add_files("bzlib.c")
    add_files("compress.c")
    add_files("crctable.c")
    add_files("decompress.c")
    add_files("huffman.c")
    add_files("randtable.c")

target("bzip2")
    set_kind("binary")
    add_deps("bz2")
    add_files("bzip2.c")

    after_install(function (target)
        -- copy/link additional executables/scripts (behavior is altered by checking the program name)
        if target:is_plat("windows", "mingw") then
            local binarydir = path.join(target:installdir(), "bin")
            os.vcp(path.join(binarydir, "bzip2.exe"), path.join(binarydir, "bzcat.exe"))
            os.vcp(path.join(binarydir, "bzip2.exe"), path.join(binarydir, "bunzip2.exe"))
        else
            local binarydir = path.join(target:installdir(), "bin")
            os.ln(path.join(binarydir, "bzip2"), path.join(binarydir, "bzcat"))
            os.ln(path.join(binarydir, "bzip2"), path.join(binarydir, "bunzip2"))

            -- copy shell scripts
            os.vcp("bzdiff", binarydir)
            os.vcp("bzgrep", binarydir)
            os.vcp("bzmore", binarydir)

            -- and renamed copies
            os.ln(path.join(binarydir, "bzdiff"), path.join(binarydir, "bzcmp"))

            os.ln(path.join(binarydir, "bzgrep"), path.join(binarydir, "bzegrep"))
            os.ln(path.join(binarydir, "bzgrep"), path.join(binarydir, "bzfgrep"))

            os.ln(path.join(binarydir, "bzmore"), path.join(binarydir, "bzless"))
        end
    end)

target("bzip2recover")
    set_kind("binary")
    add_deps("bz2")
    add_files("bzip2recover.c")
