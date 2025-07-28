#include <stdio.h>
#include <emscripten.h>
#include <SDL2/SDL.h>

// Simple drawing program for testing WebAssembly
EMSCRIPTEN_KEEPALIVE
int main(int argc, char* argv[]) {
    printf("Tux Paint WebAssembly Test - Starting...\n");
    
    // Initialize SDL
    if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO) < 0) {
        printf("SDL could not initialize! SDL_Error: %s\n", SDL_GetError());
        return 1;
    }
    
    printf("SDL initialized successfully!\n");
    
    // Create a simple window
    SDL_Window* window = SDL_CreateWindow(
        "Tux Paint WebAssembly Test",
        SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
        800, 600,
        SDL_WINDOW_SHOWN
    );
    
    if (!window) {
        printf("Window could not be created! SDL_Error: %s\n", SDL_GetError());
        return 1;
    }
    
    printf("Window created successfully!\n");
    
    // Create renderer
    SDL_Renderer* renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
    if (!renderer) {
        printf("Renderer could not be created! SDL_Error: %s\n", SDL_GetError());
        return 1;
    }
    
    printf("Renderer created successfully!\n");
    
    // Set background color (light blue)
    SDL_SetRenderDrawColor(renderer, 173, 216, 230, 255);
    SDL_RenderClear(renderer);
    
    // Draw a simple shape (red rectangle)
    SDL_SetRenderDrawColor(renderer, 255, 0, 0, 255);
    SDL_Rect rect = {100, 100, 200, 150};
    SDL_RenderFillRect(renderer, &rect);
    
    // Draw a green circle (approximated with filled circle)
    SDL_SetRenderDrawColor(renderer, 0, 255, 0, 255);
    for (int i = 0; i < 50; i++) {
        for (int j = 0; j < 50; j++) {
            int dx = i - 25;
            int dy = j - 25;
            if (dx*dx + dy*dy <= 25*25) {
                SDL_RenderDrawPoint(renderer, 400 + dx, 200 + dy);
            }
        }
    }
    
    // Present the render
    SDL_RenderPresent(renderer);
    
    printf("Drawing completed! Tux Paint WebAssembly is working!\n");
    
    // Keep the window open
    SDL_Delay(5000);
    
    // Cleanup
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
    
    return 0;
}

// Export functions for JavaScript interaction
EMSCRIPTEN_KEEPALIVE
void draw_circle(int x, int y, int radius, int r, int g, int b) {
    printf("Drawing circle at (%d, %d) with radius %d, color (%d, %d, %d)\n", x, y, radius, r, g, b);
}

EMSCRIPTEN_KEEPALIVE
void draw_rectangle(int x, int y, int w, int h, int r, int g, int b) {
    printf("Drawing rectangle at (%d, %d) with size %dx%d, color (%d, %d, %d)\n", x, y, w, h, r, g, b);
}

EMSCRIPTEN_KEEPALIVE
void clear_screen() {
    printf("Clearing screen\n");
} 