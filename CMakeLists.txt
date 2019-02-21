#=============================================================================
#
# This is ARPA2CM, a collection of CMake modules for the ARPA2 project.
# The structure and top-level of this collection is derived from the
# KDE Extra CMake Modules.
#
#=============================================================================
#
# Copyright 2006-2013 Alex Neundorf <neundorf@kde.org>
# Copyright 2014-2015 Alex Merry <alex.merry@kde.org>
# Copyright 2017,2019 Adriaan de Groot <groot@kde.org>
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. The name of the author may not be used to endorse or promote products
#    derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
# OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
# NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#=============================================================================
#
# SPDX-License-Identifier: BSD-3-Clause
# License-Filename: LICENSES/BSD-3-Clause.neundorf.merry.degroot

cmake_minimum_required(VERSION 3.2 FATAL_ERROR)

set(VERSION "0.6")

cmake_policy(SET CMP0048 NEW)
project(ARPA2CM VERSION "${VERSION}" LANGUAGES NONE)

set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")

include(FeatureSummary)

set(SHARE_INSTALL_DIR share
    CACHE
    PATH
    "read-only architecture-independent data"
)

set(ARPA2CM_INSTALL_DIR           ${SHARE_INSTALL_DIR}/ARPA2CM)

set(CMAKECONFIG_INSTALL_DIR       ${ARPA2CM_INSTALL_DIR}/cmake/)
set(FIND_MODULES_INSTALL_DIR      ${ARPA2CM_INSTALL_DIR}/find-modules/)
set(MODULES_INSTALL_DIR           ${ARPA2CM_INSTALL_DIR}/modules/)
set(TOOLCHAIN_INSTALL_DIR         ${ARPA2CM_INSTALL_DIR}/toolchain/)

set(MAN_INSTALL_DIR ${SHARE_INSTALL_DIR}/man
    CACHE
    PATH
    "man pages"
)


#
# Install modules
#

file(GLOB installModuleFiles ${CMAKE_SOURCE_DIR}/modules/*[^~])
install(FILES ${installModuleFiles} DESTINATION ${MODULES_INSTALL_DIR})

file(GLOB installFindModuleFiles
    ${CMAKE_SOURCE_DIR}/find-modules/*.cmake
    ${CMAKE_SOURCE_DIR}/find-modules/*.py
    ${CMAKE_SOURCE_DIR}/find-modules/*.cpp
    ${CMAKE_SOURCE_DIR}/find-modules/*.c
)
install(FILES ${installFindModuleFiles} DESTINATION ${FIND_MODULES_INSTALL_DIR})

file(GLOB installToolchainModuleFiles ${CMAKE_SOURCE_DIR}/toolchain/*[^~])
install(FILES ${installToolchainModuleFiles} DESTINATION ${TOOLCHAIN_INSTALL_DIR})

install(FILES README.md CMakeLists.example.txt DESTINATION ${ARPA2CM_INSTALL_DIR}/doc)

include(CMakePackageConfigHelpers)

configure_package_config_file(
    ARPA2CMConfig.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/ARPA2CMConfig.cmake
    INSTALL_DESTINATION
        ${CMAKECONFIG_INSTALL_DIR}
    PATH_VARS
        CMAKECONFIG_INSTALL_DIR
        FIND_MODULES_INSTALL_DIR
        MODULES_INSTALL_DIR
        TOOLCHAIN_INSTALL_DIR
)

write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/ARPA2CMConfigVersion.cmake
    VERSION
        "${PROJECT_VERSION}"
    COMPATIBILITY
        AnyNewerVersion
)

install(
    FILES
        ${CMAKE_CURRENT_BINARY_DIR}/ARPA2CMConfig.cmake
        ${CMAKE_CURRENT_BINARY_DIR}/ARPA2CMConfigVersion.cmake
    DESTINATION
        ${CMAKECONFIG_INSTALL_DIR}
)


set(CPACK_PACKAGE_NAME arpa2-cmake-modules)
set(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})
set(CPACK_SYSTEM_NAME "generic")
set(CPACK_GENERATOR "TGZ")
set(CPACK_SET_DESTDIR FALSE)

include(CPack)

feature_summary(FATAL_ON_MISSING_REQUIRED_PACKAGES WHAT ALL)
