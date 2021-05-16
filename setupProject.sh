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
PROJECT_ROOT=~/tmp/${PROJECT_NAME}

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

# create new class skeleton from template files
function createNewClass() {
  local className=${1}
  local classFileBaseName=${2}
  local classIncludeGuard=${3}
  local classSubDirectory=${4}
  
  /bin/mkdir -p ${PROJECT_ROOT}/${classSubDirectory}/include
  /bin/mkdir -p ${PROJECT_ROOT}/${classSubDirectory}/source

  # replace "CNewClass" by ${className}
  /usr/bin/echo "s/CNewClass/${className}/g" > newClass.sed
  # replace "new_class" by ${classFileBaseName}
  /usr/bin/echo "s/new_class/${classFileBaseName}/g" >> newClass.sed
  # replace "_NEW_CLASS_H_" by ${classIncludeGuard}
  /usr/bin/echo "s/_NEW_CLASS_H_/${classIncludeGuard}/g" >> newClass.sed
  
  /usr/bin/echo "creating source file \"${PROJECT_ROOT}/${classSubDirectory}/source/${classFileBaseName}.cpp\" ..."
  /usr/bin/sed -f newClass.sed templates/new_class.cpp > ${PROJECT_ROOT}/${classSubDirectory}/source/${classFileBaseName}.cpp
  /usr/bin/echo "creating header file \"${PROJECT_ROOT}/${classSubDirectory}/include/${classFileBaseName}.h\" ..."
  /usr/bin/sed -f newClass.sed templates/new_class.h > ${PROJECT_ROOT}/${classSubDirectory}/include/${classFileBaseName}.h

} # function createNewClass()


function generateTopLevelCMakeLists {
  echo "s|\${PROJECT_NAME}|${PROJECT_NAME}|g" > ./toplevelCMakeLists.sed
  echo "s|\${PROJECT_ROOT}|${PROJECT_ROOT}|g" >> ./toplevelCMakeLists.sed
  /usr/bin/sed -f ./toplevelCMakeLists.sed ./templates/CMakeLists.txt.toplevel > ${PROJECT_ROOT}/CMakeLists.txt
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

# createNewClass className classFileBaseName classIncludeGuard classSubDirectory
createNewClass CAbstractBaseHello abstract_base_hello _ABSTRACT_BASE_HELLO_H_ greeter 

echo "# Project ${PROJECT_NAME}" > ${PROJECT_ROOT}/README.md
echo "Project ${PROJECT_NAME} was automatigically created by ${0} at $(date "+%Y-%m-%d--%H-%M-%S")" > ${PROJECT_ROOT}/README.md

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
  echo "build/" > .gitignore
  echo ".cache/" >> .gitignore
  git init
  git add .
  git commit -a -m "inital commit of project '${PROJECT_NAME}'"
fi
