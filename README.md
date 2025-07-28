# Tux Paint WebAssembly

This project converts Tux Paint, the award-winning drawing program for children, into a native web application using WebAssembly and Emscripten.

## Overview

Tux Paint is a free, award-winning drawing program originally created for children ages 3 to 12, but enjoyed by all! This project makes it available as a web application that can run in any modern browser without installation.

## Features

- **Full Tux Paint functionality** - All drawing tools, stamps, magic effects, and sounds
- **Cross-platform** - Runs on any device with a modern web browser
- **No installation required** - Just open in a browser
- **Offline capable** - Can work without internet connection after initial load
- **Touch support** - Works on tablets and touch devices
- **Responsive design** - Adapts to different screen sizes

## Technical Details

- **Language**: C (original) → WebAssembly (compiled)
- **Graphics**: SDL2 → Emscripten SDL2 port
- **Audio**: SDL2_mixer → Emscripten audio system
- **File I/O**: Virtual filesystem in browser
- **Build System**: CMake + Emscripten

## Prerequisites

- Emscripten SDK (already installed)
- CMake 3.20+
- Git
- Modern web browser with WebAssembly support

## Building

1. **Setup Emscripten Environment**:
   ```bash
   source emsdk/emsdk_env.sh
   ```

2. **Download Tux Paint Source**:
   ```bash
   ./scripts/download_tuxpaint.sh
   ```

3. **Build WebAssembly Version**:
   ```bash
   ./scripts/build_wasm.sh
   ```

4. **Serve Locally**:
   ```bash
   python3 -m http.server 8000
   ```

5. **Open in Browser**:
   Navigate to `http://localhost:8000`

## Project Structure

```
MKPS-Tux-Paint/
├── src/                    # Source code
│   └── tuxpaint/          # Tux Paint source (downloaded)
├── build/                 # Build artifacts
├── emsdk/                 # Emscripten SDK
├── web/                   # Web interface files
├── scripts/               # Build and utility scripts
└── docs/                  # Documentation
```

## Deployment

### Free Hosting Options

1. **GitHub Pages** - Free static hosting
2. **Netlify** - Free tier with custom domains
3. **Vercel** - Free tier with automatic deployments
4. **Firebase Hosting** - Google's free hosting service

### Self-Hosting

The web app can be hosted on any web server that supports static files.

## Browser Compatibility

- Chrome 57+
- Firefox 52+
- Safari 11+
- Edge 79+

## Development

### Adding Features

1. Modify Tux Paint source in `src/tuxpaint/`
2. Rebuild with `./scripts/build_wasm.sh`
3. Test in browser

### Customization

- Modify `web/index.html` for UI changes
- Edit `web/style.css` for styling
- Update `web/app.js` for JavaScript integration

## License

Tux Paint is licensed under the GPL v2. This WebAssembly port maintains the same license.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## Troubleshooting

### Common Issues

1. **Emscripten not found**: Run `source emsdk/emsdk_env.sh`
2. **Build fails**: Check that all dependencies are installed
3. **Audio not working**: Ensure browser supports Web Audio API
4. **Performance issues**: Try different optimization levels

### Getting Help

- Check the [Emscripten documentation](https://emscripten.org/)
- Review [Tux Paint documentation](https://tuxpaint.org/)
- Open an issue on this repository

## Acknowledgments

- Tux Paint development team for the original software
- Emscripten team for the WebAssembly toolchain
- SDL2 team for the graphics library 