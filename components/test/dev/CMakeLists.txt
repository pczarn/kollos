CMAKE_MINIMUM_REQUIRED(VERSION 3.0.2)

project(dev_tests C CXX)

set(LUA_Sources
    "json.lua"
    "simple3.lua"
    "simple_test2.lua"
    "simple_test.lua"
    )
source_group("lua" FILES ${LUA_Sources})

set(LUA_Outputs "")
foreach(LuaFile ${LUA_Sources})
  add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${LuaFile}
    COMMAND ${CMAKE_COMMAND}
    ARGS -E copy_if_different
      ${CMAKE_CURRENT_SOURCE_DIR}/${LuaFile}
      ${CMAKE_CURRENT_BINARY_DIR}/${LuaFile}
  )
  list(APPEND LUA_Outputs ${CMAKE_CURRENT_BINARY_DIR}/${LuaFile})
endforeach()

add_custom_target(
  copy_dev_tests_lua ALL
  DEPENDS ${LUA_Outputs}
  COMMENT "Copying LUA files"
  VERBATIM
)

# vim: expandtab shiftwidth=4:
