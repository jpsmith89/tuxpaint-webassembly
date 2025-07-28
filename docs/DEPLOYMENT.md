# Tux Paint WebAssembly - Deployment Guide

This guide covers various options for deploying your Tux Paint WebAssembly application, including free hosting solutions.

## Prerequisites

Before deploying, ensure you have:

1. Successfully built the WebAssembly version using `./scripts/build_wasm.sh`
2. All files in the `web/` directory are ready
3. A modern web browser for testing

## Free Hosting Options

### 1. GitHub Pages (Recommended)

GitHub Pages is perfect for static web applications and is completely free.

#### Setup Steps:

1. **Create a GitHub Repository**:
   ```bash
   git init
   git add .
   git commit -m "Initial Tux Paint WebAssembly commit"
   ```

2. **Push to GitHub**:
   ```bash
   git remote add origin https://github.com/yourusername/tuxpaint-web.git
   git push -u origin main
   ```

3. **Enable GitHub Pages**:
   - Go to your repository on GitHub
   - Click "Settings" → "Pages"
   - Select "Deploy from a branch"
   - Choose "main" branch and "/docs" folder
   - Click "Save"

4. **Move Files to docs/ Directory**:
   ```bash
   mkdir docs
   cp -r web/* docs/
   git add docs/
   git commit -m "Add web files for GitHub Pages"
   git push
   ```

5. **Access Your App**:
   Your app will be available at: `https://yourusername.github.io/tuxpaint-web/`

### 2. Netlify

Netlify offers free hosting with custom domains and automatic deployments.

#### Setup Steps:

