cmake_minimum_required(VERSION 3.16)
project(TuxPaintWeb)

# Set Emscripten toolchain
set(CMAKE_TOOLCHAIN_FILE $ENV{EMSDK}/upstream/emscripten/cmake/Modules/Platform/Emscripten.cmake)

# Set C standard
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Emscripten specific settings
set(CMAKE_EXECUTABLE_SUFFIX ".html")

# Set source files for simplified Tux Paint WebAssembly
set(TUXPAINT_SOURCES
    tuxpaint-0.9.35/src/tuxpaint_wasm.c
)

# Create executable
add_executable(tuxpaint ${TUXPAINT_SOURCES})

# Include directories
target_include_directories(tuxpaint PRIVATE
    tuxpaint-0.9.35/src
)

# Emscripten specific linker flags
set_target_properties(tuxpaint PROPERTIES
    LINK_FLAGS "-s USE_SDL=2 -s USE_SDL_IMAGE=2 -s USE_SDL_TTF=2 -s USE_SDL_MIXER=2 -s ALLOW_MEMORY_GROWTH=1 -s EXPORTED_RUNTIME_METHODS=['ccall','cwrap'] -s EXPORTED_FUNCTIONS=['_main','_tuxpaint_init','_tuxpaint_set_color','_tuxpaint_clear_canvas','_tuxpaint_set_brush_size'] -s ENVIRONMENT=web -s FULL_ES2=1 -s FULL_ES3=1 -s USE_WEBGL2=1 -s MIN_WEBGL_VERSION=2 -s SUPPORT_ERRNO=1 -s SUPPORT_LONGJMP=1 -s SUPPORT_C_EXCEPTIONS=1 -s ASSERTIONS=1 -s SAFE_HEAP=1 -s STACK_OVERFLOW_CHECK=1 -s INITIAL_MEMORY=33554432 -s MAXIMUM_MEMORY=268435456 -s ALLOW_TABLE_GROWTH=1 -s MODULARIZE=1 -s EXPORT_NAME='TuxPaint'"
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/web
)

# Compiler flags
target_compile_options(tuxpaint PRIVATE
    -std=c99
    -O2
) 