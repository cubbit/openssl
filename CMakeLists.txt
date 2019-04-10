cmake_minimum_required(VERSION 3.2)

# Project settings
set(VERSION 1.0.0) 
set(DESCRIPTION "OpenSSL cmake fork")
project(openssl)

# includes
include(ExternalProject)
include(GNUInstallDirs)

# Options
set(SYSTEM_OPENSSL OFF CACHE STRING "Use system-provided openssl libraries")

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")

# Find packages
find_package(Git REQUIRED)
find_package(PythonInterp 3 REQUIRED)
find_package(Perl 3 REQUIRED)

find_program(MAKE_PROGRAM make)

if(UNIX)
    set(OPENSSL_TARGET "linux-x86_64")
endif()

set(BUILD_ENV_TOOL ${PYTHON_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/scripts/build.py ${CMAKE_CURRENT_BINARY_DIR}/openssl/src/openssl)

if(NOT CMAKE_INSTALL_PREFIX)
    set(CMAKE_INSTALL_PREFIX ${CMAKE_CURRENT_BINARY_DIR}/openssl)
endif()

if(NOT OPENSSL_BRANCH)
    set(OPENSSL_BRANCH OpenSSL_1_0_2-stable)
endif()

# Configure step
set(CONFIGURE_OPENSSL_PARAMS "--prefix=${CMAKE_INSTALL_PREFIX} --openssldir=${CMAKE_INSTALL_PREFIX} ${OPENSSL_TARGET}")
set(CONFIGURE_OPENSSL_MODULES no-shared no-srp no-psk) # no-tests
set(COMMAND_CONFIGURE ${BUILD_ENV_TOOL} "./Configure ${CONFIGURE_OPENSSL_PARAMS} ${CONFIGURE_OPENSSL_MODULES}")

# Build step
set(COMMAND_BUILD ${BUILD_ENV_TOOL} make)

# Install step
if (OPENSSL_INSTALL_MAN)
    set(INSTALL_OPENSSL "install")
else()
    set(INSTALL_OPENSSL "install_sw")
endif()

set(COMMAND_INSTALL ${BUILD_ENV_TOOL} make ${INSTALL_OPENSSL})

ExternalProject_Add(openssl
    PREFIX openssl
    GIT_REPOSITORY https://github.com/openssl/openssl
    GIT_TAG ${OPENSSL_BRANCH}
    CONFIGURE_COMMAND ${COMMAND_CONFIGURE}
    BUILD_COMMAND ${COMMAND_BUILD}
    INSTALL_COMMAND ${COMMAND_INSTALL}
    UPDATE_COMMAND ""
)