1. **Sign up for Netlify** at [netlify.com](https://netlify.com)

2. **Deploy from Git**:
   - Connect your GitHub repository
   - Set build command: (leave empty for static sites)
   - Set publish directory: `web`
   - Click "Deploy site"

3. **Custom Domain** (Optional):
   - Go to "Domain settings"
   - Add your custom domain
   - Follow DNS configuration instructions

### 3. Vercel

Vercel is great for static sites with excellent performance.

#### Setup Steps:

1. **Sign up for Vercel** at [vercel.com](https://vercel.com)

2. **Import Project**:
   - Connect your GitHub repository
   - Set framework preset to "Other"
   - Set root directory to `web`
   - Click "Deploy"

3. **Custom Domain**:
   - Go to "Settings" → "Domains"
   - Add your custom domain

### 4. Firebase Hosting

Google's Firebase offers reliable hosting with CDN.

#### Setup Steps:

1. **Install Firebase CLI**:
   ```bash
   npm install -g firebase-tools
   ```

2. **Login to Firebase**:
   ```bash
   firebase login
   ```

3. **Initialize Firebase**:
   ```bash
   firebase init hosting
   ```
   - Select your project
   - Set public directory to `web`
   - Configure as single-page app: No
   - Don't overwrite index.html

4. **Deploy**:
   ```bash
   firebase deploy
   ```

## Self-Hosting Options

### 1. Apache Web Server

1. **Install Apache** (if not already installed)
2. **Copy files**:
   ```bash
   sudo cp -r web/* /var/www/html/tuxpaint/
   ```
3. **Configure virtual host** (optional)
4. **Access at**: `http://your-server/tuxpaint/`

### 2. Nginx

1. **Install Nginx**:
   ```bash
   sudo apt-get install nginx  # Ubuntu/Debian
   ```

2. **Create configuration**:
   ```nginx
   server {
       listen 80;
       server_name your-domain.com;
       root /var/www/tuxpaint;
       index index.html;
       
       location / {
           try_files $uri $uri/ /index.html;
       }
       
       # Serve WebAssembly files with correct MIME type
       location ~* \.wasm$ {
           add_header Content-Type application/wasm;
       }
   }
   ```

3. **Deploy files**:
   ```bash
   sudo cp -r web/* /var/www/tuxpaint/
   sudo systemctl reload nginx
   ```

### 3. Docker

Create a `Dockerfile`:

```dockerfile
FROM nginx:alpine
COPY web/ /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

Build and run:
```bash
docker build -t tuxpaint-web .
docker run -p 80:80 tuxpaint-web
```

## Configuration

### WebAssembly MIME Types

Ensure your server serves WebAssembly files with the correct MIME type:

- **Apache**: Add to `.htaccess`:
  ```apache
  AddType application/wasm .wasm
  ```

- **Nginx**: Add to configuration:
  ```nginx
  location ~* \.wasm$ {
      add_header Content-Type application/wasm;
  }
  ```

### CORS Configuration

If you encounter CORS issues, add these headers:

```nginx
add_header Access-Control-Allow-Origin *;
add_header Access-Control-Allow-Methods "GET, POST, OPTIONS";
add_header Access-Control-Allow-Headers "DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range";
```

### HTTPS Configuration

For production, always use HTTPS:

1. **Let's Encrypt** (free SSL certificates):
   ```bash
   sudo apt-get install certbot
   sudo certbot --nginx -d your-domain.com
   ```

2. **Cloudflare** (free SSL proxy):
   - Sign up at cloudflare.com
   - Add your domain
   - Update DNS nameservers
   - Enable "Always Use HTTPS"

## Performance Optimization

### 1. Compression

Enable gzip compression:

**Apache** (`.htaccess`):
```apache
<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE text/plain
    AddOutputFilterByType DEFLATE text/html
    AddOutputFilterByType DEFLATE text/xml
    AddOutputFilterByType DEFLATE text/css
    AddOutputFilterByType DEFLATE application/xml
    AddOutputFilterByType DEFLATE application/xhtml+xml
    AddOutputFilterByType DEFLATE application/rss+xml
    AddOutputFilterByType DEFLATE application/javascript
    AddOutputFilterByType DEFLATE application/x-javascript
</IfModule>
```

**Nginx**:
```nginx
gzip on;
gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
```

### 2. Caching

Set appropriate cache headers:

```nginx
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|wasm)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

### 3. CDN

Consider using a CDN for better global performance:

- **Cloudflare** (free tier)
- **jsDelivr** (for static assets)
- **AWS CloudFront** (paid)

## Monitoring and Analytics

### 1. Google Analytics

Add to your `index.html`:

```html
<!-- Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=GA_MEASUREMENT_ID"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'GA_MEASUREMENT_ID');
</script>
```

### 2. Error Monitoring

Consider adding error monitoring:

```javascript
// Add to app.js
window.addEventListener('error', function(e) {
    // Send error to your monitoring service
    console.error('Application error:', e.error);
});
```

## Troubleshooting

### Common Issues

1. **WebAssembly not loading**:
   - Check MIME types
   - Verify HTTPS (required for SharedArrayBuffer)
   - Check browser console for errors

2. **CORS errors**:
   - Ensure proper CORS headers
   - Check file paths and permissions

3. **Performance issues**:
   - Enable compression
   - Use CDN for static assets
   - Optimize WebAssembly file size

### Debug Mode

Enable debug mode for development:

```javascript
// Add to app.js
const DEBUG = true;

if (DEBUG) {
    console.log('Tux Paint WebAssembly loaded');
    // Add more debug logging
}
```

## Security Considerations

1. **Content Security Policy**:
   Add CSP headers to prevent XSS attacks

2. **HTTPS Only**:
   Always use HTTPS in production

3. **Regular Updates**:
   Keep dependencies and server software updated

## Support

For deployment issues:

1. Check the browser console for errors
2. Verify all files are properly uploaded
3. Test with different browsers
4. Check server logs for errors

## Next Steps

After successful deployment:

1. Test all functionality thoroughly
2. Set up monitoring and analytics
3. Configure backups (if self-hosting)
4. Plan for scaling if needed
5. Consider adding a custom domain 