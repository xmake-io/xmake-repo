function get_links(package)
    local links = {
        "LLVMIRReader",
        "LLVMAsmParser",
        "LLVMExecutionEngine",
        "LLVMRuntimeDyld",
        "LLVMAsmPrinter",
        "LLVMDebugInfoDWARF",
        "LLVMGlobalISel",
        "LLVMSelectionDAG",
        "LLVMMCDisassembler",
        "LLVMPasses",
        "LLVMCodeGen",
        "LLVMipo",
        "LLVMBitWriter",
        "LLVMInstrumentation",
        "LLVMScalarOpts",
        "LLVMAggressiveInstCombine",
        "LLVMInstCombine",
        "LLVMVectorize",
        "LLVMTransformUtils",
        "LLVMTarget",
        "LLVMAnalysis",
        "LLVMProfileData",
        "LLVMObject",
        "LLVMBitReader",
        "LLVMCore",
        "LLVMRemarks",
        "LLVMBitstreamReader",
        "LLVMMCParser",
        "LLVMMC",
        "LLVMBinaryFormat",
        "LLVMDebugInfoCodeView",
        "LLVMSupport",
        "LLVMDemangle",
        "LLVMMIRParser",
        "LLVMCFGuard",
        "LLVMCFIVerify",
        "LLVMCoroutines",
        "LLVMCoverage",
        "LLVMDWARFLinker",
        "LLVMDWP",
        "LLVMDebugInfoGSYM",
        "LLVMDebugInfoMSF",
        "LLVMDebugInfoPDB",
        "LLVMDebuginfod",
        "LLVMDiff",
        "LLVMDlltoolDriver",
        "LLVMExegesis",
        "LLVMExtensions",
        "LLVMFileCheck",
        "LLVMFrontendOpenACC",
        "LLVMFrontendOpenMP",
        "LLVMFuzzMutate",
        "LLVMInterfaceStub",
        "LLVMInterpreter",
        "LLVMJITLink",
        "LLVMLTO",
        "LLVMLibDriver",
        "LLVMLineEditor",
        "LLVMLinker",
        "LLVMMCA",
        "LLVMMCJIT",
        "LLVMObjCARCOpts",
        "LLVMObjectYAML",
        "LLVMOption",
        "LLVMOrcJIT",
        "LLVMOrcShared",
        "LLVMOrcTargetProcess",
        "LLVMSymbolize",
        "LLVMTableGen",
        "LLVMTableGenGlobalISel",
        "LLVMTextAPI",
        "LLVMWindowsManifest",
        "LLVMXRay"
    }
    local links_arch
    if package:is_arch("x86_64", "i386", "x64", "x86") then
        links_arch = {
            "LLVMX86CodeGen",
            "LLVMX86Desc",
            "LLVMX86Info",
            "LLVMX86AsmParser",
            "LLVMX86Disassembler",
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
        links = table.join(links_arch, links)
    end
    return links
end

function main(package, component)
    component:add("links", get_links(package))
end


