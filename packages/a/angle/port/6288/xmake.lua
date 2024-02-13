set_project("angle")
set_version("6288")
set_languages("c99", "c++17")

add_rules("mode.debug", "mode.release")

add_requires("python 3.x", {kind = "binary"})
add_requires("zlib")
-- add_requires("chromium_zlib")

function angle_define_option(name, opt)
local opt = opt or {}
option(name)
    set_default(false)
    before_check(function (option)
        if opt.default then option:enable(true) end
    end)
option_end()
end

-- gni/angle.gni
angle_define_option("enable_cl",         {default=false})
angle_define_option("with_capture",      {default=false})
angle_define_option("use_x11",           {default=is_plat("linux")})
angle_define_option("use_wayland",       {default=false})
angle_define_option("use_libpci",        {default=false})

if has_config("use_x11") then
    add_requires("libx11", "libxext", "libxi")
end
if has_config("use_wayland") then
    add_requires("wayland")
end
if has_config("use_libpci") then
    add_requires("pciutils")
end

-- backends
angle_define_option("enable_null",       {default=false})
angle_define_option("enable_d3d9",       {default=is_plat("windows")})
angle_define_option("enable_d3d11",      {default=is_plat("windows")})
angle_define_option("enable_gl",         {default=true})
angle_define_option("enable_metal",      {default=is_plat("macosx")})
angle_define_option("enable_vulkan",     {default=false})
angle_define_option("enable_gl_desktop", {default=is_plat("windows", "macosx", "linux")})

angle_define_option("enable_hlsl",       {default=is_plat("windows")})
angle_define_option("enable_essl",       {default=true})
angle_define_option("enable_glsl",       {default=true})

-- loaders
angle_define_option("enable_wgpu",       {default=false})
angle_define_option("enable_cgl",        {default=is_plat("macosx")})
angle_define_option("enable_eagl",       {default=is_plat("iphoneos")})

if has_config("enable_gl_desktop") then
    add_requires("opengl")
end
if has_config("enable_vulkan") then
    add_requires("vulkansdk")
end

