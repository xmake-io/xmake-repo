target("prelude")
    set_kind("object")
    add_packages("unordered_dense")
    add_deps("slang-embed")
    set_languages("cxx17")
    set_warnings("none")

    add_files(
        "slang-cpp-host-prelude.h.cpp",
        "slang-cpp-prelude.h.cpp",
        "slang-cuda-prelude.h.cpp",
        "slang-hlsl-prelude.h.cpp",
        "slang-torch-prelude.h.cpp",
        { always_added = true }
    )
    add_includedirs("./", "$(projectdir)/include", { public = true })

    before_build(function ()
        for _, file_path in ipairs(os.files("$(scriptdir)/*-prelude.h")) do
            local file_name = path.filename(file_path)
            print("Generating prelude for " .. file_path)
            os.vrunv("$(buildir)/generators/slang-embed", {
                file_path, path.join(os.scriptdir(), file_name .. ".cpp")
            })
        end
    end)
target_end()

