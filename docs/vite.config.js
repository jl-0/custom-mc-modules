import { defineConfig } from 'vite'

export default defineConfig({
  base: '/unity-terraform-modules/',
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
  },
  server: {
    port: 3000,
    open: true
  }
})