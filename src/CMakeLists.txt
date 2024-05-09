list(APPEND DIR_SOURCES
  gfx
  interrupt
  main
  ram
  rom_header
  test_banks
  utility
)

foreach (SRC ${DIR_SOURCES})
list(APPEND _SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/${SRC}.s.z80)
endforeach()
set(SOURCES ${SOURCES} ${_SOURCES} PARENT_SCOPE)
