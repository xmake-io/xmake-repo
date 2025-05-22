--- from llvm/CMakeLists.txt

function get_llvm_all_projects()
    -- @see https://llvm.org/docs/CMake.html
    -- Some projects listed here can also go in LLVM_ENABLE_RUNTIMES. They should
    -- only appear in one of the two lists. If a project is a valid possiblity for
    -- both, prefer putting it in LLVM_ENABLE_RUNTIMES.
    return {
        "bolt",
        "clang",
        "clang-tools-extra",    -- But we do not build clang tools.
        "libclc",
        "lld",
        "lldb",
        "mlir",                 -- TODO: incompleted.
        "polly"
    }
end

function get_llvm_extra_projects()
    return {
        "flang"
    }
end

function get_llvm_known_projects()
    return table.join(get_llvm_all_projects(), get_llvm_extra_projects())
end

function get_llvm_all_runtimes()
    return {
        "libc",
        "libunwind",
        "libcxxabi",
        "pstl",
        "libcxx",
        "compiler-rt",
        "openmp",
        "llvm-libgcc",
        "offload",
        "flang-rt"
    }
end

--- from cmake/llvm/LLVMExports.cmake

function get_llvm_shared_libraries()
    return {
        "LLVM",
        "Remarks",
        "LTO"
    }
end

