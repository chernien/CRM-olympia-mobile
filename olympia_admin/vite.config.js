import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    // Proxy API calls to the .NET backend so the browser talks same-origin (no CORS).
    // Target = the backend you run in Visual Studio. Default here is the "https" profile
    // (https://localhost:7081); `secure:false` accepts its self-signed dev certificate.
    // If you run the "http" profile instead, set target to 'http://localhost:5000'.
    proxy: {
      '/api': {
        target: 'http://localhost:5000',
        changeOrigin: true,
        secure: false,
      },
    },
  },
})
