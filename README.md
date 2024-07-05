# starter-project

## Descripción

Este proyecto está diseñado para proporcionar una estructura robusta y escalable para proyectos de Machine Learning. Utilizando prácticas modernas de MLOps, este repositorio facilita la carga, preprocesamiento, ingeniería de características, entrenamiento, evaluación y visualización de modelos de machine learning.

## Estructura del Proyecto

```bash
ml-project-name/
├── data/
│   ├── external/       # Datos externos
│   ├── processed/      # Datos procesados
│   └── raw/            # Datos crudos
├── notebooks/          # Notebooks de Jupyter
├── src/
│   ├── data/           # Manejo de datos
│   │   ├── load_data.py
│   │   └── preprocess.py
│   ├── features/       # Ingeniería de características
│   │   └── build_features.py
│   ├── models/         # Modelos de ML
│   │   ├── train_model.py
│   │   └── evaluate_model.py
│   ├── visualization/  # Visualización de datos
│   │   └── visualize.py
│   └── utils/          # Funciones auxiliares
│       └── helper_functions.py
├── tests/              # Scripts de pruebas
├── .gitignore          # Archivos y carpetas a ignorar por Git
├── README.md           # Descripción del proyecto
├── requirements.txt    # Dependencias del proyecto
└── main.py             # Script principal
```
## Funcionalidades

- **Carga de Datos:** Funciones para cargar datos desde múltiples fuentes.
- **Preprocesamiento:** Limpiar y preparar datos para el modelado.
- **Ingeniería de Características:** Crear nuevas características a partir de los datos existentes.
- **Entrenamiento de Modelos:** Entrenar modelos de machine learning.
- **Evaluación de Modelos:** Evaluar el rendimiento de los modelos.
- **Visualización:** Visualizar datos y resultados del modelo.

## Instalación

### Prerrequisitos

- **macOS** con Homebrew instalado.
- **Python 3.10** (u otra versión compatible).
- **Git** y **GitHub CLI** instalados.

### Pasos de Instalación

1. **Clonar el repositorio:**

   ```sh
   git clone https://github.com/vverlaine/starter-project.git
   cd starter-project
   ```

2. **Clonar el repositorio:**
   ```sh
   chmod +x setup.sh
   ./setup.sh
   ```
   
El script setup.sh realizará las siguientes tareas:
- Verificar e instalar dependencias necesarias.
- Crear y activar un entorno virtual.
- Instalar dependencias desde requirements.txt.
- Copiar la estructura del proyecto a la ubicación seleccionada.

3. **Seleccionar dependencias a instalar:**

Durante la ejecución del script, se te pedirá seleccionar las dependencias a instalar. Confirma con “s” para instalar y “n” para omitir.

4. **Configurar el entorno virtual:**

Se creará un entorno virtual en ~/.virtualenvs/ y se configurará un alias para activarlo fácilmente.

## **Uso**
1. Activar el entorno virtual:
   ```sh
   source ~/.virtualenvs/nombre_entorno/bin/activate
   ```
2. Activar el entorno virtual:
   ```sh
   python main.py
   ```

3. Desarrollar y ejecutar notebooks de Jupyt:
```sh
   jupyter notebook
   ```