function get_llvm_static_libraries()
    return {
        "LLVMExegesisMips",
        "LLVMExegesisPowerPC",
        "LLVMExegesisAArch64",
        "LLVMExegesisX86",
        "LLVMOptDriver",
        "LLVMExegesis",
        "LLVMOrcDebugging",
        "LLVMBPFCodeGen",
        "LLVMAMDGPUCodeGen",
        "LLVMOrcJIT",
        "LLVMLTO",
        "LLVMPasses",
        "LLVMX86CodeGen",
        "LLVMRISCVCodeGen",
        "LLVMPowerPCCodeGen",
        "LLVMMipsCodeGen",
        "LLVMARMCodeGen",
        "LLVMAArch64CodeGen",
        "LLVMNVPTXCodeGen",
        "LLVMHexagonCodeGen",
        "LLVMCoroutines",
        "LLVMWebAssemblyCodeGen",
        "LLVMDWARFLinkerParallel",
        "LLVMDWARFLinkerClassic",
        "LLVMXCoreCodeGen",
        "LLVMVECodeGen",
        "LLVMSystemZCodeGen",
        "LLVMSparcCodeGen",
        "LLVMMSP430CodeGen",
        "LLVMLoongArchCodeGen",
        "LLVMLanaiCodeGen",
        "LLVMAVRCodeGen",
        "LLVMGlobalISel",
        "LLVMipo",
        "LLVMWebAssemblyUtils",
        "LLVMInterpreter",
        "LLVMDWARFLinker",
        "LLVMMIRParser",
        "LLVMAsmPrinter",
        "LLVMSelectionDAG",
        "LLVMFrontendOpenMP",
        "LLVMCodeGen",
        "LLVMFuzzMutate",
        "LLVMAMDGPUTargetMCA",
        "LLVMAMDGPUDisassembler",
        "LLVMAMDGPUAsmParser",
        "LLVMMCJIT",
        "LLVMScalarOpts",
        "LLVMAMDGPUDesc",
        "LLVMExecutionEngine",
        "LLVMLinker",
        "LLVMHipStdPar",
        "LLVMObjCARCOpts",
        "LLVMVectorize",
        "LLVMInstCombine",
        "LLVMAggressiveInstCombine",
        "LLVMInstrumentation",
        "LLVMFrontendOffloading",
        "LLVMAMDGPUUtils",
        "LLVMTarget",
        "LLVMTransformUtils",
        "LLVMFrontendDriver",
        "LLVMBitWriter",
        "LLVMIRPrinter",
        "LLVMCoverage",
        "LLVMAnalysis",
        "LLVMCFIVerify",
        "LLVMProfileData",
        "LLVMDebuginfod",
        "LLVMARMDisassembler",
        "LLVMARMAsmParser",
        "LLVMSymbolize",
        "LLVMDebugInfoLogicalView",
        "LLVMTextAPIBinaryReader",
        "LLVMDWP",
        "LLVMDebugInfoGSYM",
        "LLVMXRay",
        "LLVMLibDriver",
        "LLVMDlltoolDriver",
        "LLVMARMDesc",
        "LLVMRuntimeDyld",
        "LLVMJITLink",
        "LLVMDebugInfoPDB",
        "LLVMDebugInfoDWARF",
        "LLVMObjectYAML",
        "LLVMObjCopy",
        "LLVMCodeGenData",
        "LLVMInterfaceStub",
        "LLVMX86TargetMCA",
        "LLVMX86AsmParser",
        "LLVMWebAssemblyDisassembler",
        "LLVMWebAssemblyAsmParser",
        "LLVMVEAsmParser",
        "LLVMSystemZDisassembler",
        "LLVMSystemZAsmParser",
        "LLVMSparcAsmParser",
        "LLVMRISCVTargetMCA",
        "LLVMRISCVDisassembler",
        "LLVMRISCVAsmParser",
        "LLVMPowerPCAsmParser",
        "LLVMMSP430AsmParser",
        "LLVMMipsAsmParser",
        "LLVMLoongArchDisassembler",
        "LLVMLoongArchAsmParser",
        "LLVMLanaiDisassembler",
        "LLVMLanaiAsmParser",
        "LLVMHexagonDisassembler",
        "LLVMHexagonAsmParser",
        "LLVMBPFAsmParser",
        "LLVMAVRAsmParser",
        "LLVMAArch64Disassembler",
        "LLVMAArch64AsmParser",
        "LLVMObject",
        "LLVMXCoreDesc",
        "LLVMXCoreDisassembler",
        "LLVMX86Desc",
        "LLVMX86Disassembler",
        "LLVMWebAssemblyDesc",
        "LLVMVEDesc",
        "LLVMVEDisassembler",
        "LLVMSystemZDesc",
        "LLVMSparcDesc",
        "LLVMSparcDisassembler",
        "LLVMRISCVDesc",
        "LLVMPowerPCDesc",
        "LLVMPowerPCDisassembler",
        "LLVMNVPTXDesc",
        "LLVMMSP430Disassembler",
        "LLVMMSP430Desc",
        "LLVMMipsDesc",
        "LLVMMipsDisassembler",
        "LLVMLoongArchDesc",
        "LLVMLanaiDesc",
        "LLVMHexagonDesc",
        "LLVMBPFDesc",
        "LLVMBPFDisassembler",
        "LLVMAVRDesc",
        "LLVMAVRDisassembler",
        "LLVMAArch64Desc",
        "LLVMIRReader",
        "LLVMXCoreInfo",
        "LLVMX86Info",
        "LLVMWebAssemblyInfo",
        "LLVMVEInfo",
        "LLVMSystemZInfo",
        "LLVMSparcInfo",
        "LLVMRISCVInfo",
        "LLVMPowerPCInfo",
        "LLVMNVPTXInfo",
        "LLVMMSP430Info",
        "LLVMMipsInfo",
        "LLVMLoongArchInfo",
        "LLVMLanaiInfo",
        "LLVMHexagonInfo",
        "LLVMBPFInfo",
        "LLVMAVRInfo",
        "LLVMARMInfo",
        "LLVMAMDGPUInfo",
        "LLVMAArch64Info",
        "LLVMMCA",
        "LLVMMCDisassembler",
        "LLVMMCParser",
        "LLVMDiff",
        "LLVMAsmParser",
        "LLVMSandboxIR",
        "LLVMAArch64Utils",
        "LLVMCFGuard",
        "LLVMFrontendHLSL",
        "LLVMBitReader",
        "LLVMTextAPI",
        "LLVMMC",
        "LLVMCore",
        "LLVMTableGenCommon",
        "LLVMWindowsDriver",
        "LLVMOrcTargetProcess",
        "LLVMBinaryFormat",
        "LLVMFuzzerCLI",
        "LLVMRemarks",
        "LLVMTableGenBasic",
        "LLVMWindowsManifest",
        "LLVMTargetParser",
        "LLVMLineEditor",
        "LLVMARMUtils",
        "LLVMOrcShared",
        "LLVMDebugInfoBTF",
        "LLVMDebugInfoCodeView",
        "LLVMDebugInfoMSF",
        "LLVMOption",
        "LLVMFrontendOpenACC",
        "LLVMExtensions",
        "LLVMBitstreamReader",
        "LLVMCodeGenTypes",
        "LLVMFileCheck",
        "LLVMTableGen",
        "LLVMSupport",
        "LLVMDemangle",
        "Remarks", -- shared
        "LTO"      -- shared
    }
