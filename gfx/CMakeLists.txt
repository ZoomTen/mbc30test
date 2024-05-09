list(APPEND DIR_GFX
  font
  return_states
)

foreach(SRC ${DIR_GFX})
list(APPEND _GFX_FILES ${CMAKE_CURRENT_SOURCE_DIR}/${SRC}.png)
endforeach()
set(GFX_FILES ${GFX_FILES} ${_GFX_FILES} PARENT_SCOPE)