local zlib_wrapper_sources = {
  "third_party/zlib/google/compression_utils_portable.cc"
}
-- src/compiler.gni
local angle_translator_sources = {
  "src/compiler/translator/BaseTypes.cpp",
  "src/compiler/translator/BuiltInFunctionEmulator.cpp",
  "src/compiler/translator/CallDAG.cpp",
  "src/compiler/translator/CodeGen.cpp",
  "src/compiler/translator/CollectVariables.cpp",
  "src/compiler/translator/Compiler.cpp",
  "src/compiler/translator/ConstantUnion.cpp",
  "src/compiler/translator/Declarator.cpp",
  "src/compiler/translator/Diagnostics.cpp",
  "src/compiler/translator/DirectiveHandler.cpp",
  "src/compiler/translator/ExtensionBehavior.cpp",
  "src/compiler/translator/FlagStd140Structs.cpp",
  "src/compiler/translator/FunctionLookup.cpp",
  "src/compiler/translator/HashNames.cpp",
  "src/compiler/translator/ImmutableStringBuilder.cpp",
  "src/compiler/translator/InfoSink.cpp",
  "src/compiler/translator/Initialize.cpp",
  "src/compiler/translator/InitializeDll.cpp",
  "src/compiler/translator/IntermNode.cpp",
  "src/compiler/translator/IsASTDepthBelowLimit.cpp",
  "src/compiler/translator/Operator.cpp",
  "src/compiler/translator/OutputTree.cpp",
  "src/compiler/translator/ParseContext.cpp",
  "src/compiler/translator/PoolAlloc.cpp",
  "src/compiler/translator/QualifierTypes.cpp",
  "src/compiler/translator/ShaderLang.cpp",
  "src/compiler/translator/ShaderVars.cpp",
  "src/compiler/translator/Symbol.cpp",
  "src/compiler/translator/SymbolTable.cpp",
  "src/compiler/translator/SymbolUniqueId.cpp",
  "src/compiler/translator/Types.cpp",
  "src/compiler/translator/ValidateAST.cpp",
  "src/compiler/translator/ValidateBarrierFunctionCall.cpp",
  "src/compiler/translator/ValidateClipCullDistance.cpp",
  "src/compiler/translator/ValidateGlobalInitializer.cpp",
  "src/compiler/translator/ValidateLimitations.cpp",
  "src/compiler/translator/ValidateMaxParameters.cpp",
  "src/compiler/translator/ValidateOutputs.cpp",
  "src/compiler/translator/ValidateSwitch.cpp",
  "src/compiler/translator/ValidateTypeSizeLimitations.cpp",
  "src/compiler/translator/ValidateVaryingLocations.cpp",
  "src/compiler/translator/VariablePacker.cpp",
  "src/compiler/translator/blocklayout.cpp",
  "src/compiler/translator/glslang_lex_autogen.cpp",
  "src/compiler/translator/glslang_tab_autogen.cpp",
  "src/compiler/translator/tree_ops/ClampFragDepth.cpp",
  "src/compiler/translator/tree_ops/ClampIndirectIndices.cpp",
  "src/compiler/translator/tree_ops/ClampPointSize.cpp",
  "src/compiler/translator/tree_ops/DeclareAndInitBuiltinsForInstancedMultiview.cpp",
  "src/compiler/translator/tree_ops/DeclarePerVertexBlocks.cpp",
  "src/compiler/translator/tree_ops/DeferGlobalInitializers.cpp",
  "src/compiler/translator/tree_ops/EmulateGLFragColorBroadcast.cpp",
  "src/compiler/translator/tree_ops/EmulateMultiDrawShaderBuiltins.cpp",
  "src/compiler/translator/tree_ops/FoldExpressions.cpp",
  "src/compiler/translator/tree_ops/ForcePrecisionQualifier.cpp",
  "src/compiler/translator/tree_ops/InitializeVariables.cpp",
  "src/compiler/translator/tree_ops/MonomorphizeUnsupportedFunctions.cpp",
  "src/compiler/translator/tree_ops/PreTransformTextureCubeGradDerivatives.cpp",
  "src/compiler/translator/tree_ops/PruneEmptyCases.cpp",
  "src/compiler/translator/tree_ops/PruneNoOps.cpp",
  "src/compiler/translator/tree_ops/RecordConstantPrecision.cpp",
  "src/compiler/translator/tree_ops/RemoveArrayLengthMethod.cpp",
  "src/compiler/translator/tree_ops/RemoveAtomicCounterBuiltins.cpp",
  "src/compiler/translator/tree_ops/RemoveDynamicIndexing.cpp",
  "src/compiler/translator/tree_ops/RemoveInactiveInterfaceVariables.cpp",
  "src/compiler/translator/tree_ops/RemoveInvariantDeclaration.cpp",
  "src/compiler/translator/tree_ops/RemoveUnreferencedVariables.cpp",
  "src/compiler/translator/tree_ops/RescopeGlobalVariables.cpp",
  "src/compiler/translator/tree_ops/RewriteArrayOfArrayOfOpaqueUniforms.cpp",
  "src/compiler/translator/tree_ops/RewriteAtomicCounters.cpp",
  "src/compiler/translator/tree_ops/RewriteCubeMapSamplersAs2DArray.cpp",
  "src/compiler/translator/tree_ops/RewriteDfdy.cpp",
  "src/compiler/translator/tree_ops/RewritePixelLocalStorage.cpp",
  "src/compiler/translator/tree_ops/RewriteStructSamplers.cpp",
  "src/compiler/translator/tree_ops/RewriteTexelFetchOffset.cpp",
  "src/compiler/translator/tree_ops/SeparateDeclarations.cpp",
  "src/compiler/translator/tree_ops/SeparateStructFromUniformDeclarations.cpp",
  "src/compiler/translator/tree_ops/SimplifyLoopConditions.cpp",
  "src/compiler/translator/tree_ops/SplitSequenceOperator.cpp",
  "src/compiler/translator/tree_util/DriverUniform.cpp",
  "src/compiler/translator/tree_util/FindFunction.cpp",
  "src/compiler/translator/tree_util/FindMain.cpp",
  "src/compiler/translator/tree_util/FindPreciseNodes.cpp",
  "src/compiler/translator/tree_util/FindSymbolNode.cpp",
  "src/compiler/translator/tree_util/IntermNodePatternMatcher.cpp",
  "src/compiler/translator/tree_util/IntermNode_util.cpp",
  "src/compiler/translator/tree_util/IntermTraverse.cpp",
  "src/compiler/translator/tree_util/ReplaceArrayOfMatrixVarying.cpp",
  "src/compiler/translator/tree_util/ReplaceClipCullDistanceVariable.cpp",
  "src/compiler/translator/tree_util/ReplaceShadowingVariables.cpp",
  "src/compiler/translator/tree_util/ReplaceVariable.cpp",
  "src/compiler/translator/tree_util/RewriteSampleMaskVariable.cpp",
  "src/compiler/translator/tree_util/RunAtTheBeginningOfShader.cpp",
  "src/compiler/translator/tree_util/RunAtTheEndOfShader.cpp",
  "src/compiler/translator/tree_util/SpecializationConstant.cpp",
  "src/compiler/translator/util.cpp",
}
local angle_translator_glsl_base_sources = {
  "src/compiler/translator/glsl/OutputGLSLBase.cpp",
}
local angle_translator_glsl_and_vulkan_base_sources = {
  "src/compiler/translator/glsl/OutputGLSL.cpp",
}
local angle_translator_essl_sources = {
  "src/compiler/translator/glsl/OutputESSL.cpp",
  "src/compiler/translator/glsl/TranslatorESSL.cpp",
}
local angle_translator_glsl_sources = {
  "src/compiler/translator/glsl/BuiltInFunctionEmulatorGLSL.cpp",
  "src/compiler/translator/glsl/ExtensionGLSL.cpp",
  "src/compiler/translator/glsl/TranslatorGLSL.cpp",
  "src/compiler/translator/glsl/VersionGLSL.cpp",
  "src/compiler/translator/tree_ops/glsl/RegenerateStructNames.cpp",
  "src/compiler/translator/tree_ops/glsl/RewriteRepeatedAssignToSwizzled.cpp",
  "src/compiler/translator/tree_ops/glsl/ScalarizeVecAndMatConstructorArgs.cpp",
  "src/compiler/translator/tree_ops/glsl/UseInterfaceBlockFields.cpp",
}
local angle_translator_glsl_apple_sources = {
  "src/compiler/translator/tree_ops/glsl/apple/AddAndTrueToLoopCondition.cpp",
  "src/compiler/translator/tree_ops/glsl/apple/RewriteDoWhile.cpp",
  "src/compiler/translator/tree_ops/glsl/apple/RewriteRowMajorMatrices.cpp",
  "src/compiler/translator/tree_ops/glsl/apple/RewriteUnaryMinusOperatorFloat.cpp",
  "src/compiler/translator/tree_ops/glsl/apple/UnfoldShortCircuitAST.cpp",
}
local angle_translator_hlsl_sources = {
  "src/compiler/translator/hlsl/ASTMetadataHLSL.cpp",
  "src/compiler/translator/hlsl/AtomicCounterFunctionHLSL.cpp",
  "src/compiler/translator/hlsl/BuiltInFunctionEmulatorHLSL.cpp",
  "src/compiler/translator/hlsl/ImageFunctionHLSL.cpp",
  "src/compiler/translator/hlsl/OutputHLSL.cpp",
  "src/compiler/translator/hlsl/ResourcesHLSL.cpp",
  "src/compiler/translator/hlsl/ShaderStorageBlockFunctionHLSL.cpp",
  "src/compiler/translator/hlsl/ShaderStorageBlockOutputHLSL.cpp",
  "src/compiler/translator/hlsl/StructureHLSL.cpp",
  "src/compiler/translator/hlsl/TextureFunctionHLSL.cpp",
  "src/compiler/translator/hlsl/TranslatorHLSL.cpp",
  "src/compiler/translator/hlsl/UtilsHLSL.cpp",
  "src/compiler/translator/hlsl/blocklayoutHLSL.cpp",
  "src/compiler/translator/hlsl/emulated_builtin_functions_hlsl_autogen.cpp",
  "src/compiler/translator/tree_ops/hlsl/AddDefaultReturnStatements.cpp",
  "src/compiler/translator/tree_ops/hlsl/AggregateAssignArraysInSSBOs.cpp",
  "src/compiler/translator/tree_ops/hlsl/AggregateAssignStructsInSSBOs.cpp",
  "src/compiler/translator/tree_ops/hlsl/ArrayReturnValueToOutParameter.cpp",
  "src/compiler/translator/tree_ops/hlsl/BreakVariableAliasingInInnerLoops.cpp",
  "src/compiler/translator/tree_ops/hlsl/ExpandIntegerPowExpressions.cpp",
  "src/compiler/translator/tree_ops/hlsl/RecordUniformBlocksWithLargeArrayMember.cpp",
  "src/compiler/translator/tree_ops/hlsl/RemoveSwitchFallThrough.cpp",
  "src/compiler/translator/tree_ops/hlsl/RewriteAtomicFunctionExpressions.cpp",
  "src/compiler/translator/tree_ops/hlsl/RewriteElseBlocks.cpp",
  "src/compiler/translator/tree_ops/hlsl/RewriteExpressionsWithShaderStorageBlock.cpp",
  "src/compiler/translator/tree_ops/hlsl/RewriteUnaryMinusOperatorInt.cpp",
  "src/compiler/translator/tree_ops/hlsl/SeparateArrayConstructorStatements.cpp",
  "src/compiler/translator/tree_ops/hlsl/SeparateArrayInitialization.cpp",
  "src/compiler/translator/tree_ops/hlsl/SeparateExpressionsReturningArrays.cpp",
  "src/compiler/translator/tree_ops/hlsl/UnfoldShortCircuitToIf.cpp",
  "src/compiler/translator/tree_ops/hlsl/WrapSwitchStatementsInBlocks.cpp",
}
local angle_translator_lib_spirv_sources = {
  "src/compiler/translator/spirv/BuildSPIRV.cpp",
  "src/compiler/translator/spirv/BuiltinsWorkaround.cpp",
  "src/compiler/translator/spirv/OutputSPIRV.cpp",
  "src/compiler/translator/spirv/TranslatorSPIRV.cpp",
  "src/compiler/translator/tree_ops/spirv/EmulateAdvancedBlendEquations.cpp",
  "src/compiler/translator/tree_ops/spirv/EmulateDithering.cpp",
  "src/compiler/translator/tree_ops/spirv/EmulateFragColorData.cpp",
  "src/compiler/translator/tree_ops/spirv/EmulateFramebufferFetch.cpp",
  "src/compiler/translator/tree_ops/spirv/EmulateYUVBuiltIns.cpp",
  "src/compiler/translator/tree_ops/spirv/FlagSamplersWithTexelFetch.cpp",
  "src/compiler/translator/tree_ops/spirv/ReswizzleYUVOps.cpp",
  "src/compiler/translator/tree_ops/spirv/RewriteInterpolateAtOffset.cpp",
  "src/compiler/translator/tree_ops/spirv/RewriteR32fImages.cpp",
}
local angle_translator_essl_symbol_table_sources = {
  "src/compiler/translator/ImmutableString_ESSL_autogen.cpp",
  "src/compiler/translator/SymbolTable_ESSL_autogen.cpp",
}
local angle_translator_glsl_symbol_table_sources = {
  "src/compiler/translator/ImmutableString_autogen.cpp",
  "src/compiler/translator/SymbolTable_autogen.cpp",
}
local angle_translator_lib_msl_sources = {
  "src/compiler/translator/msl/AstHelpers.cpp",
  "src/compiler/translator/msl/ConstantNames.cpp",
  "src/compiler/translator/msl/DiscoverDependentFunctions.cpp",
  "src/compiler/translator/msl/DiscoverEnclosingFunctionTraverser.cpp",
  "src/compiler/translator/msl/DriverUniformMetal.cpp",
  "src/compiler/translator/msl/EmitMetal.cpp",
  "src/compiler/translator/msl/IdGen.cpp",
  "src/compiler/translator/msl/IntermRebuild.cpp",
  "src/compiler/translator/msl/Layout.cpp",
  "src/compiler/translator/msl/MapFunctionsToDefinitions.cpp",
  "src/compiler/translator/msl/MapSymbols.cpp",
  "src/compiler/translator/msl/ModifyStruct.cpp",
  "src/compiler/translator/msl/Name.cpp",
  "src/compiler/translator/msl/Pipeline.cpp",
  "src/compiler/translator/msl/ProgramPrelude.cpp",
  "src/compiler/translator/msl/RewritePipelines.cpp",
  "src/compiler/translator/msl/SymbolEnv.cpp",
  "src/compiler/translator/msl/ToposortStructs.cpp",
  "src/compiler/translator/msl/TranslatorMSL.cpp",
  "src/compiler/translator/msl/UtilsMSL.cpp",
  "src/compiler/translator/tree_ops/msl/AddExplicitTypeCasts.cpp",
  "src/compiler/translator/tree_ops/msl/ConvertUnsupportedConstructorsToFunctionCalls.cpp",
  "src/compiler/translator/tree_ops/msl/FixTypeConstructors.cpp",
  "src/compiler/translator/tree_ops/msl/GuardFragDepthWrite.cpp",
  "src/compiler/translator/tree_ops/msl/HoistConstants.cpp",
  "src/compiler/translator/tree_ops/msl/IntroduceVertexIndexID.cpp",
  "src/compiler/translator/tree_ops/msl/NameEmbeddedUniformStructsMetal.cpp",
  "src/compiler/translator/tree_ops/msl/ReduceInterfaceBlocks.cpp",
  "src/compiler/translator/tree_ops/msl/RewriteCaseDeclarations.cpp",
  "src/compiler/translator/tree_ops/msl/RewriteInterpolants.cpp",
  "src/compiler/translator/tree_ops/msl/RewriteOutArgs.cpp",
  "src/compiler/translator/tree_ops/msl/RewriteUnaddressableReferences.cpp",
  "src/compiler/translator/tree_ops/msl/SeparateCompoundExpressions.cpp",
  "src/compiler/translator/tree_ops/msl/SeparateCompoundStructDeclarations.cpp",
  "src/compiler/translator/tree_ops/msl/TransposeRowMajorMatrices.cpp",
  "src/compiler/translator/tree_ops/msl/WrapMain.cpp",
}
local angle_preprocessor_sources = {
  "src/compiler/preprocessor/DiagnosticsBase.cpp",
  "src/compiler/preprocessor/DirectiveHandlerBase.cpp",
  "src/compiler/preprocessor/DirectiveParser.cpp",
  "src/compiler/preprocessor/Input.cpp",
  "src/compiler/preprocessor/Lexer.cpp",
  "src/compiler/preprocessor/Macro.cpp",
  "src/compiler/preprocessor/MacroExpander.cpp",
  "src/compiler/preprocessor/Preprocessor.cpp",
  "src/compiler/preprocessor/Token.cpp",
  "src/compiler/preprocessor/preprocessor_lex_autogen.cpp",
  "src/compiler/preprocessor/preprocessor_tab_autogen.cpp",
}
-- end src/compiler.gni