end

function get_bolt_shared_libraries()
    return {} -- TODO
end

function get_bolt_static_libraries()
    return {
        "LLVMBOLTRewrite",
        "LLVMBOLTRuntimeLibs",
        "LLVMBOLTTargetRISCV",
        "LLVMBOLTTargetX86",
        "LLVMBOLTTargetAArch64",
        "LLVMBOLTProfile",
        "LLVMBOLTPasses",
        "LLVMBOLTCore",
        "LLVMBOLTUtils"
    }
end

function get_polly_shared_libraries()
    return {} -- TODO
end

function get_polly_static_libraries()
    return {
        "Polly",
        "LLVMPolly", -- shared
        "PollyISL",
    }
end

--- from cmake/clang/ClangTargets.cmake

function get_clang_shared_libraries()
    return {
        "clang-cpp",
        "clang" -- Clang's stable CAPI (shared)
    }
end

function get_clang_static_libraries()
    return {
        "clangInterpreter",
        "clangFrontendTool",
        "clangStaticAnalyzerFrontend",
        "clangStaticAnalyzerCheckers",
        "clangTransformer",
        "clangStaticAnalyzerCore",
        "clangToolingRefactoring",
        "clangExtractAPI",
        "clangCrossTU",
        "clangHandleCXX",
        "clangDependencyScanning",
        "clangIndex",
        "clangTooling",
        "clangToolingSyntax",
        "clangRewriteFrontend",
        "clangARCMigrate",
        "clangCodeGen",
        "clangFrontend",
        "clangAnalysisFlowSensitiveModels",
        "clangSerialization",
        "clangParse",
        "clangFormat",
        "clangAnalysisFlowSensitive",
        "clangSema",
        "clangToolingInclusions",
        "clangAnalysis",
        "clangDynamicASTMatchers",
        "clangToolingCore",
        "clangInstallAPI",
        "clangToolingASTDiff",
        "clangToolingInclusionsStdlib",
        "clangEdit",
        "clangASTMatchers",
        "clangRewrite",
        "clangAST",
        "clangIndexSerialization",
        "clangDriver",
        "clangLex",
        "clangAPINotes",
        "clangHandleLLVM",
        "clangSupport",
        "clangDirectoryWatcher",
        "clangBasic",
        "clang", -- Clang's stable CAPI (shared)
    }
end

--- from cmake/lld/LLDTargets.cmake

function get_lld_shared_libraries()
    return {} -- TODO
end

function get_lld_static_libraries()
    return {
        "lldMinGW",
        "lldWasm",
        "lldMachO",
        "lldELF",
        "lldCOFF",
        "lldCommon",
    }
end

--- lldb

function get_lldb_shared_libraries()
    return {
        "lldb"
    }
end

function get_lldb_static_libraries()
    return {
        "lldb" -- shared
    }
end
