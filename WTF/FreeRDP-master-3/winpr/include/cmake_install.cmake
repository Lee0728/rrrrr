# Install script for directory: /Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include

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
  FILE(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/winpr" TYPE FILE FILES
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/asn1.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/bcrypt.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/cmdline.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/collections.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/config.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/credentials.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/credui.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/crt.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/crypto.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/dsparse.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/endian.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/environment.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/error.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/file.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/handle.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/heap.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/input.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/interlocked.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/io.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/library.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/memory.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/midl.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/ndr.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/nt.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/ntlm.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/path.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/pipe.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/platform.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/pool.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/print.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/registry.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/rpc.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/sam.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/schannel.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/security.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/spec.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/sspi.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/sspicli.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/stream.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/string.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/synch.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/sysinfo.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/tchar.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/thread.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/timezone.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/windows.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/winhttp.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/winpr.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/winsock.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/wlog.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/wtsapi.h"
    "/Users/lgxu/Pictures/yuanguangtest/FreeRDP-master-3/winpr/include/winpr/wtypes.h"
    )
ENDIF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "headers")