-- src/libGLESv2.gni
local libangle_common_sources = {
    "src/common/Float16ToFloat32.cpp",
    "src/common/MemoryBuffer.cpp",
    "src/common/PackedEGLEnums_autogen.cpp",
    "src/common/PackedEnums.cpp",
    "src/common/PackedGLEnums_autogen.cpp",
    "src/common/PoolAlloc.cpp",
    "src/common/RingBufferAllocator.cpp",
    "src/common/WorkerThread.cpp",
    "src/common/aligned_memory.cpp",
    "src/common/android_util.cpp",
    "src/common/angleutils.cpp",
    "src/common/base/anglebase/sha1.cc",
    "src/common/debug.cpp",
    "src/common/entry_points_enum_autogen.cpp",
    "src/common/event_tracer.cpp",
    "src/common/mathutil.cpp",
    "src/common/matrix_utils.cpp",
    "src/common/platform_helpers.cpp",
    "src/common/string_utils.cpp",
    "src/common/system_utils.cpp",
    "src/common/tls.cpp",
    "src/common/uniform_type_info_autogen.cpp",
    "src/common/utilities.cpp",
}
if is_plat("android") then
    table.join2(libangle_common_sources, "src/common/backtrace_utils_android.cpp")
else
    table.join2(libangle_common_sources, "src/common/backtrace_utils_noop.cpp")
end
if is_plat("linux", "android") then
    table.join2(libangle_common_sources, "src/common/system_utils_linux.cpp")
    table.join2(libangle_common_sources, "src/common/system_utils_posix.cpp")
end
if is_plat("macosx", "iphoneos") then
    table.join2(libangle_common_sources, {
        "src/common/apple_platform_utils.mm",
        "src/common/system_utils_apple.cpp",
        "src/common/system_utils_posix.cpp",
    })
    if is_plat("macosx") then
        table.join2(libangle_common_sources, "src/common/gl/cgl/FunctionsCGL.cpp")
        table.join2(libangle_common_sources, "src/common/system_utils_mac.cpp")
    elseif is_plat("iphoneos") then
        table.join2(libangle_common_sources, "src/common/system_utils_ios.cpp")
    end
end
if is_plat("windows") then
    table.join2(libangle_common_sources, "src/common/system_utils_win.cpp")
    table.join2(libangle_common_sources, "src/common/system_utils_win32.cpp")
