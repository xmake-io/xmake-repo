add_rules("mode.debug", "mode.release")

if is_subhost("windows") then
    add_requires("strawberry-perl")
    add_packages("strawberry-perl")
end

add_defines("WITHOUT_ICONV_FILTER")

target("parserutils")
    set_kind("$(kind)")
    add_files("src/**.c")
    add_includedirs("include", "src")
    add_headerfiles("include/(parserutils/**.h)")

    if is_plat("windows") and is_kind("shared") then
        add_rules("utils.symbols.export_all")
    end

    before_build(function (target)
        local perl
        if is_subhost("windows") then
            perl = path.join(target:pkg("strawberry-perl"):installdir(), "perl/bin/perl.exe")
        else
            perl = "perl"
        end
        os.vrunv(perl, {"build/make-aliases.pl"})
    end)
