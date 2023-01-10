cmake_minimum_required(VERSION 3.4.1)

add_library(smawatchface SHARED
        watch_face.c
        watch_face_builder.c)

# Include libraries needed for hello-jni lib
target_link_libraries(smawatchface)
