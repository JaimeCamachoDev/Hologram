# Hologram

![Holograma004](https://github.com/user-attachments/assets/76338c11-5da3-4050-8cc8-c7a70f696ae9)
![413377504-f7bf48d1-871e-4193-887b-d99de6634ba2](https://github.com/user-attachments/assets/7a527f48-6aed-4861-8663-924497067ba8)
![406858841-b4a42e2c-619c-4028-a9fb-e5ede18dd9cf](https://github.com/user-attachments/assets/88a540fa-9bc9-4741-aa4e-5e99ac5356b6)
![Holograma008](https://github.com/user-attachments/assets/ccce1846-59eb-426f-9449-1d079f54b298)

Proyecto de base en **Unity 6 + URP** para crear un efecto de **holograma** con Shader Graph y Amplify, materiales dedicados y escenas de demostración.

## Cómo ejecutar

1. Clona el repositorio.
2. Abre Unity Hub y agrega la carpeta del proyecto.
3. Abre el proyecto con **Unity 6000.3.10f1**.
4. Carga la escena `Assets/3-Scenes/Hologram.unity`.
5. Presiona **Play** para validar el efecto.

## Requisitos

* Unity **6000.3.10f1**
* Render Pipeline: Universal Render Pipeline (URP)
* Paquetes: Visual Effect Graph
* Assets de terceros incluidos (no redistribuibles): AmplifyShaderEditor, Knife

## Contenido

* **VFX Graph:** `Barca-RecorridoVFX`, `Hologram_HeightMap`
* **Shader Graph:** `HoloOpaque`, `HoloTransparent`, `HoloTransparent Bordes`, `HologramWire`, `Hologram_Hologram 1`, `Hologram_Screen_Shader`
* **Sub Graphs:** `CalculateVirtualRoom`, `VirtualRoom`
* **Shaders HLSL:** `Diosa_DIssolve_LIT_RIM`, `Hex Avatar Astro`, `Hex Avatar Astro 1`, `Hex Dissolve_Hologram`, `Hex_Avatar_Excurio_Lit`, `Hex_Avatar_Excurio_Opaque`, `Hologram Shader`, `Hologram Shader IA`, `Hologram Shader IA HDRP`, `Hologram Shader IA Lit` y 10 más
* **Scripts:** `HoloMotion`
* **Prefabs:** `Hologram Capsule`, `Hologram_HeightMap`, `Nuevo Mapa`, `Prism God ray`, `SELENE_B2M1`, `SELENE_T`, `SELENE_T Variant`, `X Bot`
* **Escenas:** `Assets/3-Scenes/Hologram-HeightMap.unity`, `Assets/3-Scenes/Hologram.unity`
