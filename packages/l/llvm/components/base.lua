function get_links(package)
    local links = {
        "LLVMAggressiveInstCombine",
        "LLVMAnalysis",
        "LLVMAsmParser",
        "LLVMAsmPrinter",
        "LLVMBinaryFormat",
        "LLVMBitReader",
        "LLVMBitWriter",
        "LLVMBitstreamReader",
        "LLVMCFGuard",
        "LLVMCFIVerify",
        "LLVMCodeGen",
        "LLVMCore",
        "LLVMCoroutines",
        "LLVMCoverage",
        "LLVMDWARFLinker",
        "LLVMDWP",
        "LLVMDebugInfoCodeView",
        "LLVMDebugInfoDWARF",
        "LLVMDebugInfoGSYM",
        "LLVMDebugInfoMSF",
        "LLVMDebugInfoPDB",
        "LLVMDebuginfod",
        "LLVMDemangle",
        "LLVMDiff",
        "LLVMDlltoolDriver",
        "LLVMExecutionEngine",
        "LLVMExegesis",
        "LLVMExtensions",
        "LLVMFileCheck",
        "LLVMFrontendOpenACC",
        "LLVMFrontendOpenMP",
        "LLVMFuzzMutate",
        "LLVMGlobalISel",
        "LLVMIRReader",
        "LLVMInstCombine",
        "LLVMInstrumentation",
        "LLVMInterfaceStub",
        "LLVMInterpreter",
        "LLVMJITLink",
        "LLVMLTO",
        "LLVMLibDriver",
        "LLVMLineEditor",
        "LLVMLinker",
        "LLVMMC",
        "LLVMMCA",
        "LLVMMCDisassembler",
        "LLVMMCJIT",
        "LLVMMCParser",
        "LLVMMIRParser",
        "LLVMObjCARCOpts",
        "LLVMObject",
        "LLVMObjectYAML",
        "LLVMOption",
        "LLVMOrcJIT",
        "LLVMOrcShared",
        "LLVMOrcTargetProcess",
        "LLVMPasses",
        "LLVMProfileData",
        "LLVMRemarks",
        "LLVMRuntimeDyld",
        "LLVMScalarOpts",
        "LLVMSelectionDAG",
        "LLVMSupport",
        "LLVMSymbolize",
        "LLVMTableGen",
        "LLVMTableGenGlobalISel",
        "LLVMTarget",
        "LLVMTextAPI",
        "LLVMTransformUtils",
        "LLVMVectorize",
        "LLVMWindowsManifest",
        "LLVMXRay",
        "LLVMipo"
    }
    local links_arch
    if package:is_arch("x86_64", "i386", "x64", "x86") then
        links_arch = {
            "LLVMX86AsmParser",
            "LLVMX86CodeGen",
            "LLVMX86Desc",
            "LLVMX86Disassembler",
            "LLVMX86Info",
            "LLVMX86TargetMCA",
            "LLVMExegesisX86"}
    elseif package:is_arch("arm64") then
        links_arch = {
            "LLVMAArch64AsmParser",
            "LLVMAArch64CodeGen",
            "LLVMAArch64Desc",
            "LLVMAArch64Disassembler",
            "LLVMAArch64Info",
            "LLVMAArch64Utils",
            "LLVMExegesisAArch64"}
    elseif package:is_arch("armv7") then
        links_arch = {
            "LLVMARMAsmParser",
            "LLVMARMCodeGen",
            "LLVMARMDesc",
            "LLVMARMDisassembler",
            "LLVMARMInfo",
            "LLVMARMUtils"}
    elseif package:is_arch("mips", "mips64") then
        links_arch = {
            "LLVMMipsAsmParser",
            "LLVMMipsCodeGen",
            "LLVMMipsDesc",
            "LLVMMipsDisassembler",
            "LLVMMipsInfo",
            "LLVMExegesisMips"}
    elseif package:is_arch("wasm32") then
        links_arch = {
            "LLVMWebAssemblyAsmParser",
            "LLVMWebAssemblyCodeGen",
            "LLVMWebAssemblyDesc",
            "LLVMWebAssemblyDisassembler",
            "LLVMWebAssemblyInfo",
            "LLVMWebAssemblyUtils"}
    elseif package:is_arch("riscv32") then
        links_arch = {
            "LLVMRISCVAsmParser",
            "LLVMRISCVCodeGen",
            "LLVMRISCVDesc",
            "LLVMRISCVDisassembler",
            "LLVMRISCVInfo"}
    end
    if links_arch then
        table.join2(links, links_arch)
    end
    return links
end

function main(package, component)
    component:add("links", get_links(package))
end


