cmake_minimum_required(VERSION 3.17)
project(CLion_Programs)

set(CMAKE_CXX_STANDARD 14)

add_executable(CLion_Programs main.cpp)

# added -fopenmp
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -fopenmp")

set(SOURCE_FILES main.cpp)
add_executable(openmp_test_clion ${SOURCE_FILES})