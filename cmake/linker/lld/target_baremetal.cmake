# SPDX-License-Identifier: Apache-2.0

# See root CMakeLists.txt for description and expectations of these macros

macro(toolchain_ld_baremetal)

  # LINKERFLAGPREFIX comes from linker/lld/target.cmake
  zephyr_ld_options(
    -nostdlib
    -static
    ${LINKERFLAGPREFIX},-X
    ${LINKERFLAGPREFIX},-N
  )

  # Force LLVM to use built-in lld linker
  if(NOT CONFIG_LLVM_USE_LD)
    zephyr_ld_options(
      -fuse-ld=lld
  )
  endif()

  # Funny thing is if this is set to =error, some architectures will
  # skip this flag even though the compiler flag check passes
  # (e.g. ARC and Xtensa). So warning should be the default for now.
  #
  # Skip this for native application as Zephyr only provides
  # additions to the host toolchain linker script. The relocation
  # sections (.rel*) requires us to override those provided
  # by host toolchain. As we can't account for all possible
  # combination of compiler and linker on all machines used
  # for development, it is better to turn this off.
  #
  # CONFIG_LINKER_ORPHAN_SECTION_PLACE is to place the orphan sections
  # without any warnings or errors, which is the default behavior.
  # So there is no need to explicitly set a linker flag.
  # HACK: Link -lc -lm -lclang_rt.builtins librares required by ld.lld
  if(CONFIG_LLVM_USE_LLD AND CONFIG_CPU_CORTEX_M55)
    set(LLVM_LINK_LIB "-lc -lm -lclang_rt.builtins")
  else()
    set(LLVM_LINK_LIB "")
  endif()
  zephyr_ld_options(
    ${LLVM_LINK_LIB}
  )
  if(CONFIG_LINKER_ORPHAN_SECTION_WARN)
    zephyr_ld_options(
      ${LINKERFLAGPREFIX},--orphan-handling=warn
    )
  elseif(CONFIG_LINKER_ORPHAN_SECTION_ERROR)
    zephyr_ld_options(
      ${LINKERFLAGPREFIX},--orphan-handling=error
    )
  endif()

endmacro()