end
local libangle_common_shader_state_sources = {
    "src/common/CompiledShaderState.cpp"
}
local libangle_common_cl_sources = {
    "src/common/PackedCLEnums_autogen.cpp"
}
local xxhash_sources = {
    "src/common/third_party/xxhash/xxhash.c"
}
local libangle_image_util_sources = {
  "src/image_util/copyimage.cpp",
  "src/image_util/imageformats.cpp",
  "src/image_util/loadimage.cpp",
  "src/image_util/loadimage_astc.cpp",
  "src/image_util/loadimage_etc.cpp",
  "src/image_util/loadimage_paletted.cpp",
  "src/image_util/storeimage_paletted.cpp",
  -- no astc encoder
  "src/image_util/AstcDecompressorNoOp.cpp"
}
local libangle_gpu_info_util_sources = { "src/gpu_info_util/SystemInfo.cpp" }
local libangle_gpu_info_util_win_sources = { "src/gpu_info_util/SystemInfo_win.cpp" }
local libangle_gpu_info_util_android_sources = { "src/gpu_info_util/SystemInfo_android.cpp" }
local libangle_gpu_info_util_linux_sources = { "src/gpu_info_util/SystemInfo_linux.cpp" }
local libangle_gpu_info_util_vulkan_sources = { "src/gpu_info_util/SystemInfo_vulkan.cpp" }
local libangle_gpu_info_util_libpci_sources = { "src/gpu_info_util/SystemInfo_libpci.cpp" }
local libangle_gpu_info_util_x11_sources = { "src/gpu_info_util/SystemInfo_x11.cpp" }
local libangle_gpu_info_util_mac_sources = {
    "src/gpu_info_util/SystemInfo_apple.mm",
    "src/gpu_info_util/SystemInfo_macos.mm",
}
local libangle_gpu_info_util_ios_sources = {
    "src/gpu_info_util/SystemInfo_apple.mm",
    "src/gpu_info_util/SystemInfo_ios.cpp",
}
local libXNVCtrl_sources = { "src/third_party/libXNVCtrl/NVCtrl.c" }
local libangle_headers = { "src/libANGLE/entry_points_utils.cpp" }
local libangle_sources = {
  "src/libANGLE/AttributeMap.cpp",
  "src/libANGLE/BlobCache.cpp",
  "src/libANGLE/Buffer.cpp",
  "src/libANGLE/Caps.cpp",
  "src/libANGLE/Compiler.cpp",
  "src/libANGLE/Config.cpp",
  "src/libANGLE/Context.cpp",
  "src/libANGLE/ContextMutex.cpp",
  "src/libANGLE/Context_gles_1_0.cpp",
  "src/libANGLE/Debug.cpp",
  "src/libANGLE/Device.cpp",
  "src/libANGLE/Display.cpp",
  "src/libANGLE/EGLSync.cpp",
  "src/libANGLE/Error.cpp",
  "src/libANGLE/Fence.cpp",
  "src/libANGLE/Framebuffer.cpp",
  "src/libANGLE/FramebufferAttachment.cpp",
  "src/libANGLE/GLES1Renderer.cpp",
  "src/libANGLE/GLES1State.cpp",
  "src/libANGLE/GlobalMutex.cpp",
  "src/libANGLE/HandleAllocator.cpp",
  "src/libANGLE/Image.cpp",
  "src/libANGLE/ImageIndex.cpp",
  "src/libANGLE/IndexRangeCache.cpp",
  "src/libANGLE/LoggingAnnotator.cpp",
  "src/libANGLE/MemoryObject.cpp",
  "src/libANGLE/MemoryProgramCache.cpp",
  "src/libANGLE/MemoryShaderCache.cpp",
  "src/libANGLE/Observer.cpp",
  "src/libANGLE/Overlay.cpp",
  "src/libANGLE/OverlayWidgets.cpp",
  "src/libANGLE/Overlay_autogen.cpp",
  "src/libANGLE/Overlay_font_autogen.cpp",
  "src/libANGLE/PixelLocalStorage.cpp",
  "src/libANGLE/Platform.cpp",
  "src/libANGLE/Program.cpp",
  "src/libANGLE/ProgramExecutable.cpp",
  "src/libANGLE/ProgramLinkedResources.cpp",
  "src/libANGLE/ProgramPipeline.cpp",
  "src/libANGLE/Query.cpp",
  "src/libANGLE/Renderbuffer.cpp",
  "src/libANGLE/ResourceManager.cpp",
  "src/libANGLE/Sampler.cpp",
  "src/libANGLE/Semaphore.cpp",
  "src/libANGLE/Shader.cpp",
  "src/libANGLE/ShareGroup.cpp",
  "src/libANGLE/State.cpp",
  "src/libANGLE/Stream.cpp",
  "src/libANGLE/Surface.cpp",
  "src/libANGLE/Texture.cpp",
  "src/libANGLE/Thread.cpp",
  "src/libANGLE/TransformFeedback.cpp",
  "src/libANGLE/Uniform.cpp",
  "src/libANGLE/VaryingPacking.cpp",
  "src/libANGLE/VertexArray.cpp",
  "src/libANGLE/VertexAttribute.cpp",
  "src/libANGLE/angletypes.cpp",
  "src/libANGLE/context_private_call_gles.cpp",
  "src/libANGLE/es3_copy_conversion_table_autogen.cpp",
  "src/libANGLE/format_map_autogen.cpp",
  "src/libANGLE/format_map_desktop.cpp",
  "src/libANGLE/formatutils.cpp",
  "src/libANGLE/gles_extensions_autogen.cpp",
  "src/libANGLE/queryconversions.cpp",
  "src/libANGLE/queryutils.cpp",
  "src/libANGLE/renderer/BufferImpl.cpp",
  "src/libANGLE/renderer/ContextImpl.cpp",
  "src/libANGLE/renderer/DeviceImpl.cpp",
  "src/libANGLE/renderer/DisplayImpl.cpp",
  "src/libANGLE/renderer/EGLReusableSync.cpp",
  "src/libANGLE/renderer/EGLSyncImpl.cpp",
  "src/libANGLE/renderer/Format_table_autogen.cpp",
  "src/libANGLE/renderer/FramebufferImpl.cpp",
  "src/libANGLE/renderer/ImageImpl.cpp",
  "src/libANGLE/renderer/ProgramImpl.cpp",
  "src/libANGLE/renderer/ProgramPipelineImpl.cpp",
  "src/libANGLE/renderer/QueryImpl.cpp",
  "src/libANGLE/renderer/RenderbufferImpl.cpp",
  "src/libANGLE/renderer/ShaderImpl.cpp",
  "src/libANGLE/renderer/SurfaceImpl.cpp",
  "src/libANGLE/renderer/TextureImpl.cpp",
  "src/libANGLE/renderer/TransformFeedbackImpl.cpp",
  "src/libANGLE/renderer/VertexArrayImpl.cpp",
  "src/libANGLE/renderer/driver_utils.cpp",
  "src/libANGLE/renderer/load_functions_table_autogen.cpp",
  "src/libANGLE/renderer/renderer_utils.cpp",
  "src/libANGLE/validationEGL.cpp",
  "src/libANGLE/validationES.cpp",
  "src/libANGLE/validationES1.cpp",
  "src/libANGLE/validationES2.cpp",
  "src/libANGLE/validationES3.cpp",
  "src/libANGLE/validationES31.cpp",
  "src/libANGLE/validationES32.cpp",
  "src/libANGLE/validationESEXT.cpp",
}
local libangle_gl_sources = {
  "src/libANGLE/Context_gl.cpp",
  "src/libANGLE/context_private_call_gl.cpp",
  "src/libANGLE/validationGL1.cpp",
  "src/libANGLE/validationGL2.cpp",
  "src/libANGLE/validationGL3.cpp",
  "src/libANGLE/validationGL4.cpp",
}
local libangle_cl_sources = {
  "src/libANGLE/CLBuffer.cpp",
  "src/libANGLE/CLCommandQueue.cpp",
  "src/libANGLE/CLContext.cpp",
  "src/libANGLE/CLDevice.cpp",
  "src/libANGLE/CLEvent.cpp",
  "src/libANGLE/CLImage.cpp",
  "src/libANGLE/CLKernel.cpp",
  "src/libANGLE/CLMemory.cpp",
  "src/libANGLE/CLObject.cpp",
  "src/libANGLE/CLPlatform.cpp",
  "src/libANGLE/CLProgram.cpp",
  "src/libANGLE/CLSampler.cpp",
  "src/libANGLE/cl_utils.cpp",
  "src/libANGLE/renderer/CLCommandQueueImpl.cpp",
  "src/libANGLE/renderer/CLContextImpl.cpp",
  "src/libANGLE/renderer/CLDeviceImpl.cpp",
  "src/libANGLE/renderer/CLEventImpl.cpp",
  "src/libANGLE/renderer/CLExtensions.cpp",
  "src/libANGLE/renderer/CLKernelImpl.cpp",
  "src/libANGLE/renderer/CLMemoryImpl.cpp",
  "src/libANGLE/renderer/CLPlatformImpl.cpp",
  "src/libANGLE/renderer/CLProgramImpl.cpp",
  "src/libANGLE/renderer/CLSamplerImpl.cpp",
  "src/libANGLE/validationCL.cpp",
}
local libangle_mac_sources = {
  "src/libANGLE/renderer/driver_utils_mac.mm",
}
local libangle_capture_sources = {
  "src/libANGLE/capture/FrameCapture.cpp",
  "src/libANGLE/capture/capture_egl_autogen.cpp",
  "src/libANGLE/capture/capture_gl_1_autogen.cpp",
  "src/libANGLE/capture/capture_gl_1_params.cpp",
  "src/libANGLE/capture/capture_gl_2_autogen.cpp",
  "src/libANGLE/capture/capture_gl_2_params.cpp",
  "src/libANGLE/capture/capture_gl_3_autogen.cpp",
  "src/libANGLE/capture/capture_gl_3_params.cpp",
  "src/libANGLE/capture/capture_gl_4_autogen.cpp",
  "src/libANGLE/capture/capture_gl_4_params.cpp",
  "src/libANGLE/capture/capture_gles_1_0_autogen.cpp",
  "src/libANGLE/capture/capture_gles_1_0_params.cpp",
  "src/libANGLE/capture/capture_gles_2_0_autogen.cpp",
  "src/libANGLE/capture/capture_gles_2_0_params.cpp",
  "src/libANGLE/capture/capture_gles_3_0_autogen.cpp",
  "src/libANGLE/capture/capture_gles_3_0_params.cpp",
  "src/libANGLE/capture/capture_gles_3_1_autogen.cpp",
  "src/libANGLE/capture/capture_gles_3_1_params.cpp",
  "src/libANGLE/capture/capture_gles_3_2_autogen.cpp",
  "src/libANGLE/capture/capture_gles_3_2_params.cpp",
  "src/libANGLE/capture/capture_gles_ext_autogen.cpp",
  "src/libANGLE/capture/capture_gles_ext_params.cpp",
}
local libglesv2_sources = {
  "src/libGLESv2/egl_ext_stubs.cpp",
  "src/libGLESv2/egl_stubs.cpp",
  "src/libGLESv2/entry_points_egl_autogen.cpp",
  "src/libGLESv2/entry_points_egl_ext_autogen.cpp",
  "src/libGLESv2/entry_points_gles_1_0_autogen.cpp",
  "src/libGLESv2/entry_points_gles_2_0_autogen.cpp",
  "src/libGLESv2/entry_points_gles_3_0_autogen.cpp",
  "src/libGLESv2/entry_points_gles_3_1_autogen.cpp",
  "src/libGLESv2/entry_points_gles_3_2_autogen.cpp",
  "src/libGLESv2/entry_points_gles_ext_autogen.cpp",
  "src/libGLESv2/global_state.cpp",
  "src/libGLESv2/libGLESv2_autogen.cpp",
  "src/libGLESv2/proc_table_egl_autogen.cpp",
}
local libglesv2_gl_sources = {
  "src/libGLESv2/entry_points_gl_1_autogen.cpp",
  "src/libGLESv2/entry_points_gl_2_autogen.cpp",
  "src/libGLESv2/entry_points_gl_3_autogen.cpp",
  "src/libGLESv2/entry_points_gl_4_autogen.cpp",
}
local libglesv2_cl_sources = {
  "src/libGLESv2/cl_dispatch_table.cpp",
  "src/libGLESv2/cl_stubs.cpp",
  "src/libGLESv2/entry_points_cl_autogen.cpp",
  "src/libGLESv2/entry_points_cl_utils.cpp",
  "src/libGLESv2/proc_table_cl_autogen.cpp",
}
local libglesv1_cm_sources = {
  "src/libGLESv1_CM/libGLESv1_CM.cpp",
}
if is_plat("windows") then
    table.join2(libglesv1_cm_sources, "src/libGLESv1_CM/libGLESv1_CM.rc")
end
local libegl_sources = {
  "src/libEGL/libEGL_autogen.cpp",
}
-- end src/libGLESv2.gni

-- src/common/linux/BUILD.gn
local angle_dma_buf = {
  "src/common/linux/dma_buf_utils.cpp",
}
-- end src/common/linux/BUILD.gn

-- src/libANGLE/renderer/null/null_backend.gni
local null_backend_sources = {
  "src/libANGLE/renderer/null/BufferNULL.cpp",
  "src/libANGLE/renderer/null/CompilerNULL.cpp",
  "src/libANGLE/renderer/null/ContextNULL.cpp",
  "src/libANGLE/renderer/null/DeviceNULL.cpp",
  "src/libANGLE/renderer/null/DisplayNULL.cpp",
  "src/libANGLE/renderer/null/FenceNVNULL.cpp",
  "src/libANGLE/renderer/null/FramebufferNULL.cpp",
  "src/libANGLE/renderer/null/ImageNULL.cpp",
  "src/libANGLE/renderer/null/ProgramExecutableNULL.cpp",
  "src/libANGLE/renderer/null/ProgramNULL.cpp",
  "src/libANGLE/renderer/null/ProgramPipelineNULL.cpp",
  "src/libANGLE/renderer/null/QueryNULL.cpp",
  "src/libANGLE/renderer/null/RenderbufferNULL.cpp",
  "src/libANGLE/renderer/null/SamplerNULL.cpp",
  "src/libANGLE/renderer/null/ShaderNULL.cpp",
  "src/libANGLE/renderer/null/SurfaceNULL.cpp",
  "src/libANGLE/renderer/null/SyncNULL.cpp",
  "src/libANGLE/renderer/null/TextureNULL.cpp",
  "src/libANGLE/renderer/null/TransformFeedbackNULL.cpp",
  "src/libANGLE/renderer/null/VertexArrayNULL.cpp",
}
-- end src/libANGLE/renderer/null/null_backend.gni

