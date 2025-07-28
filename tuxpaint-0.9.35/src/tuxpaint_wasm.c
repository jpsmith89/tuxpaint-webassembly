/*
  tuxpaint_wasm.c

  Tux Paint WebAssembly - A simplified version for WebAssembly compilation

  Based on tuxpaint.c by various contributors
  https://tuxpaint.org/

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <emscripten.h>
#include "SDL2/SDL.h"
#include "SDL2/SDL_image.h"
#include "SDL2/SDL_ttf.h"
#include "SDL2/SDL_mixer.h"

// Simplified Tux Paint for WebAssembly
// This version focuses on basic drawing functionality

#define WINDOW_WIDTH 800
#define WINDOW_HEIGHT 600
#define CANVAS_WIDTH 640
#define CANVAS_HEIGHT 480

typedef struct {
    SDL_Window *window;
    SDL_Renderer *renderer;
    SDL_Surface *canvas;
    SDL_Texture *canvas_texture;
    int drawing;
    int last_x, last_y;
    SDL_Color current_color;
    int brush_size;
} TuxPaintState;

static TuxPaintState *state = NULL;

// Initialize Tux Paint
EMSCRIPTEN_KEEPALIVE
int tuxpaint_init() {
    printf("🎨 Initializing Tux Paint WebAssembly...\n");
    
    // Initialize SDL
    if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO) < 0) {
        printf("❌ SDL initialization failed: %s\n", SDL_GetError());
        return 0;
    }
    
    // Initialize SDL_image
    if (!(IMG_Init(IMG_INIT_PNG) & IMG_INIT_PNG)) {
        printf("❌ SDL_image initialization failed: %s\n", IMG_GetError());
        return 0;
    }
    
    // Initialize SDL_ttf
    if (TTF_Init() < 0) {
        printf("❌ SDL_ttf initialization failed: %s\n", TTF_GetError());
        return 0;
    }
    
    // Initialize SDL_mixer
    if (Mix_OpenAudio(44100, MIX_DEFAULT_FORMAT, 2, 2048) < 0) {
        printf("❌ SDL_mixer initialization failed: %s\n", Mix_GetError());
        return 0;
    }
    
    // Create window
    state = malloc(sizeof(TuxPaintState));
    if (!state) {
        printf("❌ Memory allocation failed\n");
        return 0;
    }
    
    state->window = SDL_CreateWindow("Tux Paint WebAssembly", 
                                   SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
                                   WINDOW_WIDTH, WINDOW_HEIGHT, 
                                   SDL_WINDOW_SHOWN);
    if (!state->window) {
        printf("❌ Window creation failed: %s\n", SDL_GetError());
        return 0;
    }
    
    // Create renderer
    state->renderer = SDL_CreateRenderer(state->window, -1, 
                                       SDL_RENDERER_ACCELERATED);
    if (!state->renderer) {
        printf("❌ Renderer creation failed: %s\n", SDL_GetError());
        return 0;
    }
    
    // Create canvas
    state->canvas = SDL_CreateRGBSurface(0, CANVAS_WIDTH, CANVAS_HEIGHT, 32,
                                        0x00FF0000, 0x0000FF00, 0x000000FF, 0xFF000000);
    if (!state->canvas) {
        printf("❌ Canvas creation failed: %s\n", SDL_GetError());
        return 0;
    }
    
    // Create canvas texture
    state->canvas_texture = SDL_CreateTexture(state->renderer, 
                                            SDL_PIXELFORMAT_ARGB8888,
                                            SDL_TEXTUREACCESS_STREAMING,
                                            CANVAS_WIDTH, CANVAS_HEIGHT);
    if (!state->canvas_texture) {
        printf("❌ Canvas texture creation failed: %s\n", SDL_GetError());
        return 0;
    }
    
    // Initialize state
    state->drawing = 0;
    state->last_x = 0;
    state->last_y = 0;
    state->current_color.r = 0;
    state->current_color.g = 0;
    state->current_color.b = 0;
    state->current_color.a = 255;
    state->brush_size = 3;
    
    // Clear canvas to white
    SDL_FillRect(state->canvas, NULL, SDL_MapRGB(state->canvas->format, 255, 255, 255));
    
    printf("✅ Tux Paint WebAssembly initialized successfully!\n");
    return 1;
}

// Main loop
EMSCRIPTEN_KEEPALIVE
void tuxpaint_main_loop() {
    SDL_Event event;
    
    while (SDL_PollEvent(&event)) {
        switch (event.type) {
            case SDL_QUIT:
                printf("👋 Tux Paint WebAssembly closing...\n");
                emscripten_cancel_main_loop();
                break;
                
            case SDL_MOUSEBUTTONDOWN:
                if (event.button.button == SDL_BUTTON_LEFT) {
                    state->drawing = 1;
                    state->last_x = event.button.x;
                    state->last_y = event.button.y;
                }
                break;
                
            case SDL_MOUSEBUTTONUP:
                if (event.button.button == SDL_BUTTON_LEFT) {
                    state->drawing = 0;
                }
                break;
                
            case SDL_MOUSEMOTION:
                if (state->drawing) {
                    // Draw line from last position to current position
                    int x = event.motion.x;
                    int y = event.motion.y;
                    
                    // Simple line drawing
                    int dx = abs(x - state->last_x);
                    int dy = abs(y - state->last_y);
                    int sx = state->last_x < x ? 1 : -1;
                    int sy = state->last_y < y ? 1 : -1;
                    int err = dx - dy;
                    
                    int current_x = state->last_x;
                    int current_y = state->last_y;
                    
                    while (1) {
                        // Draw pixel
                        if (current_x >= 0 && current_x < CANVAS_WIDTH && 
                            current_y >= 0 && current_y < CANVAS_HEIGHT) {
                            Uint32 pixel = SDL_MapRGB(state->canvas->format, 
                                                     state->current_color.r,
                                                     state->current_color.g,
                                                     state->current_color.b);
                            Uint32 *pixels = (Uint32*)state->canvas->pixels;
                            pixels[current_y * CANVAS_WIDTH + current_x] = pixel;
                        }
                        
                        if (current_x == x && current_y == y) break;
                        
                        int e2 = 2 * err;
                        if (e2 > -dy) {
                            err -= dy;
                            current_x += sx;
                        }
                        if (e2 < dx) {
                            err += dx;
                            current_y += sy;
                        }
                    }
                    
                    state->last_x = x;
                    state->last_y = y;
                }
                break;
        }
    }
    
    // Update canvas texture
    SDL_UpdateTexture(state->canvas_texture, NULL, state->canvas->pixels, state->canvas->pitch);
    
    // Clear screen
    SDL_SetRenderDrawColor(state->renderer, 200, 200, 200, 255);
    SDL_RenderClear(state->renderer);
    
    // Draw canvas
    SDL_RenderCopy(state->renderer, state->canvas_texture, NULL, NULL);
    
    // Present
    SDL_RenderPresent(state->renderer);
}

// Set drawing color
EMSCRIPTEN_KEEPALIVE
void tuxpaint_set_color(int r, int g, int b) {
    if (state) {
        state->current_color.r = r;
        state->current_color.g = g;
        state->current_color.b = b;
        printf("🎨 Color set to RGB(%d, %d, %d)\n", r, g, b);
    }
}

// Clear canvas
EMSCRIPTEN_KEEPALIVE
void tuxpaint_clear_canvas() {
    if (state && state->canvas) {
        SDL_FillRect(state->canvas, NULL, SDL_MapRGB(state->canvas->format, 255, 255, 255));
        printf("🧹 Canvas cleared\n");
    }
}

// Set brush size
EMSCRIPTEN_KEEPALIVE
void tuxpaint_set_brush_size(int size) {
    if (state) {
        state->brush_size = size;
        printf("🖌️ Brush size set to %d\n", size);
    }
}

// Main entry point
EMSCRIPTEN_KEEPALIVE
int main(int argc, char* argv[]) {
    printf("🎨 Tux Paint WebAssembly Starting...\n");
    
    if (!tuxpaint_init()) {
        printf("❌ Failed to initialize Tux Paint\n");
        return 1;
    }
    
    // Set up main loop
    emscripten_set_main_loop(tuxpaint_main_loop, 60, 1);
    
    return 0;
} 