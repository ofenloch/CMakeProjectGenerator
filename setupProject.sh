 #!/bin/bash

if [ -n "${1}" ] ; then
    # there's an argument (the string's length is greater than zero)
    PROJECT_NAME=${1}
else
    # there was no argument given
    PROJECT_NAME=coolcpp
fi

echo "Setting up project ${PROJECT_NAME} ..."

PROJECT_ROOT=~/workspaces/cpp/${PROJECT_NAME}

echo "Project root is ${PROJECT_ROOT}"


CMAKE_SOURCE_DIR='${CMAKE_SOURCE_DIR}'


INIT_GIT_REPO=true

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
  /bin/mkdir -p ${PROJECT_ROOT}/.vscode
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
include_directories(
  "${CMAKE_SOURCE_DIR}/bin/include"
  "${CMAKE_SOURCE_DIR}/lib/include"
  "${CMAKE_SOURCE_DIR}/test/include"
)

# include the sub-projects in bin, lib and test
add_subdirectory(lib)
add_subdirectory(bin)
add_subdirectory(test)

# add the executable

# add_executable(${PROJECT_NAME} ${PROJECT_ROOT}/bin/source/main.cpp)

# add test executable
# add_executable(${PROJECT_NAME}Test ${PROJECT_ROOT}/test/source/main.cpp)

enable_testing()
add_test(NAME ${PROJECT_NAME}Test COMMAND MyExample)

EOF
  # now cat the template into the file
  /bin/cat ./templates/TopLevelCMakeLists.template >> ${PROJECT_ROOT}/CMakeLists.txt
} # function generateTopLevelCMakeLists

function generateSubLevelCMakeLists {
  # TODO: different version for lib
  local subdir=${1}
  local filename=${PROJECT_ROOT}/${subdir}/CMakeLists.txt
  if [ "${subdir}" == "lib" ] ; then
    /bin/cat << EOF >${filename}
# CMakeLists.txt: CMakeLists.txt for ${subdir} of project ${PROJECT_NAME}

# create a library called ${PROJECT_NAME}${subdir}
add_library( ${PROJECT_NAME}lib STATIC ${CMAKE_SOURCE_DIR}/${subdir}/source/mainlib.cpp)

EOF
  else
    /bin/cat << EOF >${filename}
# CMakeLists.txt: CMakeLists.txt for ${subdir} of project ${PROJECT_NAME}

add_executable(${PROJECT_NAME}${subdir} ${CMAKE_SOURCE_DIR}/${subdir}/source/main.cpp)

target_link_libraries(${PROJECT_NAME}${subdir} ${PROJECT_NAME}lib)

EOF
  fi
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

/bin/cp -pvf templates/main.lib.cpp.template ${PROJECT_ROOT}/lib/source/mainlib.cpp
/bin/cp -pvf templates/main.lib.h.template ${PROJECT_ROOT}/lib/include/mainlib.h

/bin/cp -pvf templates/launch.json.template ${PROJECT_ROOT}/.vscode/launch.json

/bin/cp -pvf templates/gitignore.template ${PROJECT_ROOT}/.gitignore

if [ "${INIT_GIT_REPO}" == "true" ] ; then
  echo "intializing Git repository in directory  ${PROJECT_ROOT} ..."
  cd ${PROJECT_ROOT}
  git init
  git add .
  git commit -a -m "inital commit of project '${PROJECT_NAME}'"
fi
