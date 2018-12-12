# Generated by CMake 2.8.10.2

IF("${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION}" LESS 2.5)
   MESSAGE(FATAL_ERROR "CMake >= 2.6.0 required")
ENDIF("${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION}" LESS 2.5)
CMAKE_POLICY(PUSH)
CMAKE_POLICY(VERSION 2.6)
#----------------------------------------------------------------
# Generated CMake target import file.
#----------------------------------------------------------------

# Commands may need to know the format version.
SET(CMAKE_IMPORT_FILE_VERSION 1)

# Create imported target zlib
ADD_LIBRARY(zlib STATIC IMPORTED)

# Create imported target libtiff
ADD_LIBRARY(libtiff STATIC IMPORTED)

# Create imported target libjpeg
ADD_LIBRARY(libjpeg STATIC IMPORTED)

# Create imported target libjasper
ADD_LIBRARY(libjasper STATIC IMPORTED)

# Create imported target libpng
ADD_LIBRARY(libpng STATIC IMPORTED)

# Create imported target IlmImf
ADD_LIBRARY(IlmImf STATIC IMPORTED)

# Create imported target opencv_core
ADD_LIBRARY(opencv_core STATIC IMPORTED)

# Create imported target opencv_flann
ADD_LIBRARY(opencv_flann STATIC IMPORTED)

# Create imported target opencv_imgproc
ADD_LIBRARY(opencv_imgproc STATIC IMPORTED)

# Create imported target opencv_highgui
ADD_LIBRARY(opencv_highgui STATIC IMPORTED)

# Create imported target opencv_features2d
ADD_LIBRARY(opencv_features2d STATIC IMPORTED)

# Create imported target opencv_calib3d
ADD_LIBRARY(opencv_calib3d STATIC IMPORTED)

# Create imported target opencv_ml
ADD_LIBRARY(opencv_ml STATIC IMPORTED)

# Create imported target opencv_video
ADD_LIBRARY(opencv_video STATIC IMPORTED)

# Create imported target opencv_legacy
ADD_LIBRARY(opencv_legacy STATIC IMPORTED)

# Create imported target opencv_objdetect
ADD_LIBRARY(opencv_objdetect STATIC IMPORTED)

# Create imported target opencv_photo
ADD_LIBRARY(opencv_photo STATIC IMPORTED)

# Create imported target opencv_gpu
ADD_LIBRARY(opencv_gpu STATIC IMPORTED)

# Create imported target opencv_ocl
ADD_LIBRARY(opencv_ocl STATIC IMPORTED)

# Create imported target opencv_nonfree
ADD_LIBRARY(opencv_nonfree STATIC IMPORTED)

# Create imported target opencv_contrib
ADD_LIBRARY(opencv_contrib STATIC IMPORTED)

# Create imported target opencv_stitching
ADD_LIBRARY(opencv_stitching STATIC IMPORTED)

# Create imported target opencv_superres
ADD_LIBRARY(opencv_superres STATIC IMPORTED)

# Create imported target opencv_ts
ADD_LIBRARY(opencv_ts STATIC IMPORTED)

# Create imported target opencv_videostab
ADD_LIBRARY(opencv_videostab STATIC IMPORTED)

# Load information for each installed configuration.
GET_FILENAME_COMPONENT(_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)
FILE(GLOB CONFIG_FILES "${_DIR}/OpenCVModules-*.cmake")
FOREACH(f ${CONFIG_FILES})
  INCLUDE(${f})
ENDFOREACH(f)

# Commands beyond this point should not need to know the version.
SET(CMAKE_IMPORT_FILE_VERSION)
CMAKE_POLICY(POP)