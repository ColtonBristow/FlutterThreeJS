import { defineConfig } from "vite";

// https://vitejs.dev/config/
export default defineConfig(({ command, mode }) => {
  return {
    publicDir: "public",
    assetsInclude: ["**/*.gltf", "**/*.glb"],
    build: {
      outDir: "../threeJS_Viewer/web",
      minify: false,
      emptyOutDir: true,
      rollupOptions: {
        output: {
          entryFileNames: `[name].js`,
          chunkFileNames: `[name].js`,
          assetFileNames: `[name].[ext]`,
        },
      },
    },
  };
});
