# Hologram

![Banner](https://github.com/user-attachments/assets/5b933a56-0ece-452a-99c0-1a641485a6b9)

Proyecto de ejemplo en **Unity 6 + URP** para crear un efecto de **holograma** con Shader Graph, material dedicado y escena de demostración.

## ✨ Objetivo

Este repositorio funciona como base para:

- Prototipar shaders de holograma en URP.
- Reutilizar un material `HologramMat` en modelos 3D.
- Tener una escena lista para pruebas visuales rápidas.
- Servir como punto de partida para paquetes o demos más avanzadas.

## 🧱 Stack técnico

- **Engine:** Unity `6000.3.10f1` (Unity 6).
- **Render Pipeline:** Universal Render Pipeline (URP).
- **Shadering:** Shader Graph (`Hologram.shadergraph`).

## 📁 Estructura del proyecto

```text
Assets/
├── 1-Programming/           # Scripts y lógica (placeholder)
├── 2-Art/
│   ├── 2-VFX/
│   │   ├── Hologram.shadergraph
│   │   ├── HologramMat.mat
│   │   └── X Bot.fbx
│   └── 8-PostProcessing/
├── 3-Scenes/
│   ├── Main.unity
│   └── Hologram.unity
├── 4-Presets/
└── 5-Settings/              # Assets de URP y renderer

Packages/                    # Dependencias del proyecto Unity
ProjectSettings/             # Configuración global del editor/proyecto
```

## 🚀 Cómo ejecutar

1. Clona el repositorio.
2. Abre Unity Hub y agrega la carpeta del proyecto.
3. Abre el proyecto con **Unity 6000.3.10f1**.
4. Carga la escena `Assets/3-Scenes/Hologram.unity`.
5. Presiona **Play** para validar el efecto.

## 🛠️ Personalización rápida

- Ajusta parámetros en `Hologram.shadergraph` para cambiar color, fresnel, ruido o intensidad del escaneo.
- Duplica `HologramMat.mat` para crear variantes por personaje/prop.
- Ajusta `DefaultVolumeProfile` para reforzar look holográfico con bloom y post-procesado.

## 📦 Publicación y automatización

El repositorio incluye un workflow de GitHub Actions (`publish.yml`) orientado a publicar un paquete al crear un release.

> Recomendación: valida la estructura de `Packages/com.jaimecamacho.<repo>` antes de usar ese flujo en producción.

## ✅ Buenas prácticas recomendadas

- Mantener una escena mínima de benchmark visual para comparar cambios de shader.
- Versionar cambios de materiales junto con capturas o clips de referencia.
- Evitar hardcodear parámetros visuales en scripts; centralizarlos en material/shader.

## 🤝 Contribución

1. Crea una rama descriptiva (`feature/hologram-scan-lines`).
2. Realiza cambios acotados y documentados.
3. Abre PR con:
   - contexto del cambio,
   - capturas/video antes y después,
   - checklist de pruebas.

## 📄 Licencia

Este proyecto se distribuye bajo la licencia indicada en [`LICENSE`](./LICENSE).
