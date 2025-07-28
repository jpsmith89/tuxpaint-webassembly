/**
 * Tux Paint Web - JavaScript Application
 * Handles WebAssembly integration and UI interactions
 */

const TuxPaintWeb = {
    // Application state
    state: {
        isLoaded: false,
        isFullscreen: false,
        currentTool: 'brush',
        tuxpaintInstance: null,
        canvas: null
    },

    // Initialize the application
    init() {
        this.setupEventListeners();
        this.loadTuxPaint();
    },

    // Setup event listeners
    setupEventListeners() {
        // Tool buttons
        document.querySelectorAll('.tool-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                this.selectTool(e.target.closest('.tool-btn').dataset.tool);
            });
        });

        // Action buttons
        document.getElementById('new-btn').addEventListener('click', () => this.newDrawing());
        document.getElementById('save-btn').addEventListener('click', () => this.saveDrawing());
        document.getElementById('open-btn').addEventListener('click', () => this.openDrawing());

        // Header controls
        document.getElementById('fullscreen-btn').addEventListener('click', () => this.toggleFullscreen());
        document.getElementById('help-btn').addEventListener('click', () => this.showHelp());

        // Modal controls
        document.getElementById('close-help').addEventListener('click', () => this.hideHelp());
        document.getElementById('help-modal').addEventListener('click', (e) => {
            if (e.target.id === 'help-modal') this.hideHelp();
        });

        // Keyboard shortcuts
        document.addEventListener('keydown', (e) => this.handleKeyboard(e));

        // Fullscreen change events
        document.addEventListener('fullscreenchange', () => this.handleFullscreenChange());
        document.addEventListener('webkitfullscreenchange', () => this.handleFullscreenChange());
        document.addEventListener('mozfullscreenchange', () => this.handleFullscreenChange());
        document.addEventListener('MSFullscreenChange', () => this.handleFullscreenChange());

        // Window resize
        window.addEventListener('resize', () => this.handleResize());
    },

    // Load Tux Paint WebAssembly module
    async loadTuxPaint() {
        try {
            this.updateProgress(10, 'Loading Tux Paint...');

            // Check if WebAssembly is supported
            if (!('WebAssembly' in window)) {
                throw new Error('WebAssembly is not supported in this browser');
            }

            this.updateProgress(20, 'Initializing WebAssembly...');

            // Load the Tux Paint WebAssembly module
            // Note: This assumes the compiled module is available as 'tuxpaint.js'
            const module = await this.loadModule('tuxpaint.js');
            
            this.updateProgress(50, 'Setting up canvas...');

            // Initialize the module
            this.state.tuxpaintInstance = module({
                canvas: document.getElementById('canvas-wrapper'),
                onRuntimeInitialized: () => {
                    this.updateProgress(80, 'Starting Tux Paint...');
                    this.initializeCanvas();
                }
            });

            this.updateProgress(90, 'Finalizing...');

            // Wait for initialization to complete
            await new Promise(resolve => {
                const checkReady = () => {
                    if (this.state.tuxpaintInstance && this.state.tuxpaintInstance.ready) {
                        resolve();
                    } else {
                        setTimeout(checkReady, 100);
                    }
                };
                checkReady();
            });

            this.updateProgress(100, 'Ready!');
            
            // Hide loading screen and show main app
            setTimeout(() => {
                this.showMainApp();
            }, 500);

        } catch (error) {
            console.error('Failed to load Tux Paint:', error);
            this.showError('Failed to load Tux Paint. Please refresh the page and try again.');
        }
    },

    // Load WebAssembly module
    async loadModule(modulePath) {
        return new Promise((resolve, reject) => {
            const script = document.createElement('script');
            script.src = modulePath;
            script.onload = () => {
                // The module should be available globally
                if (typeof TuxPaint !== 'undefined') {
                    resolve(TuxPaint);
                } else {
                    reject(new Error('TuxPaint module not found'));
                }
            };
            script.onerror = () => reject(new Error('Failed to load TuxPaint module'));
            document.head.appendChild(script);
        });
    },

    // Initialize canvas
    initializeCanvas() {
        try {
            // Get the canvas element from the WebAssembly module
            this.state.canvas = this.state.tuxpaintInstance.canvas;
            
            // Set up canvas event handlers
            this.setupCanvasEvents();
            
            // Start Tux Paint
            this.state.tuxpaintInstance._main();
            
            this.state.isLoaded = true;
            
        } catch (error) {
            console.error('Failed to initialize canvas:', error);
            this.showError('Failed to initialize drawing canvas.');
        }
    },

    // Setup canvas event handlers
    setupCanvasEvents() {
        if (!this.state.canvas) return;

        // Handle canvas interactions
        this.state.canvas.addEventListener('click', (e) => {
            this.handleCanvasClick(e);
        });

        this.state.canvas.addEventListener('mousedown', (e) => {
            this.handleCanvasMouseDown(e);
        });

        this.state.canvas.addEventListener('mousemove', (e) => {
            this.handleCanvasMouseMove(e);
        });

        this.state.canvas.addEventListener('mouseup', (e) => {
            this.handleCanvasMouseUp(e);
        });

        // Touch events for mobile
        this.state.canvas.addEventListener('touchstart', (e) => {
            e.preventDefault();
            this.handleCanvasTouchStart(e);
        });

        this.state.canvas.addEventListener('touchmove', (e) => {
            e.preventDefault();
            this.handleCanvasTouchMove(e);
        });

        this.state.canvas.addEventListener('touchend', (e) => {
            e.preventDefault();
            this.handleCanvasTouchEnd(e);
        });
    },

    // Handle canvas interactions
    handleCanvasClick(e) {
        if (!this.state.isLoaded) return;
        
        // Convert coordinates and send to Tux Paint
        const rect = this.state.canvas.getBoundingClientRect();
        const x = e.clientX - rect.left;
        const y = e.clientY - rect.top;
        
        this.sendMouseEvent('click', x, y);
    },

    handleCanvasMouseDown(e) {
        if (!this.state.isLoaded) return;
        
        const rect = this.state.canvas.getBoundingClientRect();
        const x = e.clientX - rect.left;
        const y = e.clientY - rect.top;
        
        this.sendMouseEvent('mousedown', x, y);
    },

    handleCanvasMouseMove(e) {
        if (!this.state.isLoaded) return;
        
        const rect = this.state.canvas.getBoundingClientRect();
        const x = e.clientX - rect.left;
        const y = e.clientY - rect.top;
        
        this.sendMouseEvent('mousemove', x, y);
    },

    handleCanvasMouseUp(e) {
        if (!this.state.isLoaded) return;
        
        const rect = this.state.canvas.getBoundingClientRect();
        const x = e.clientX - rect.left;
        const y = e.clientY - rect.top;
        
        this.sendMouseEvent('mouseup', x, y);
    },

    // Touch event handlers
    handleCanvasTouchStart(e) {
        if (!this.state.isLoaded) return;
        
        const touch = e.touches[0];
        const rect = this.state.canvas.getBoundingClientRect();
        const x = touch.clientX - rect.left;
        const y = touch.clientY - rect.top;
        
        this.sendMouseEvent('mousedown', x, y);
    },

    handleCanvasTouchMove(e) {
        if (!this.state.isLoaded) return;
        
        const touch = e.touches[0];
        const rect = this.state.canvas.getBoundingClientRect();
        const x = touch.clientX - rect.left;
        const y = touch.clientY - rect.top;
        
        this.sendMouseEvent('mousemove', x, y);
    },

    handleCanvasTouchEnd(e) {
        if (!this.state.isLoaded) return;
        
        const touch = e.changedTouches[0];
        const rect = this.state.canvas.getBoundingClientRect();
        const x = touch.clientX - rect.left;
        const y = touch.clientY - rect.top;
        
        this.sendMouseEvent('mouseup', x, y);
    },

    // Send mouse events to Tux Paint
    sendMouseEvent(type, x, y) {
        if (!this.state.tuxpaintInstance) return;

        try {
            // Convert coordinates to Tux Paint coordinate system
            const scaleX = this.state.canvas.width / this.state.canvas.offsetWidth;
            const scaleY = this.state.canvas.height / this.state.canvas.offsetHeight;
            
            const tuxX = Math.floor(x * scaleX);
            const tuxY = Math.floor(y * scaleY);

            // Send event to Tux Paint via WebAssembly
            this.state.tuxpaintInstance.ccall(
                'handle_mouse_event',
                'void',
                ['string', 'number', 'number'],
                [type, tuxX, tuxY]
            );
        } catch (error) {
            console.error('Failed to send mouse event:', error);
        }
    },

    // Tool selection
    selectTool(tool) {
        this.state.currentTool = tool;
        
        // Update UI
        document.querySelectorAll('.tool-btn').forEach(btn => {
            btn.classList.remove('active');
        });
        document.querySelector(`[data-tool="${tool}"]`).classList.add('active');
        
        // Send tool change to Tux Paint
        if (this.state.isLoaded && this.state.tuxpaintInstance) {
            try {
                this.state.tuxpaintInstance.ccall(
                    'set_tool',
                    'void',
                    ['string'],
                    [tool]
                );
            } catch (error) {
                console.error('Failed to set tool:', error);
            }
        }
    },

    // Action handlers
    newDrawing() {
        if (!this.state.isLoaded) return;
        
        if (confirm('Start a new drawing? Your current work will be lost.')) {
            try {
                this.state.tuxpaintInstance.ccall(
                    'new_drawing',
                    'void',
                    [],
                    []
                );
            } catch (error) {
                console.error('Failed to create new drawing:', error);
            }
        }
    },

    saveDrawing() {
        if (!this.state.isLoaded) return;
        
        try {
            // Get canvas data
            const canvas = this.state.canvas;
            const dataURL = canvas.toDataURL('image/png');
            
            // Create download link
            const link = document.createElement('a');
            link.download = `tuxpaint-drawing-${Date.now()}.png`;
            link.href = dataURL;
            link.click();
        } catch (error) {
            console.error('Failed to save drawing:', error);
            this.showError('Failed to save drawing.');
        }
    },

    openDrawing() {
        if (!this.state.isLoaded) return;
        
        const input = document.createElement('input');
        input.type = 'file';
        input.accept = 'image/*';
        input.onchange = (e) => {
            const file = e.target.files[0];
            if (file) {
                this.loadDrawing(file);
            }
        };
        input.click();
    },

    loadDrawing(file) {
        const reader = new FileReader();
        reader.onload = (e) => {
            try {
                const img = new Image();
                img.onload = () => {
                    // Load image into Tux Paint
                    if (this.state.tuxpaintInstance) {
                        this.state.tuxpaintInstance.ccall(
                            'load_image',
                            'void',
                            ['string'],
                            [e.target.result]
                        );
                    }
                };
                img.src = e.target.result;
            } catch (error) {
                console.error('Failed to load drawing:', error);
                this.showError('Failed to load drawing.');
            }
        };
        reader.readAsDataURL(file);
    },

    // Fullscreen handling
    toggleFullscreen() {
        if (!this.state.isFullscreen) {
            this.enterFullscreen();
        } else {
            this.exitFullscreen();
        }
    },

    enterFullscreen() {
        const app = document.getElementById('app');
        
        if (app.requestFullscreen) {
            app.requestFullscreen();
        } else if (app.webkitRequestFullscreen) {
            app.webkitRequestFullscreen();
        } else if (app.mozRequestFullScreen) {
            app.mozRequestFullScreen();
        } else if (app.msRequestFullscreen) {
            app.msRequestFullscreen();
        }
    },

    exitFullscreen() {
        if (document.exitFullscreen) {
            document.exitFullscreen();
        } else if (document.webkitExitFullscreen) {
            document.webkitExitFullscreen();
        } else if (document.mozCancelFullScreen) {
            document.mozCancelFullScreen();
        } else if (document.msExitFullscreen) {
            document.msExitFullscreen();
        }
    },

    handleFullscreenChange() {
        this.state.isFullscreen = !!(document.fullscreenElement || 
                                   document.webkitFullscreenElement || 
                                   document.mozFullScreenElement || 
                                   document.msFullscreenElement);
        
        document.getElementById('app').classList.toggle('fullscreen', this.state.isFullscreen);
    },

    // Help modal
    showHelp() {
        document.getElementById('help-modal').style.display = 'flex';
    },

    hideHelp() {
        document.getElementById('help-modal').style.display = 'none';
    },

    // Keyboard shortcuts
    handleKeyboard(e) {
        // Don't handle shortcuts in input fields
        if (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA') return;

        switch (e.key.toLowerCase()) {
            case 'b':
                this.selectTool('brush');
                break;
            case 's':
                this.selectTool('stamp');
                break;
            case 'h':
                this.selectTool('shape');
                break;
            case 't':
                this.selectTool('text');
                break;
            case 'm':
                this.selectTool('magic');
                break;
            case 'e':
                this.selectTool('eraser');
                break;
            case 'n':
                if (e.ctrlKey || e.metaKey) {
                    e.preventDefault();
                    this.newDrawing();
                }
                break;
            case 's':
                if (e.ctrlKey || e.metaKey) {
                    e.preventDefault();
                    this.saveDrawing();
                }
                break;
            case 'o':
                if (e.ctrlKey || e.metaKey) {
                    e.preventDefault();
                    this.openDrawing();
                }
                break;
            case 'f11':
                e.preventDefault();
                this.toggleFullscreen();
                break;
            case 'escape':
                if (this.state.isFullscreen) {
                    this.exitFullscreen();
                }
                this.hideHelp();
                break;
        }
    },

    // Window resize handling
    handleResize() {
        if (this.state.canvas && this.state.isLoaded) {
            // Resize canvas if needed
            this.resizeCanvas();
        }
    },

    resizeCanvas() {
        // Implementation depends on how Tux Paint handles resizing
        // This is a placeholder for canvas resizing logic
    },

    // Progress updates
    updateProgress(percent, message) {
        const progressFill = document.getElementById('progress-fill');
        const progressText = document.getElementById('progress-text');
        
        if (progressFill) progressFill.style.width = `${percent}%`;
        if (progressText) progressText.textContent = `${percent}%`;
        
        console.log(`Progress: ${percent}% - ${message}`);
    },

    // Show main application
    showMainApp() {
        document.getElementById('loading').style.display = 'none';
        document.getElementById('main-app').style.display = 'flex';
        document.getElementById('main-app').classList.add('fade-in');
    },

    // Error handling
    showError(message) {
        alert(`Error: ${message}`);
    }
};

// Export for global access
window.TuxPaintWeb = TuxPaintWeb; 