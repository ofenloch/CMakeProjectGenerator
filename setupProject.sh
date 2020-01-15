 #!/bin/bash

PROJECT_NAME=coolcpp
PROJECT_ROOT=~/tmp/cpp_project

INIT_GIT_REPO=false

DEBUG=true

function createDirectoryStructure {
  /bin/mkdir -p ${PROJECT_ROOT}
  /bin/mkdir -p ${PROJECT_ROOT}/bin/source
  /bin/mkdir -p ${PROJECT_ROOT}/bin/include
  /bin/mkdir -p ${PROJECT_ROOT}/lib/source
  /bin/mkdir -p ${PROJECT_ROOT}/lib/include
  /bin/mkdir -p ${PROJECT_ROOT}/test/source
  /bin/mkdir -p ${PROJECT_ROOT}/test/include
  /bin/mkdir -p ${PROJECT_ROOT}/doc
  /bin/mkdir -p ${PROJECT_ROOT}/data
}

function generateTopLevelCMakeLists {
  # create the files first lines here to get the variables right
  /bin/cat <<EOF >${PROJECT_ROOT}/CMakeLists.txt
# CMakeLists.txt: top level CMakeLists.txt for project ${PROJECT_NAME}

# set minimum CMake version
cmake_minimum_required(VERSION 3.13)

# This is your project statement. You should always list languages;
# Listing the version is nice here since it sets lots of useful variables
project(${PROJECT_NAME} VERSION 0.1 LANGUAGES CXX)

# set the project's root folder
set(PROJECT_ROOT ${PROJECT_ROOT})
set(PROJECT_NAME ${PROJECT_NAME})

# set C++ standard
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# set include directories
include_directories("${PROJECT_ROOT}/bin/include"
  "${PROJECT_ROOT}/lib/include"
  "${PROJECT_ROOT}/test/include"
)

add_subdirectory(${PROJECT_ROOT}/bin)
add_subdirectory(${PROJECT_ROOT}/lib)
add_subdirectory(${PROJECT_ROOT}/test)

# add the executable
add_executable(${PROJECT_NAME} ${PROJECT_ROOT}/bin/source/main.cpp)

# add test executable
add_executable(${PROJECT_NAME}Test ${PROJECT_ROOT}/test/source/main.cpp)

enable_testing()
add_test(NAME ${PROJECT_NAME}Test COMMAND MyExample)

EOF
  # now cat the template into the file
  /bin/cat ./templates/TopLevelCMakeLists.template >> ${PROJECT_ROOT}/CMakeLists.txt
} # function generateTopLevelCMakeLists

function generateSubLevelCMakeLists {
  local subdir=${1}
  local filename=${PROJECT_ROOT}/${subdir}/CMakeLists.txt
  /bin/cat << EOF >${filename}
# CMakeLists.txt: CMakeLists.txt for ${subdir} of project ${PROJECT_NAME}

EOF
} # function generateSubLevelCMakeLists


if [ "${DEBUG}" == "true" ] ; then
  /bin/rm -rf ${PROJECT_ROOT}
fi

createDirectoryStructure

generateTopLevelCMakeLists

generateSubLevelCMakeLists bin

generateSubLevelCMakeLists lib

generateSubLevelCMakeLists test

echo "# Project ${PROJECT_NAME}" > ${PROJECT_ROOT}/README.md

/bin/cp -pvf templates/main.cpp.template ${PROJECT_ROOT}/bin/source/main.cpp
/bin/cp -pvf templates/main.h.template ${PROJECT_ROOT}/bin/include/main.h

/bin/cp -pvf templates/main.cpp.template ${PROJECT_ROOT}/test/source/main.cpp
/bin/cp -pvf templates/main.h.template ${PROJECT_ROOT}/test/include/main.h

if [ "${INIT_GIT_REPO}" == "true" ] ; then
  echo "intializing Git repository in directory  ${PROJECT_ROOT} ..."
  cd ${PROJECT_ROOT}
  git init
  git add .
  git commit -a -m "inital check in of project '${PROJECT_NAME}'"
fi