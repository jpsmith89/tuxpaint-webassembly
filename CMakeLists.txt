cmake_minimum_required(VERSION 3.20)
project(TuxPaintWeb)

# Set C standard
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Emscripten specific settings
if(EMSCRIPTEN)
    # Enable WebAssembly
    set(CMAKE_EXECUTABLE_SUFFIX ".html")
    
    # Set compiler flags for WebAssembly
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -s USE_SDL=2 -s USE_SDL_MIXER=2 -s USE_SDL_IMAGE=2 -s USE_SDL_TTF=2")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -s ALLOW_MEMORY_GROWTH=1 -s EXPORTED_RUNTIME_METHODS=['ccall','cwrap']")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -s EXPORTED_FUNCTIONS=['_main'] -s FULL_ES2=1 -s FULL_ES3=1")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -s USE_WEBGL2=1 -s MIN_WEBGL_VERSION=2 -s SUPPORT_ERRNO=1")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -s SUPPORT_LONGJMP=1 -s SUPPORT_C_EXCEPTIONS=1 -s ASSERTIONS=1")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -s SAFE_HEAP=1 -s STACK_OVERFLOW_CHECK=1")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -s INITIAL_MEMORY=33554432 -s MAXIMUM_MEMORY=268435456")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -s ALLOW_TABLE_GROWTH=1 -s ENVIRONMENT=web")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -s MODULARIZE=1 -s EXPORT_NAME='TuxPaint'")
    
    # Linker flags
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -s USE_SDL=2 -s USE_SDL_MIXER=2 -s USE_SDL_IMAGE=2 -s USE_SDL_TTF=2")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -s ALLOW_MEMORY_GROWTH=1 -s EXPORTED_RUNTIME_METHODS=['ccall','cwrap']")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -s EXPORTED_FUNCTIONS=['_main'] -s FULL_ES2=1 -s FULL_ES3=1")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -s USE_WEBGL2=1 -s MIN_WEBGL_VERSION=2 -s SUPPORT_ERRNO=1")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -s SUPPORT_LONGJMP=1 -s SUPPORT_C_EXCEPTIONS=1 -s ASSERTIONS=1")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -s SAFE_HEAP=1 -s STACK_OVERFLOW_CHECK=1")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -s INITIAL_MEMORY=33554432 -s MAXIMUM_MEMORY=268435456")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -s ALLOW_TABLE_GROWTH=1 -s ENVIRONMENT=web")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -s MODULARIZE=1 -s EXPORT_NAME='TuxPaint'")
    
    # Preload data files
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} --preload-file src/tuxpaint/data@/data")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} --preload-file src/tuxpaint/stamps@/stamps")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} --preload-file src/tuxpaint/fonts@/fonts")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} --preload-file src/tuxpaint/sounds@/sounds")
    
    # Optimization flags
    set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -O2")
    set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -g -O0")
endif()

# Find required packages
find_package(SDL2 REQUIRED)
find_package(SDL2_mixer REQUIRED)
find_package(SDL2_image REQUIRED)
find_package(SDL2_ttf REQUIRED)

# Include directories
include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/src/tuxpaint/src
    ${CMAKE_CURRENT_SOURCE_DIR}/src/tuxpaint/src/include
    ${SDL2_INCLUDE_DIRS}
    ${SDL2_MIXER_INCLUDE_DIRS}
    ${SDL2_IMAGE_INCLUDE_DIRS}
    ${SDL2_TTF_INCLUDE_DIRS}
)

# Find all source files
file(GLOB_RECURSE TUXPAINT_SOURCES 
    "src/tuxpaint/src/*.c"
    "src/tuxpaint/src/*.cpp"
)

# Exclude platform-specific files
list(FILTER TUXPAINT_SOURCES EXCLUDE REGEX ".*win32.*")
list(FILTER TUXPAINT_SOURCES EXCLUDE REGEX ".*macosx.*")
list(FILTER TUXPAINT_SOURCES EXCLUDE REGEX ".*linux.*")
list(FILTER TUXPAINT_SOURCES EXCLUDE REGEX ".*android.*")

# Create executable
add_executable(tuxpaint ${TUXPAINT_SOURCES})

# Link libraries
target_link_libraries(tuxpaint
    ${SDL2_LIBRARIES}
    ${SDL2_MIXER_LIBRARIES}
    ${SDL2_IMAGE_LIBRARIES}
    ${SDL2_TTF_LIBRARIES}
)

# Set output directory
set_target_properties(tuxpaint PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/web
)

# Copy web interface files
configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/web/index.html
    ${CMAKE_CURRENT_SOURCE_DIR}/web/index.html
    COPYONLY
)

configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/web/style.css
    ${CMAKE_CURRENT_SOURCE_DIR}/web/style.css
    COPYONLY
)

configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/web/app.js
    ${CMAKE_CURRENT_SOURCE_DIR}/web/app.js
    COPYONLY
)

# Custom target to copy all web files
add_custom_target(copy_web_files ALL
    COMMAND ${CMAKE_COMMAND} -E copy_directory
    ${CMAKE_CURRENT_SOURCE_DIR}/web
    ${CMAKE_CURRENT_BINARY_DIR}/web
    COMMENT "Copying web interface files"
)

# Make tuxpaint depend on copy_web_files
add_dependencies(tuxpaint copy_web_files)

# Print configuration info
message(STATUS "Tux Paint WebAssembly Configuration:")
message(STATUS "  Source files: ${TUXPAINT_SOURCES}")
message(STATUS "  SDL2: ${SDL2_LIBRARIES}")
message(STATUS "  SDL2_mixer: ${SDL2_MIXER_LIBRARIES}")
message(STATUS "  SDL2_image: ${SDL2_IMAGE_LIBRARIES}")
message(STATUS "  SDL2_ttf: ${SDL2_TTF_LIBRARIES}")
message(STATUS "  Output directory: ${CMAKE_CURRENT_SOURCE_DIR}/web") 