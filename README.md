# Simulador de Sistemas de Comunicaciones Móviles (MATLAB)

![MATLAB](https://img.shields.io/badge/MATLAB-R2025a-blue)
![App Designer](https://img.shields.io/badge/App%20Designer-Interfaz%20Gr%C3%A1fica-orange)
![Licencia](https://img.shields.io/badge/Licencia-Acad%C3%A9mica-green)

## 📌 Descripción

Este repositorio contiene el código fuente de un **Simulador de Sistemas de Comunicaciones Móviles**, desarrollado en **MATLAB App Designer** como proyecto para la asignatura de Comunicaciones Móviles. 

La herramienta permite resolver, de forma interactiva y visual, problemas relacionados con la propagación de ondas, dimensionamiento de redes celulares, tráfico (Erlang-B) y control de admisión en sistemas CDMA. Todas las fórmulas implementadas están basadas en la literatura estándar de ingeniería (Rappaport, Hata, etc.).

## 🎯 Características principales

El simulador está dividido en cinco módulos accesibles desde una portada principal:

1. **Temas 1 y 2: Propagación y Enlace**
   - Cálculo de potencia de ruido, potencia umbral y margen log-normal.
   - Modelo de propagación de Okumura-Hata (urbano, suburbano, rural).
   - Gráfica de pérdidas vs distancia y cálculo del radio de cobertura.

2. **Tema 3: Sistemas Celulares**
   - Cálculo del factor de reuso (\( K \)) y distancia de reuso (\( D \)).
   - Canales por sector y tráfico máximo (Erlang-B).
   - Curva de probabilidad de bloqueo y punto de diseño.

3. **Tema 4: GSM y Dimensionamiento**
   - Cálculo de tráfico total soportado por celda.
   - Probabilidad de handover, probabilidad de caída y recursos (Time Slots).
   - Área de cobertura y radio de la celda.

4. **Tema 5: CDMA y Control de Admisión**
   - Factor de carga e incremento de ruido.
   - Evaluación de aceptación/rechazo de usuarios según el factor de actividad.
   - Gráfica de incremento de ruido vs factor de carga.

## 🛠️ Requisitos del sistema

- **MATLAB R2020a** o superior (el proyecto fue desarrollado en R2025a).
- **App Designer** (incluido en el paquete básico de MATLAB).
- No se requieren toolboxes adicionales.

## 🚀 Cómo ejecutar el simulador

1. Clona este repositorio o descarga los archivos.
2. Abre MATLAB y cambia la carpeta actual a la ubicación del proyecto.
3. En la ventana de comandos, escribe:
   ```matlab
   Portada
Se abrirá la ventana principal. Haz clic en el botón del tema que deseas probar.

🎥 Video demostrativo
Puedes ver una demostración del simulador en funcionamiento en el siguiente enlace:
(https://www.youtube.com/watch?v=JVSFcFaKSfg)

📄 Licencia y uso académico
Este proyecto fue desarrollado con fines exclusivamente académicos para la asignatura de Comunicaciones Móviles. El código es de libre consulta y uso educativo. Si lo utilizas como base para otros proyectos, se agradece una mención o referencia.

✒️ Autor
Gerardo Hernández - Desarrollo del simulador y documentación
Facultad de Ingeniería Mecánica y Eléctrica, incorporada a la Universidad Autónoma de Nuevo León.
9no semestre, Ingeniería en Electrónica y Comunicaciones.

Este proyecto fue desarrollado como una herramienta de apoyo didáctico para facilitar la comprensión de los conceptos teóricos de las comunicaciones móviles