-- src/libANGLE/renderer/cl/BUILD.gn
local cl_backend_sources = {
  "src/libANGLE/renderer/cl/CLCommandQueueCL.cpp",
  "src/libANGLE/renderer/cl/CLContextCL.cpp",
  "src/libANGLE/renderer/cl/CLDeviceCL.cpp",
  "src/libANGLE/renderer/cl/CLEventCL.cpp",
  "src/libANGLE/renderer/cl/CLKernelCL.cpp",
  "src/libANGLE/renderer/cl/CLMemoryCL.cpp",
  "src/libANGLE/renderer/cl/CLPlatformCL.cpp",
  "src/libANGLE/renderer/cl/CLProgramCL.cpp",
  "src/libANGLE/renderer/cl/CLSamplerCL.cpp",
  "src/libANGLE/renderer/cl/cl_util.cpp",
}
-- end src/libANGLE/renderer/cl/BUILD.gn

-- src/libANGLE/renderer/d3d/d3d_backend.gni
local d3d_shared_sources = {
  "src/libANGLE/renderer/d3d/BufferD3D.cpp",
  "src/libANGLE/renderer/d3d/CompilerD3D.cpp",
  "src/libANGLE/renderer/d3d/DeviceD3D.cpp",
  "src/libANGLE/renderer/d3d/DisplayD3D.cpp",
  "src/libANGLE/renderer/d3d/DynamicHLSL.cpp",
  "src/libANGLE/renderer/d3d/DynamicImage2DHLSL.cpp",
  "src/libANGLE/renderer/d3d/EGLImageD3D.cpp",
  "src/libANGLE/renderer/d3d/FramebufferD3D.cpp",
  "src/libANGLE/renderer/d3d/HLSLCompiler.cpp",
  "src/libANGLE/renderer/d3d/ImageD3D.cpp",
  "src/libANGLE/renderer/d3d/IndexBuffer.cpp",
  "src/libANGLE/renderer/d3d/IndexDataManager.cpp",
  "src/libANGLE/renderer/d3d/NativeWindowD3D.cpp",
  "src/libANGLE/renderer/d3d/ProgramD3D.cpp",
  "src/libANGLE/renderer/d3d/ProgramExecutableD3D.cpp",
  "src/libANGLE/renderer/d3d/RenderTargetD3D.cpp",
  "src/libANGLE/renderer/d3d/RenderbufferD3D.cpp",
  "src/libANGLE/renderer/d3d/RendererD3D.cpp",
  "src/libANGLE/renderer/d3d/ShaderD3D.cpp",
  "src/libANGLE/renderer/d3d/ShaderExecutableD3D.cpp",
  "src/libANGLE/renderer/d3d/SurfaceD3D.cpp",
  "src/libANGLE/renderer/d3d/SwapChainD3D.cpp",
  "src/libANGLE/renderer/d3d/TextureD3D.cpp",
  "src/libANGLE/renderer/d3d/VertexBuffer.cpp",
  "src/libANGLE/renderer/d3d/VertexDataManager.cpp",
  "src/libANGLE/renderer/d3d/driver_utils_d3d.cpp",
}
local d3d9_backend_sources = {
  "src/libANGLE/renderer/d3d/d3d9/Blit9.cpp",
  "src/libANGLE/renderer/d3d/d3d9/Buffer9.cpp",
  "src/libANGLE/renderer/d3d/d3d9/Context9.cpp",
  "src/libANGLE/renderer/d3d/d3d9/DebugAnnotator9.cpp",
  "src/libANGLE/renderer/d3d/d3d9/Fence9.cpp",
  "src/libANGLE/renderer/d3d/d3d9/Framebuffer9.cpp",
  "src/libANGLE/renderer/d3d/d3d9/Image9.cpp",
  "src/libANGLE/renderer/d3d/d3d9/IndexBuffer9.cpp",
  "src/libANGLE/renderer/d3d/d3d9/NativeWindow9.cpp",
  "src/libANGLE/renderer/d3d/d3d9/Query9.cpp",
  "src/libANGLE/renderer/d3d/d3d9/RenderTarget9.cpp",
  "src/libANGLE/renderer/d3d/d3d9/Renderer9.cpp",
  "src/libANGLE/renderer/d3d/d3d9/ShaderExecutable9.cpp",
  "src/libANGLE/renderer/d3d/d3d9/StateManager9.cpp",
  "src/libANGLE/renderer/d3d/d3d9/SwapChain9.cpp",
  "src/libANGLE/renderer/d3d/d3d9/TextureStorage9.cpp",
  "src/libANGLE/renderer/d3d/d3d9/VertexBuffer9.cpp",
  "src/libANGLE/renderer/d3d/d3d9/VertexDeclarationCache.cpp",
  "src/libANGLE/renderer/d3d/d3d9/formatutils9.cpp",
  "src/libANGLE/renderer/d3d/d3d9/renderer9_utils.cpp",
}
local d3d11_backend_sources = {
  "src/libANGLE/renderer/d3d/d3d11/Blit11.cpp",
  "src/libANGLE/renderer/d3d/d3d11/Buffer11.cpp",
  "src/libANGLE/renderer/d3d/d3d11/Clear11.cpp",
  "src/libANGLE/renderer/d3d/d3d11/Context11.cpp",
  "src/libANGLE/renderer/d3d/d3d11/DebugAnnotator11.cpp",
  "src/libANGLE/renderer/d3d/d3d11/ExternalImageSiblingImpl11.cpp",
  "src/libANGLE/renderer/d3d/d3d11/Fence11.cpp",
  "src/libANGLE/renderer/d3d/d3d11/Framebuffer11.cpp",
  "src/libANGLE/renderer/d3d/d3d11/Image11.cpp",
  "src/libANGLE/renderer/d3d/d3d11/IndexBuffer11.cpp",
  "src/libANGLE/renderer/d3d/d3d11/InputLayoutCache.cpp",
  "src/libANGLE/renderer/d3d/d3d11/MappedSubresourceVerifier11.cpp",
  "src/libANGLE/renderer/d3d/d3d11/PixelTransfer11.cpp",
  "src/libANGLE/renderer/d3d/d3d11/Program11.cpp",
  "src/libANGLE/renderer/d3d/d3d11/ProgramPipeline11.cpp",
  "src/libANGLE/renderer/d3d/d3d11/Query11.cpp",
  "src/libANGLE/renderer/d3d/d3d11/RenderStateCache.cpp",
  "src/libANGLE/renderer/d3d/d3d11/RenderTarget11.cpp",
  "src/libANGLE/renderer/d3d/d3d11/Renderer11.cpp",
  "src/libANGLE/renderer/d3d/d3d11/ResourceManager11.cpp",
  "src/libANGLE/renderer/d3d/d3d11/ShaderExecutable11.cpp",
  "src/libANGLE/renderer/d3d/d3d11/StateManager11.cpp",
  "src/libANGLE/renderer/d3d/d3d11/StreamProducerD3DTexture.cpp",
  "src/libANGLE/renderer/d3d/d3d11/SwapChain11.cpp",
  "src/libANGLE/renderer/d3d/d3d11/TextureStorage11.cpp",
  "src/libANGLE/renderer/d3d/d3d11/TransformFeedback11.cpp",
  "src/libANGLE/renderer/d3d/d3d11/Trim11.cpp",
  "src/libANGLE/renderer/d3d/d3d11/VertexArray11.cpp",
  "src/libANGLE/renderer/d3d/d3d11/VertexBuffer11.cpp",
  "src/libANGLE/renderer/d3d/d3d11/formatutils11.cpp",
  "src/libANGLE/renderer/d3d/d3d11/renderer11_utils.cpp",
  "src/libANGLE/renderer/d3d/d3d11/texture_format_table.cpp",
  "src/libANGLE/renderer/d3d/d3d11/texture_format_table_autogen.cpp",
  "src/libANGLE/renderer/d3d/d3d11/win32/NativeWindow11Win32.cpp",
  "src/libANGLE/renderer/d3d/d3d11/converged/CompositorNativeWindow11.cpp",
}
-- end src/libANGLE/renderer/d3d/d3d_backend.gni

