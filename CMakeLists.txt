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

if(UNIX AND NOT APPLE)
    set(OPENSSL_TARGET "linux-x86_64")
elseif(UNIX)
    set(OPENSSL_TARGET "darwin64-x86_64-cc")
elseif(WIN32)
    set(OPENSSL_TARGET "VC-WIN64A")
    set(OPENSSL_WIN_DO "ms/do_win64a")
endif()

set(BUILD_ENV_TOOL ${PYTHON_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/scripts/build.py ${CMAKE_CURRENT_BINARY_DIR}/openssl/src/openssl)

if(NOT CMAKE_INSTALL_PREFIX)
    set(CMAKE_INSTALL_PREFIX ${CMAKE_CURRENT_BINARY_DIR}/openssl)
endif()

if(NOT OPENSSL_BRANCH)
    set(OPENSSL_BRANCH OpenSSL_1_0_2-stable)
endif()

if(APPLE)
    set(CONFIGURE_OPENSSL_PARAMS "${CONFIGURE_OPENSSL_PARAMS} enable-ec_nistp_64_gcc_128")
endif(APPLE)

# Install step
if (OPENSSL_INSTALL_MAN)
    set(INSTALL_OPENSSL "install")
else()
    set(INSTALL_OPENSSL "install_sw")
endif()

set(CONFIGURE_OPENSSL_PARAMS "--prefix=${CMAKE_INSTALL_PREFIX} --openssldir=${CMAKE_INSTALL_PREFIX} ${OPENSSL_TARGET}")

if(WIN32)
    set(CONFIGURE_OPENSSL_MODULES no-shared) # no-tests
    set(COMMAND_CONFIGURE ${BUILD_ENV_TOOL} "perl Configure ${CONFIGURE_OPENSSL_PARAMS} ${CONFIGURE_OPENSSL_MODULES}")
    set(COMMAND_BUILD ${BUILD_ENV_TOOL} call ${OPENSSL_WIN_DO} && ${BUILD_ENV_TOOL} nmake -f ms/nt.mak)
    set(COMMAND_INSTALL ${BUILD_ENV_TOOL} nmake -f ms/nt.mak install)
else()
    string(APPEND CONFIGURE_OPENSSL_PARAMS " -fPIC")
    set(CONFIGURE_OPENSSL_MODULES shared) # no-tests
    set(COMMAND_CONFIGURE ${BUILD_ENV_TOOL} "./Configure ${CONFIGURE_OPENSSL_PARAMS} ${CONFIGURE_OPENSSL_MODULES}")
    set(COMMAND_BUILD ${BUILD_ENV_TOOL} make)
    set(COMMAND_INSTALL ${BUILD_ENV_TOOL} make ${INSTALL_OPENSSL})
endif()

ExternalProject_Add(openssl
    PREFIX openssl
    GIT_REPOSITORY https://github.com/openssl/openssl
    GIT_TAG ${OPENSSL_BRANCH}
    GIT_CONFIG user.name=cmake user.email=cmake@cmake.c
    CONFIGURE_COMMAND ${COMMAND_CONFIGURE}
    BUILD_COMMAND ${COMMAND_BUILD}
    INSTALL_COMMAND ${COMMAND_INSTALL}
)
