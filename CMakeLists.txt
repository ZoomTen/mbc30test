cmake_minimum_required(VERSION 3.10)

project(
  "MBC3/MBC30 Test ROM"
  LANGUAGES NONE
)

set(PROJECT_VERSION 1.1)

set(MOTORZ80 motorz80)
set(XLINK xlink)
set(PYTHON python3)

set(ROM_FILE MBC3_Test.gbc)

set(SOURCES)
set(GFX_FILES)
add_subdirectory(src)
add_subdirectory(gfx)

set(THISDIR ${CMAKE_CURRENT_SOURCE_DIR})
set(GENDIR ${CMAKE_CURRENT_BINARY_DIR})
set(INCLUDE ${THISDIR}/include)

message(STATUS "Create graphics rules")
foreach(src ${GFX_FILES})
  # determine object file name
  get_filename_component(src_dirname ${src} DIRECTORY)
  get_filename_component(src_basename ${src} NAME_WE)
  set(gfx ${src_basename}.1bpp)

  message(STATUS "Create rule for ${gfx}")
  add_custom_command(
    OUTPUT
    ${GENDIR}/gfx/${gfx}
    COMMAND
      ${PYTHON} ${THISDIR}/utils/gfx.py
      1bpp
      ${src}
      ${GENDIR}/gfx/${gfx}
    DEPENDS
      ${src}
    VERBATIM
  )
  list(APPEND GFX_GEN ${GENDIR}/gfx/${gfx})
endforeach()

message(STATUS "Create ROM rules")
foreach(src ${SOURCES})
  # determine object file name
  get_filename_component(src_dirname ${src} DIRECTORY)
  get_filename_component(src_basename ${src} NAME_WE)

  string(SHA1 src_dirname_hash ${src_dirname})
  string(SUBSTRING ${src_dirname_hash} 0 8 src_dirname_hash_short)

  set(obj ${src_dirname_hash_short}_${src_basename})

  message(STATUS "Create rule for ${src_basename}.o")
  add_custom_command(
    OUTPUT
      ${CMAKE_CURRENT_BINARY_DIR}/src/${obj}.o
    COMMAND
      ${MOTORZ80}
      -i${INCLUDE} -i${THISDIR} -i${GENDIR}
      -d${CMAKE_CURRENT_BINARY_DIR}/src/${obj}.dep
      -mcg -ms1 -v
      -o${CMAKE_CURRENT_BINARY_DIR}/src/${obj}.o
      ${src}
    DEPFILE
      ${CMAKE_CURRENT_BINARY_DIR}/src/${obj}.dep
    VERBATIM
  )
  # ./ is needed because XLINK interprets / as
  # "Windows option prefix" rather than "root directory"
  list(APPEND OBJECTS ./src/${obj}.o)
endforeach()

add_custom_command(
  OUTPUT ${ROM_FILE} ${ROM_FILE}.sym
  COMMAND
    ${XLINK} -o${ROM_FILE} -m${ROM_FILE}.sym -fngb -cngb ${OBJECTS}
  DEPENDS
    ${GFX_GEN}
    ${OBJECTS}
  VERBATIM
)

add_custom_target(
  rom
  ALL
  DEPENDS
    ${ROM_FILE}
)