-- src/libANGLE/renderer/gl/gl_backend.gni
local gl_backend_sources = {
  "src/libANGLE/renderer/gl/BlitGL.cpp",
  "src/libANGLE/renderer/gl/BufferGL.cpp",
  "src/libANGLE/renderer/gl/ClearMultiviewGL.cpp",
  "src/libANGLE/renderer/gl/CompilerGL.cpp",
  "src/libANGLE/renderer/gl/ContextGL.cpp",
  "src/libANGLE/renderer/gl/DispatchTableGL_autogen.cpp",
  "src/libANGLE/renderer/gl/DisplayGL.cpp",
  "src/libANGLE/renderer/gl/FenceNVGL.cpp",
  "src/libANGLE/renderer/gl/FramebufferGL.cpp",
  "src/libANGLE/renderer/gl/FunctionsGL.cpp",
  "src/libANGLE/renderer/gl/ImageGL.cpp",
  "src/libANGLE/renderer/gl/MemoryObjectGL.cpp",
  "src/libANGLE/renderer/gl/PLSProgramCache.cpp",
  "src/libANGLE/renderer/gl/ProgramExecutableGL.cpp",
  "src/libANGLE/renderer/gl/ProgramGL.cpp",
  "src/libANGLE/renderer/gl/ProgramPipelineGL.cpp",
  "src/libANGLE/renderer/gl/QueryGL.cpp",
  "src/libANGLE/renderer/gl/RenderbufferGL.cpp",
  "src/libANGLE/renderer/gl/RendererGL.cpp",
  "src/libANGLE/renderer/gl/SamplerGL.cpp",
  "src/libANGLE/renderer/gl/SemaphoreGL.cpp",
  "src/libANGLE/renderer/gl/ShaderGL.cpp",
  "src/libANGLE/renderer/gl/StateManagerGL.cpp",
  "src/libANGLE/renderer/gl/SurfaceGL.cpp",
  "src/libANGLE/renderer/gl/SyncGL.cpp",
  "src/libANGLE/renderer/gl/TextureGL.cpp",
  "src/libANGLE/renderer/gl/TransformFeedbackGL.cpp",
  "src/libANGLE/renderer/gl/VertexArrayGL.cpp",
  "src/libANGLE/renderer/gl/formatutilsgl.cpp",
  "src/libANGLE/renderer/gl/renderergl_utils.cpp",
  "src/libANGLE/renderer/gl/null_functions.cpp",
}
local gl_backend_sources_wgl = {
    "src/libANGLE/renderer/gl/wgl/ContextWGL.cpp",
    "src/libANGLE/renderer/gl/wgl/D3DTextureSurfaceWGL.cpp",
    "src/libANGLE/renderer/gl/wgl/DXGISwapChainWindowSurfaceWGL.cpp",
    "src/libANGLE/renderer/gl/wgl/DisplayWGL.cpp",
    "src/libANGLE/renderer/gl/wgl/FunctionsWGL.cpp",
    "src/libANGLE/renderer/gl/wgl/PbufferSurfaceWGL.cpp",
    "src/libANGLE/renderer/gl/wgl/RendererWGL.cpp",
    "src/libANGLE/renderer/gl/wgl/WindowSurfaceWGL.cpp",
    "src/libANGLE/renderer/gl/wgl/wgl_utils.cpp",
}
if is_plat("windows") then
    table.join2(gl_backend_sources, gl_backend_sources_wgl)
end
local gl_backend_sources_glx = {
    "src/libANGLE/renderer/gl/glx/DisplayGLX.cpp",
    "src/libANGLE/renderer/gl/glx/FunctionsGLX.cpp",
    "src/libANGLE/renderer/gl/glx/PbufferSurfaceGLX.cpp",
    "src/libANGLE/renderer/gl/glx/PixmapSurfaceGLX.cpp",
    "src/libANGLE/renderer/gl/glx/WindowSurfaceGLX.cpp",
    "src/libANGLE/renderer/gl/glx/glx_utils.cpp",
}
if has_config("use_x11") then
    table.join2(gl_backend_sources, gl_backend_sources_glx)
end
local gl_backend_sources_egl = {
    "src/libANGLE/renderer/gl/egl/ContextEGL.cpp",
    "src/libANGLE/renderer/gl/egl/DeviceEGL.cpp",
    "src/libANGLE/renderer/gl/egl/DisplayEGL.cpp",
    "src/libANGLE/renderer/gl/egl/DmaBufImageSiblingEGL.cpp",
    "src/libANGLE/renderer/gl/egl/FunctionsEGL.cpp",
    "src/libANGLE/renderer/gl/egl/FunctionsEGLDL.cpp",
    "src/libANGLE/renderer/gl/egl/ImageEGL.cpp",
    "src/libANGLE/renderer/gl/egl/PbufferSurfaceEGL.cpp",
    "src/libANGLE/renderer/gl/egl/RendererEGL.cpp",
    "src/libANGLE/renderer/gl/egl/SurfaceEGL.cpp",
    "src/libANGLE/renderer/gl/egl/SyncEGL.cpp",
    "src/libANGLE/renderer/gl/egl/WindowSurfaceEGL.cpp",
    "src/libANGLE/renderer/gl/egl/egl_utils.cpp",
}
if is_plat("linux") or is_plat("android") then
    table.join2(gl_backend_sources, gl_backend_sources_egl)
end
local gl_backend_sources_android = {
    "src/libANGLE/renderer/gl/egl/android/DisplayAndroid.cpp",
    "src/libANGLE/renderer/gl/egl/android/NativeBufferImageSiblingAndroid.cpp",
}
if is_plat("android") then
    table.join2(gl_backend_sources, gl_backend_sources_android)
end
local gl_backend_sources_cgl = {
    "src/libANGLE/renderer/gl/cgl/ContextCGL.cpp",
    "src/libANGLE/renderer/gl/cgl/DeviceCGL.cpp",
    "src/libANGLE/renderer/gl/cgl/DisplayCGL.mm",
    "src/libANGLE/renderer/gl/cgl/IOSurfaceSurfaceCGL.cpp",
    "src/libANGLE/renderer/gl/cgl/PbufferSurfaceCGL.cpp",
    "src/libANGLE/renderer/gl/cgl/WindowSurfaceCGL.mm",
}
if has_config("enable_cgl") then
    table.join2(gl_backend_sources, gl_backend_sources_cgl)
end
local gl_backend_sources_eagl = {
    "src/libANGLE/renderer/gl/eagl/ContextEAGL.cpp",
    "src/libANGLE/renderer/gl/eagl/DeviceEAGL.cpp",
    "src/libANGLE/renderer/gl/eagl/DisplayEAGL.mm",
    "src/libANGLE/renderer/gl/eagl/FunctionsEAGL.mm",
    "src/libANGLE/renderer/gl/eagl/IOSurfaceSurfaceEAGL.mm",
    "src/libANGLE/renderer/gl/eagl/PbufferSurfaceEAGL.cpp",
    "src/libANGLE/renderer/gl/eagl/WindowSurfaceEAGL.mm",
}
if has_config("enable_eagl") then
    table.join2(gl_backend_sources, gl_backend_sources_eagl)
end
-- end src/libANGLE/renderer/gl/gl_backend.gni

-- src/libANGLE/renderer/metal/metal_backend.gni
local metal_backend_sources = {
  "src/libANGLE/renderer/metal/BufferMtl.mm",
  "src/libANGLE/renderer/metal/CompilerMtl.mm",
  "src/libANGLE/renderer/metal/ContextMtl.mm",
  "src/libANGLE/renderer/metal/DeviceMtl.mm",
  "src/libANGLE/renderer/metal/DisplayMtl.mm",
  "src/libANGLE/renderer/metal/FrameBufferMtl.mm",
  "src/libANGLE/renderer/metal/IOSurfaceSurfaceMtl.mm",
  "src/libANGLE/renderer/metal/ImageMtl.mm",
  "src/libANGLE/renderer/metal/ProgramExecutableMtl.mm",
  "src/libANGLE/renderer/metal/ProgramMtl.mm",
  "src/libANGLE/renderer/metal/ProvokingVertexHelper.mm",
  "src/libANGLE/renderer/metal/QueryMtl.mm",
  "src/libANGLE/renderer/metal/RenderBufferMtl.mm",
  "src/libANGLE/renderer/metal/RenderTargetMtl.mm",
  "src/libANGLE/renderer/metal/SamplerMtl.mm",
  "src/libANGLE/renderer/metal/ShaderMtl.mm",
  "src/libANGLE/renderer/metal/SurfaceMtl.mm",
  "src/libANGLE/renderer/metal/SyncMtl.mm",
  "src/libANGLE/renderer/metal/TextureMtl.mm",
  "src/libANGLE/renderer/metal/TransformFeedbackMtl.mm",
  "src/libANGLE/renderer/metal/VertexArrayMtl.mm",
  "src/libANGLE/renderer/metal/blocklayoutMetal.cpp",
  "src/libANGLE/renderer/metal/mtl_buffer_manager.mm",
  "src/libANGLE/renderer/metal/mtl_buffer_pool.mm",
  "src/libANGLE/renderer/metal/mtl_command_buffer.mm",
  "src/libANGLE/renderer/metal/mtl_common.mm",
  "src/libANGLE/renderer/metal/mtl_context_device.mm",
  "src/libANGLE/renderer/metal/mtl_format_table_autogen.mm",
  "src/libANGLE/renderer/metal/mtl_format_utils.mm",
  "src/libANGLE/renderer/metal/mtl_library_cache.mm",
  "src/libANGLE/renderer/metal/mtl_msl_utils.mm",
  "src/libANGLE/renderer/metal/mtl_occlusion_query_pool.mm",
  "src/libANGLE/renderer/metal/mtl_pipeline_cache.mm",
  "src/libANGLE/renderer/metal/mtl_render_utils.mm",
  "src/libANGLE/renderer/metal/mtl_resources.mm",
  "src/libANGLE/renderer/metal/mtl_state_cache.mm",
  "src/libANGLE/renderer/metal/mtl_utils.mm",
  "src/libANGLE/renderer/metal/process.cpp",
  "src/libANGLE/renderer/metal/renderermtl_utils.cpp",
}
-- end src/libANGLE/renderer/metal/metal_backend.gni

