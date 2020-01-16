# Shell Script Setting Up a new C++ Project with CMake

This script and the associated templates create a basic CMake project. 

On my kubuntu 19.04 machine the project acutally builds and the program runs.

The directory layout looks like this (`tree -F projectname`):


    projectname/
    ├── .git/
    ├── .vscode/
    ├── bin/
    │   ├── CMakeLists.txt
    │   ├── include/
    │   │   └── main.h
    │   └── source/
    │       └── main.cpp
    ├── CMakeLists.txt
    ├── data/
    ├── doc/
    ├── lib/
    │   ├── CMakeLists.txt
    │   ├── include/
    │   │   └── mainlib.h
    │   └── source/
    │       └── mainlib.cpp
    ├── README.md
    └── test/
        ├── CMakeLists.txt
        ├── include/
        │   └── main.h
        └── source/
            └── main.cpp

* Directory **lib/** contains a CMakeLists.txt and all sources and headers needed to build the library libhello.a.

* Directory **bin/** contains CMakeLists.txt and all sources and headers needed to build the executable main-hello which uses libhello.a.

* Directory **test/** contains CMakeLists.txt and all sources and headers to build the tes program.

* Directory **doc/** contains stuff needed to build the documentation (by Doxygen).

* Directory **data/** contains all kind of data (e.g. logger config, translations, etc.) needed for various parts of out our project




The top level CMakeLists.txt sets up th global configuaraion and loads the sub-projects in directories bin/, lib/, and test/.

