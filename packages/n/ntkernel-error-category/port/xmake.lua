if is_plat("windows", "mingw") then
    target("generate-table")
        set_kind("binary")
        set_languages("c++17")
        add_files("src/generate-table.cpp")
        add_defines("_UNICODE", "UNICODE")
end

target("ntkernel-error-category")
    set_kind("$(kind)")
    set_languages("c++17")
    add_headerfiles("include/(ntkernel-error-category/*.hpp)")
    add_includedirs("include")

    if not is_kind("headeronly") then
        add_files("src/ntkernel_category.cpp")
        if is_kind("static") then
            add_defines("NTKERNEL_ERROR_CATEGORY_STATIC", { public = true })
        end
    else
        add_defines("NTKERNEL_ERROR_CATEGORY_INLINE", { public = true })
        add_headerfiles("include/(ntkernel-error-category/detail/*.ipp)")
    end