-- src/libANGLE/renderer/vulkan/vulkan_backend.gni
local vulkan_backend_sources = {
  "src/libANGLE/renderer/vulkan/AllocatorHelperPool.cpp",
  "src/libANGLE/renderer/vulkan/AllocatorHelperRing.cpp",
  "src/libANGLE/renderer/vulkan/BufferVk.cpp",
  "src/libANGLE/renderer/vulkan/CommandProcessor.cpp",
  "src/libANGLE/renderer/vulkan/CompilerVk.cpp",
  "src/libANGLE/renderer/vulkan/ContextVk.cpp",
  "src/libANGLE/renderer/vulkan/DebugAnnotatorVk.cpp",
  "src/libANGLE/renderer/vulkan/DeviceVk.cpp",
  "src/libANGLE/renderer/vulkan/DisplayVk.cpp",
  "src/libANGLE/renderer/vulkan/FenceNVVk.cpp",
  "src/libANGLE/renderer/vulkan/FramebufferVk.cpp",
  "src/libANGLE/renderer/vulkan/ImageVk.cpp",
  "src/libANGLE/renderer/vulkan/MemoryObjectVk.cpp",
  "src/libANGLE/renderer/vulkan/MemoryTracking.cpp",
  "src/libANGLE/renderer/vulkan/OverlayVk.cpp",
  "src/libANGLE/renderer/vulkan/PersistentCommandPool.cpp",
  "src/libANGLE/renderer/vulkan/ProgramExecutableVk.cpp",
  "src/libANGLE/renderer/vulkan/ProgramPipelineVk.cpp",
  "src/libANGLE/renderer/vulkan/ProgramVk.cpp",
  "src/libANGLE/renderer/vulkan/QueryVk.cpp",
  "src/libANGLE/renderer/vulkan/RenderTargetVk.cpp",
  "src/libANGLE/renderer/vulkan/RenderbufferVk.cpp",
  "src/libANGLE/renderer/vulkan/RendererVk.cpp",
  "src/libANGLE/renderer/vulkan/ResourceVk.cpp",
  "src/libANGLE/renderer/vulkan/SamplerVk.cpp",
  "src/libANGLE/renderer/vulkan/SecondaryCommandBuffer.cpp",
  "src/libANGLE/renderer/vulkan/SecondaryCommandPool.cpp",
  "src/libANGLE/renderer/vulkan/SemaphoreVk.cpp",
  "src/libANGLE/renderer/vulkan/ShaderInterfaceVariableInfoMap.cpp",
  "src/libANGLE/renderer/vulkan/ShaderVk.cpp",
  "src/libANGLE/renderer/vulkan/ShareGroupVk.cpp",
  "src/libANGLE/renderer/vulkan/Suballocation.cpp",
  "src/libANGLE/renderer/vulkan/SurfaceVk.cpp",
  "src/libANGLE/renderer/vulkan/SyncVk.cpp",
  "src/libANGLE/renderer/vulkan/TextureVk.cpp",
  "src/libANGLE/renderer/vulkan/TransformFeedbackVk.cpp",
  "src/libANGLE/renderer/vulkan/UtilsVk.cpp",
  "src/libANGLE/renderer/vulkan/VertexArrayVk.cpp",
  "src/libANGLE/renderer/vulkan/VkImageImageSiblingVk.cpp",
  "src/libANGLE/renderer/vulkan/VulkanSecondaryCommandBuffer.cpp",
  "src/libANGLE/renderer/vulkan/android/vk_android_utils.cpp",
  "src/libANGLE/renderer/vulkan/spv_utils.cpp",
  "src/libANGLE/renderer/vulkan/vk_cache_utils.cpp",
  "src/libANGLE/renderer/vulkan/vk_caps_utils.cpp",
  "src/libANGLE/renderer/vulkan/vk_format_table_autogen.cpp",
  "src/libANGLE/renderer/vulkan/vk_format_utils.cpp",
  "src/libANGLE/renderer/vulkan/vk_helpers.cpp",
  "src/libANGLE/renderer/vulkan/vk_internal_shaders_autogen.cpp",
  "src/libANGLE/renderer/vulkan/vk_mandatory_format_support_table_autogen.cpp",
  "src/libANGLE/renderer/vulkan/vk_utils.cpp",
}
-- end src/libANGLE/renderer/vulkan/vulkan_backend.gni

-- BUILD.gn
local angle_capture_common = {
    "src/common/frame_capture_utils.cpp",
    "src/common/frame_capture_utils_autogen.cpp",
}
local angle_version_info = { "src/common/angle_version_info.cpp" }
local angle_d3d_format_tables = {
    "src/libANGLE/renderer/dxgi_format_map_autogen.cpp",
    "src/libANGLE/renderer/dxgi_support_table_autogen.cpp",
    "src/libANGLE/renderer/d3d_format.cpp",
}
local angle_frame_capture_mock = {
    "src/libANGLE/capture/FrameCapture_mock.cpp",
    "src/libANGLE/capture/serialize_mock.cpp",
}
local angle_gl_enum_utils = {
    "src/common/gl_enum_utils.cpp",
    "src/common/gl_enum_utils_autogen.cpp",
}

if is_kind("static") then
    add_defines({
        "ANGLE_EXPORT=",
        "ANGLE_STATIC=1",
        "ANGLE_UTIL_EXPORT=",
        "EGLAPI=",
        "GL_APICALL=",
        "GL_API=",
    })
end

