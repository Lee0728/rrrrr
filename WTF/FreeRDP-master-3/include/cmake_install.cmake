# Install script for directory: /Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/include

# Set the install prefix
IF(NOT DEFINED CMAKE_INSTALL_PREFIX)
  SET(CMAKE_INSTALL_PREFIX "/usr/local")
ENDIF(NOT DEFINED CMAKE_INSTALL_PREFIX)
STRING(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
IF(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  IF(BUILD_TYPE)
    STRING(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  ELSE(BUILD_TYPE)
    SET(CMAKE_INSTALL_CONFIG_NAME "Release")
  ENDIF(BUILD_TYPE)
  MESSAGE(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
ENDIF(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)

# Set the component getting installed.
IF(NOT CMAKE_INSTALL_COMPONENT)
  IF(COMPONENT)
    MESSAGE(STATUS "Install component: \"${COMPONENT}\"")
    SET(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  ELSE(COMPONENT)
    SET(CMAKE_INSTALL_COMPONENT)
  ENDIF(COMPONENT)
ENDIF(NOT CMAKE_INSTALL_COMPONENT)

IF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "headers")
  FILE(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/freerdp" TYPE FILE FILES
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/include/freerdp/addin.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/include/freerdp/altsec.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/include/freerdp/api.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/include/freerdp/client.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/include/freerdp/constants.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/include/freerdp/dvc.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/include/freerdp/error.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/include/freerdp/event.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/include/freerdp/extension.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/include/freerdp/freerdp.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/include/freerdp/graphics.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/include/freerdp/input.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/include/freerdp/listener.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/include/freerdp/message.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/include/freerdp/peer.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/include/freerdp/pointer.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/include/freerdp/primary.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/include/freerdp/primitives.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/include/freerdp/rail.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/include/freerdp/scancode.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/include/freerdp/secondary.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/include/freerdp/settings.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/include/freerdp/svc.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/include/freerdp/types.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/include/freerdp/update.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/include/freerdp/window.h"
    )
ENDIF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "headers")

IF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "headers")
  FILE(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/freerdp" TYPE DIRECTORY FILES "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/include/freerdp/cache" FILES_MATCHING REGEX "/[^/]*\\.h$")
ENDIF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "headers")

IF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "headers")
  FILE(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/freerdp" TYPE DIRECTORY FILES "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/include/freerdp/codec" FILES_MATCHING REGEX "/[^/]*\\.h$")
ENDIF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "headers")

IF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "headers")
  FILE(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/freerdp" TYPE DIRECTORY FILES "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/include/freerdp/crypto" FILES_MATCHING REGEX "/[^/]*\\.h$")
ENDIF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "headers")

IF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "headers")
  FILE(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/freerdp" TYPE DIRECTORY FILES "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/include/freerdp/gdi" FILES_MATCHING REGEX "/[^/]*\\.h$")
ENDIF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "headers")

IF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "headers")
  FILE(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/freerdp" TYPE DIRECTORY FILES "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/include/freerdp/locale" FILES_MATCHING REGEX "/[^/]*\\.h$")
ENDIF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "headers")

IF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "headers")
  FILE(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/freerdp" TYPE DIRECTORY FILES "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/include/freerdp/rail" FILES_MATCHING REGEX "/[^/]*\\.h$")
ENDIF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "headers")

IF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "headers")
  FILE(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/freerdp" TYPE DIRECTORY FILES "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/include/freerdp/utils" FILES_MATCHING REGEX "/[^/]*\\.h$")
ENDIF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "headers")

IF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "headers")
  FILE(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/freerdp" TYPE DIRECTORY FILES "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/include/freerdp/client" FILES_MATCHING REGEX "/[^/]*\\.h$")
ENDIF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "headers")

IF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "headers")
  FILE(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/freerdp" TYPE DIRECTORY FILES "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/include/freerdp/server" FILES_MATCHING REGEX "/[^/]*\\.h$")
ENDIF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "headers")

IF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "headers")
  FILE(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/freerdp" TYPE DIRECTORY FILES "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/include/freerdp/channels" FILES_MATCHING REGEX "/[^/]*\\.h$")
ENDIF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "headers")

