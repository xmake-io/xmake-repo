set_project("SuiteSparse")
set_xmakever("2.5.6")
set_languages("cxx14")

add_rules("mode.debug", "mode.release")

-- initialize options
option("with_cuda",        {default = false, showmenu = true, description = "Build with CUDA support."})
option("with_blas",        {default = "mkl", showmenu = true, description = "Choose BLAS vendor.", values={"mkl", "openblas"}})
option("complex",          {default = false, showmenu = true, description = "Build with complex number support."})
option("graphblas",        {default = false, showmenu = true, description = "Build GraphBLAS module."})
option("graphblas_static", {default = false, showmenu = true, description = "Build static GraphBLAS module."})

-- set dependencies
add_requires("metis")
add_requires(get_config("with_blas"))
if has_config("with_cuda") then
    add_requires("cuda", {system = true, configs = {utils = {"cublas"}}})
    add_defines("GPU_BLAS")
end
if not has_config("complex") then
    add_defines("NCOMPLEX")
end

-- export config files for cmake
add_rules("utils.install.cmake_importfiles")

-- export symbols for windows
if is_plat("windows") and is_kind("shared") then
    add_rules("utils.symbols.export_all")
end

-- rule for compiling source files with multiple definitions
rule("c.def_gen")
    set_extensions(".c")
    on_buildcmd_file(function (target, batchcmds, sourcefile, opt)
        local prod_defs = {"none"}

        -- get defines from sourcefile
        local fileconfig = target:fileconfig(sourcefile)
        if fileconfig then
            prod_defs = fileconfig.prod_defs
        end

        local objectfile
        for _, res in ipairs(prod_defs) do
            local rootdir = path.join(target:autogendir(), "rules", "def_gen")
            local filename = table.concat(table.join({path.basename(sourcefile)}, res), "_") .. ".c"
            local sourcefile_cx = target:autogenfile(sourcefile, {rootdir = rootdir, filename = filename})

            -- add objectfile
            objectfile = target:objectfile(sourcefile_cx)
            table.insert(target:objectfiles(), objectfile)

            -- add commands
            if res ~= "none" then
                batchcmds:show_progress(opt.progress, "${color.build.object}compiling.%s %s with define %s", get_config("mode"), sourcefile, res)
                batchcmds:compile(sourcefile, objectfile, {configs = {defines = res}})
            else
                batchcmds:show_progress(opt.progress, "${color.build.object}compiling.%s %s with no defines", get_config("mode"), sourcefile)
                batchcmds:compile(sourcefile, objectfile)
            end
        end

        -- add deps
        batchcmds:add_depfiles(sourcefile)
        batchcmds:set_depmtime(os.mtime(objectfile))
        batchcmds:set_depcache(target:dependfile(objectfile))
    end)
rule_end()

add_rules("c.def_gen", {override = true})

target("suitesparseconfig")
    set_kind("$(kind)")
    add_files("SuiteSparse_config/SuiteSparse_config.c")
    add_headerfiles("SuiteSparse_config/SuiteSparse_config.h")
    add_includedirs("SuiteSparse_config", {public = true})
target_end()

for _, libname in ipairs({"AMD", "BTF", "CAMD", "CCOLAMD", "COLAMD"}) do
target(libname)
    set_kind("$(kind)")
    add_deps("suitesparseconfig")
    add_files(libname .. "/Source/*.c", {prod_defs = {"none", "DLONG"}})
    add_includedirs(libname .. "/Include", {public = true})
    add_headerfiles(libname .. "/Include/*.h")
target_end()
end

target("CHOLMOD")
    set_kind("$(kind)")
    add_deps("suitesparseconfig")
    add_deps("AMD", "CAMD", "COLAMD", "CCOLAMD")
    for _, module in ipairs({"Core", "Check", "Cholesky", "MatrixOps", "Partition", "Modify", "Supernodal"}) do
        add_files("CHOLMOD/" .. module .. "/cholmod*.c", {prod_defs = {"none", "DLONG"}})
    end
    add_includedirs("CHOLMOD/Include", {public = true})
    add_headerfiles("CHOLMOD/Include/*.h")
    add_packages("metis")
    add_packages(get_config("with_blas"))
    if has_config("with_cuda") then
        add_files("CHOLMOD/GPU/cholmod*.cu")
        add_files("CHOLMOD/GPU/cholmod*.c", {prod_defs = {"none", "DLONG"}})
        add_packages("cuda", {public = true})
    end
target_end()

target("CXSparse")
    set_kind("$(kind)")
    add_deps("suitesparseconfig")
    add_files("CXSparse/Source/*.c|cs_convert.c", {prod_defs = {"none", "CS_LONG"}})
    add_includedirs("CXSparse/Include", {public = true})
    add_headerfiles("CXSparse/Include/*.h")
target_end()

target("KLU")
    set_kind("$(kind)")
    add_deps("suitesparseconfig")
    add_deps("AMD", "COLAMD", "BTF")
    add_files("KLU/Source/*.c", {prod_defs = {"none", "DLONG"}})
    add_includedirs("KLU/Include", {public = true})
    add_headerfiles("KLU/Include/*.h")
target_end()

target("LDL")
    set_kind("$(kind)")
    add_deps("suitesparseconfig")
    add_files("LDL/Source/*.c", {prod_defs = {"none", "LDL_LONG"}})
    add_includedirs("LDL/Include", {public = true})
    add_headerfiles("LDL/Include/*.h")
target_end()

target("UMFPACK")
    set_kind("$(kind)")
    add_deps("suitesparseconfig")
    add_deps("AMD", "CHOLMOD")
    add_files("UMFPACK/Source/umfpack_timer.c", "UMFPACK/Source/umfpack_tictoc.c")
    local doubledefs = {"umf_analyze.c", "umf_apply_order.c", "umf_cholmod.c", "umf_colamd.c", "umf_free.c", "umf_fsize.c", "umf_is_permutation.c", "umf_malloc.c", "umf_realloc.c", "umf_report_perm.c", "umf_singletons.c"}
    for _, file in ipairs(doubledefs) do
        add_files("UMFPACK/Source/" .. file, {prod_defs = {"DINT", "DLONG"}})
    end
    add_files("UMFPACK/Source/*.c|umfpack_timer.c|umfpack_tictoc.c|" .. table.concat(doubledefs, "|"), {prod_defs = {"DINT", "DLONG", "ZINT", "ZLONG"}})
    add_includedirs("UMFPACK/Include", {public = true})
    add_headerfiles("UMFPACK/Include/*.h")
    add_packages(get_config("with_blas"), "metis")
target_end()

target("SPQR")
    set_kind("$(kind)")
    add_deps("suitesparseconfig")
    add_deps("CHOLMOD")
    add_files("SPQR/Source/*.cpp")
    add_includedirs("SPQR/Include", {public = true})
    add_headerfiles("SPQR/Include/*.h", "SPQR/Include/*.hpp")
    add_packages(get_config("with_blas"), "metis")
    if has_config("with_cuda") then
        add_deps("GPUQREngine")
        add_packages("cuda")
        add_files("SPQR/SPQRGPU/*.cpp")
    end
target_end()

if has_config("graphblas") then
if has_config("graphblas_static") then
target("GraphBLAS")
    set_kind("static")
    add_files("GraphBLAS/Source/*.c", "GraphBLAS/Source/Generated/*.c")
    add_includedirs("GraphBLAS/Include", "GraphBLAS/Source", "GraphBLAS/Source/Template", "GraphBLAS/Source/Generated")
    add_headerfiles("GraphBLAS/Include/*.h")
target_end()
else
target("GraphBLAS")
    set_kind("shared")
    add_files("GraphBLAS/Source/*.c", "GraphBLAS/Source/Generated/*.c")
    add_includedirs("GraphBLAS/Include", "GraphBLAS/Source", "GraphBLAS/Source/Template", "GraphBLAS/Source/Generated")
    add_headerfiles("GraphBLAS/Include/*.h")
target_end()
end
end

if has_config("with_cuda") then
target("SuiteSparse_GPURuntime")
    set_kind("$(kind)")
    add_deps("suitesparseconfig")
    add_packages("cuda")
    add_files("SuiteSparse_GPURuntime/Source/*.cpp")
    add_includedirs("SuiteSparse_GPURuntime/Include", {public = true})
    add_headerfiles("SuiteSparse_GPURuntime/Include/*.hpp")
target_end()

target("GPUQREngine")
    set_kind("$(kind)")
    add_deps("suitesparseconfig", "SuiteSparse_GPURuntime")
    add_files("GPUQREngine/Source/**.cpp", "GPUQREngine/Source/*.cu")
    add_includedirs("GPUQREngine/Include", {public = true})
    add_headerfiles("GPUQREngine/Include/(**.hpp)", "GPUQREngine/Include/(**.cu)")
target_end()
end