target("ANGLE")
    if is_plat("windows") then
        set_basename("libANGLE")
    end
    set_kind("static")
    add_defines("LIBANGLE_IMPLEMENTATION")
    add_defines("GL_GLES_PROTOTYPES=0", "EGL_EGL_PROTOTYPES=0")
    add_includedirs("src", "include", "$(buildir)/gen/angle", {public = true})
    add_includedirs("src/common/base",
                    "src/common/third_party/xxhash",
                    "src/third_party/khronos",
                    "third_party/zlib/google", {public = true})
    add_files(libangle_headers)
    add_files(libangle_sources)
    add_files(libangle_common_sources)
    add_files(libangle_common_shader_state_sources)
    add_files(libangle_image_util_sources)
    add_files(angle_preprocessor_sources)
    add_files(angle_translator_sources)
    add_files(angle_frame_capture_mock)
    add_files(angle_version_info)
    add_files(xxhash_sources)
    add_files(zlib_wrapper_sources)

    -- gpuinfo util
    add_files(libangle_gpu_info_util_sources)
    if is_plat("windows") then
        add_files(libangle_gpu_info_util_win_sources)
        add_syslinks("setupapi", "dxgi")
    end
    if is_plat("linux") then
        add_files(libangle_gpu_info_util_linux_sources)
    end
    if is_plat("macosx") then
        add_files(libangle_gpu_info_util_mac_sources)
        add_frameworks("CoreFoundation", "CoreGraphics", "IOKit")
    end
    if is_plat("android") then
        add_files(libangle_gpu_info_util_android_sources)
    end
    if is_plat("iphoneos") then
        add_files(libangle_gpu_info_util_ios_sources)
    end
    if has_config("use_x11") then
        add_packages("libx11", "libxext", "libxi")
        add_files(libangle_gpu_info_util_x11_sources)
        add_files(libXNVCtrl_sources)
        add_defines("GPU_INFO_USE_X11")
    end
    if has_config("use_libpci") then
        add_packages("pciutils")
        add_files(libangle_gpu_info_util_libpci_sources)
        add_defines("GPU_INFO_USE_LIBPCI")
    end

    -- backend
    if has_config("enable_null") then
        add_defines("ANGLE_ENABLE_NULL")
    end
    if has_config("enable_cl") then
        add_defines("ANGLE_ENABLE_CL_PASSTHROUGH")
        add_files("libangle_common_cl_sources")
    end
    if has_config("enable_glsl") then
        add_files(angle_translator_glsl_sources)
        add_files(angle_translator_glsl_base_sources)
        add_files(angle_translator_glsl_and_vulkan_base_sources)
        if is_plat("macosx", "iphoneos") then
            add_files(angle_translator_glsl_apple_sources)
        end
        add_defines("ANGLE_ENABLE_GLSL")
    end
    if has_config("enable_essl") then
        add_files(angle_translator_essl_sources)
        add_defines("ANGLE_ENABLE_ESSL")
    end
    if has_config("enable_hlsl") then
        add_files(angle_translator_hlsl_sources)
        add_defines("ANGLE_ENABLE_HLSL")
    end
    if is_plat("windows") then
        if has_config("enable_d3d9") or has_config("enable_d3d11") then
            add_defines("ANGLE_PRELOADED_D3DCOMPILER_MODULE_NAMES={ \"d3dcompiler_47.dll\", \"d3dcompiler_46.dll\", \"d3dcompiler_43.dll\" }")
            add_files(d3d_shared_sources)
        end
        if has_config("enable_d3d9") or has_config("enable_d3d11") or has_config("enable_gl") then
            add_files(angle_d3d_format_tables)
        end
        if has_config("enable_d3d9") then
            add_syslinks("d3d9", "delayimp")
            add_defines("ANGLE_ENABLE_D3D9")
            add_ldflags("/DELAYLOAD:d3d9.dll")
            add_files(d3d9_backend_sources)
        end
        if has_config("enable_d3d11") then
            add_syslinks("dxguid")
            add_defines("ANGLE_ENABLE_D3D11")
            add_defines("ANGLE_ENABLE_D3D11_COMPOSITOR_NATIVE_WINDOW")
            add_files(d3d11_backend_sources)
        end
    end
    if has_config("enable_gl") then
        add_defines("ANGLE_ENABLE_OPENGL")
        add_defines("ANGLE_ENABLE_OPENGL_NULL")
        add_files(gl_backend_sources)
        if has_config("enable_cgl") then
            add_defines("GL_SILENCE_DEPRECATION", "ANGLE_ENABLE_CGL")
            if is_plat("macosx") then
                add_frameworks("OpenGL")
            end
        end
        if has_config("enable_eagl") then
            add_defines("GL_SILENCE_DEPRECATION", "ANGLE_ENABLE_EAGL")
            if is_plat("macosx", "iphoneos") then
                add_frameworks("OpenGLES")
            end
        end
        if is_plat("linux") or is_plat("android") then
            add_files(angle_dma_buf)
        end
        if is_plat("macosx") or is_plat("iphoneos") then
            add_frameworks("IOSurface", "QuartzCore")
            if is_plat("macosx") then
                add_frameworks("Cocoa")
            end
        end
    end
    if has_config("enable_gl_desktop") then
        add_packages("opengl")
        add_defines("ANGLE_ENABLE_GL_DESKTOP_BACKEND")
        add_files(angle_translator_glsl_symbol_table_sources)
    else
        add_files(angle_translator_essl_symbol_table_sources)
    end
    if has_config("enable_metal") then
        add_defines("ANGLE_ENABLE_METAL")
        add_frameworks("Metal")
        add_files(metal_backend_sources)
        add_files(angle_translator_lib_msl_sources)
    end
    if has_config("enable_vulkan") then
        add_defines("ANGLE_ENABLE_VULKAN")
        add_files(vulkan_backend_sources)
        add_packages("vulkansdk")
        -- TODO
    end

    -- miscellanous
    add_headerfiles("include/(**.h)|export.h")
    add_defines("ANGLE_OUTSIDE_WEBKIT")
    add_defines("ANGLE_ENABLE_SHARE_CONTEXT_LOCK=1", "ANGLE_ENABLE_CONTEXT_MUTEX=1")
    add_packages("python")
    add_packages("zlib")
    -- add_packages("chromium_zlib")
    if has_config("with_capture") then
        add_defines("ANGLE_CAPTURE_ENABLED=1")
        add_files("src/libANGLE/capture/serialize_mock.cpp")
        add_files("angle_gl_enum_utils")
    else
        add_defines("ANGLE_CAPTURE_ENABLED=0")
    end
    if has_config("use_x11") then
        add_defines("ANGLE_USE_X11")
    end
    if has_config("use_wayland") then
        add_defines("ANGLE_USE_WAYLAND")
    end
    if is_plat("android") then
        add_defines("ANGLE_USE_ANDROID_TLS_SLOT=1")
        add_defines("ANGLE_ENABLE_GLOBAL_MUTEX_LOAD_TIME_ALLOCATE=1")
    else
        add_defines("ANGLE_PLATFORM_EXPORT=")
    end
    if is_plat("windows") then
        add_defines("ANGLE_IS_WIN")
        add_defines("WIN32_LEAN_AND_MEAN", "NOMINMAX", {public = true})
        add_syslinks("user32", "gdi32")
    elseif is_plat("macosx") then
        set_values("objc++.build.arc", false)
        add_files(libangle_mac_sources)
    elseif is_plat("linux") then
        add_defines("ANGLE_IS_LINUX")
        add_links("dl")
    elseif is_plat("iphoneos") then
        set_values("objc++.build.arc", false)
        add_files("src/libANGLE/renderer/driver_utils_ios.mm")
    end
    before_build(function (target)
        import("lib.detect.find_tool")
        import("core.tool.toolchain")
        import("core.base.option")

        -- generate version info
        local python = find_tool("python")
        assert(python, "python not found!")
        local buildir = val("buildir")
        if not os.isdir(buildir .. "/gen/angle") then
            os.mkdir(buildir .. "/gen/angle")
        end
        io.writefile(buildir .. "/gen/response", "")
        if option.get("verbose") then
            print(python.program .. " " .. "./src/commit_id.py gen " .. buildir .. "/gen/angle/angle_commit.h")
        end
        os.vrunv(python.program, {"./src/commit_id.py", "gen", buildir .. "/gen/angle/angle_commit.h"})
        if option.get("verbose") then
            print(python.program .. " " .. "./src/commit_id.py gen " .. buildir .. "/gen/angle/angle_commit_autogen.cpp")
        end
        os.vrunv(python.program, {"./src/program_serialize_data_version.py", buildir .. "/gen/angle/ANGLEShaderProgramVersion.h", buildir .. "/gen/response"})
        if option.get("verbose") then
            print("Done generating version info for ANGLE.")
        end

        -- add android syslinks
        if target:is_plat("android") then
            local ndk = toolchain.load("ndk")
            local ndk_sdkver = ndk:config("ndk_sdkver")
            if ndk_sdkver and tonumber(ndk_sdkver) >= 26 then
                target:add("syslinks", "nativewindow")
            else
                target:add("syslinks", "android")
            end
        end
    end)

target("GLESv2")
    set_kind("$(kind)")
    add_deps("ANGLE")
    add_defines("LIBGLESV2_IMPLEMENTATION")
    add_defines("GL_GLES_PROTOTYPES=1", "EGL_EGL_PROTOTYPES=1", "GL_GLEXT_PROTOTYPES", "EGL_EGLEXT_PROTOTYPES")
    add_files(libglesv2_sources)
    if is_plat("windows") then
        set_basename("libGLESv2")
        add_files("src/libGLESv2/libGLESv2.rc")
        add_files("src/libGLESv2/libGLESv2_autogen.def")
    end
    if is_plat("android") then
        set_basename("GLESv2_angle")
    end
    if has_config("enable_cl") then
        add_files(libglesv2_cl_sources)
    end
    if is_kind("shared") then
        if is_plat("windows") then
            add_defines("GL_APICALL=", "GL_API=")
        else
            add_defines(
                "GL_APICALL=__attribute__((visibility(\"default\")))",
                "GL_API=__attribute__((visibility(\"default\")))")
        end
    end
    after_install(function (target) 
        if target:is_plat("windows") and target:kind() == "shared" then
            local vcvars = import("core.tool.toolchain").load("msvc"):config("vcvars")
            local winsdkdir = vcvars["WindowsSdkDir"]
            local d3dcompiler = path.join(winsdkdir, "Redist", "D3D", target:arch(), "d3dcompiler_47.dll")
            os.cp(d3dcompiler, path.join(target:installdir(), "bin"))
        end
    end)

target("EGL")
    set_kind("$(kind)")
    add_deps("GLESv2")
    add_defines("LIBEGL_IMPLEMENTATION")
    add_defines("GL_GLES_PROTOTYPES=1", "EGL_EGL_PROTOTYPES=1", "GL_GLEXT_PROTOTYPES", "EGL_EGLEXT_PROTOTYPES")
    add_files(libegl_sources)
    add_defines("ANGLE_DISPATCH_LIBRARY=\"libGLESv2\"")
    if is_plat("windows") then
        set_basename("libEGL")
        add_files("src/libEGL/libEGL.rc")
        add_files("src/libEGL/libEGL_autogen.def")
    end
    if is_plat("android") then
        set_basename("EGL_angle")
    end
    if is_kind("shared") then
        add_files("src/libEGL/egl_loader_autogen.cpp")
        add_defines("ANGLE_USE_EGL_LOADER")
        if is_plat("windows") then
            add_defines("EGLAPI=")
        else
            add_defines("EGLAPI=__attribute__((visibility(\"default\")))")
        end
    end
