#!/bin/bash

# Función para verificar si un comando existe
command_exists() {
    command -v "$1" &> /dev/null
}

# Función para imprimir el logotipo
PrintLogo() {
    echo
    echo " _______  __    _  __   __         _______  _______  _______  ______    _______ "
    echo "|       ||  |  | ||  | |  |       |       ||       ||   _   ||    _ |  |       |"
    echo "|    ___||   |_| ||  |_|  | ____  |  _____||_     _||  |_|  ||   | ||  |_     _|"
    echo "|   |___ |       ||       ||____| | |_____   |   |  |       ||   |_||_   |   |  "
    echo "|    ___||  _    ||       |       |_____  |  |   |  |       ||    __  |  |   |  "
    echo "|   |___ | | |   | |     |         _____| |  |   |  |   _   ||   |  | |  |   |  "
    echo "|_______||_|  |__|  |___|         |_______|  |___|  |__| |__||___|  |_|  |___|  "
    echo
}

# Función para crear y activar un entorno virtual
CreateVenv() {
    echo
    echo "--> Proceso de creación de entorno virtual"
    echo

    venv_root="$HOME/.virtualenvs/"

    if [ ! -d $venv_root ]; then
        echo "Creando la carpeta $venv_root"
        mkdir $venv_root
    fi

    # Solicitar el nombre del entorno virtual
    read -p "Nombre del entorno virtual: " venv

    # Instalar virtualenv si no está instalado
    if ! command_exists virtualenv; then
        echo "Instalando herramientas de entorno virtual de Python."
        brew install virtualenv
    fi

    # Solicitar la versión de Python
    read -p "Versión de Python: " pver

    # Instalar la versión específica de Python si no está instalada
    if ! command_exists python$pver; then
        echo "Instalando la versión de Python."
        brew install python@$pver
    fi

    # Crear el entorno virtual
    echo "Creando $venv con Python $pver"
    venv_path="$venv_root$venv"
    virtualenv -p python$pver $venv_path

    venv_bin="$venv_path/bin/activate"
    source $venv_bin

    # Crear un alias para la activación del entorno virtual
    echo >> $HOME/.zshrc
    echo "# Alias para la activación del entorno virtual $venv" >> $HOME/.zshrc
    echo "alias act_$venv='source $venv_bin'" >> $HOME/.zshrc
    echo "El alias 'act_$venv' ha sido creado en ~/.zshrc"

    # Actualizar el sistema
    echo
    echo "Actualizando el sistema"
    brew update
    brew install zsh

    source $HOME/.zshrc
}

# Función principal para configurar el entorno
SetupEnvironment() {
    # Imprimir el logotipo
    PrintLogo

    # Verificar el sistema operativo y asegurarse de que las herramientas necesarias están instaladas
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "Sistema operativo: macOS"
        if ! command_exists brew; then
            echo "Homebrew no está instalado. Instalándolo ahora..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        if ! command_exists python3; then
            echo "Python3 no está instalado. Por favor, instálalo antes de continuar."
            exit 1
        fi
        if ! command_exists zenity; then
            echo "Zenity no está instalado. Instalándolo ahora..."
            brew install zenity
        fi
        if ! command_exists gh; then
            echo "GitHub CLI no está instalado. Instalándolo ahora..."
            brew install gh
        fi
    else
        echo "Sistema operativo no soportado. Por favor, usa macOS."
        exit 1
    fi

    # Solicitar la ubicación del entorno inicial de manera visual
    starter_env=$(zenity --file-selection --directory --title="Selecciona la carpeta del entorno inicial")
    echo "------------------------------------------------------------"
    echo "$starter_env"
    echo "------------------------------------------------------------"

    # Verificar si se seleccionó una ubicación
    if [ -z "$starter_env" ]; then
        echo "No se seleccionó una ubicación. Saliendo..."
        exit 1
    fi

    # Copiar la estructura básica del proyecto desde la plantilla existente, asegurándose de copiar todos los archivos
    echo "Copiando estructura del proyecto..."
    rsync -av --progress --exclude 'setup.sh' --exclude 'README.md' . "$starter_env"

    # Cambiar a la carpeta del proyecto de destino
    cd "$starter_env"

    # Crear un archivo requirements.txt temporal y seleccionar dependencias
    cp requirements.txt temp_requirements.txt

    # Preguntar si se quiere instalar PySpark
    read -p "¿Deseas instalar PySpark? (s/n): " install_pyspark

    if [[ "$install_pyspark" == "s" ]]; then
        if ! command_exists java; then
            echo "Java no está instalado. Instalándolo ahora..."
            brew install java
        fi
        if ! command_exists spark-shell; then
            echo "Apache Spark no está instalado. Instalándolo ahora..."
            brew install apache-spark
        fi
        echo "pyspark" >> temp_requirements.txt
    fi

    # Preguntar si se quiere instalar Jupyter Notebook
    read -p "¿Deseas instalar Jupyter Notebook? (s/n): " install_jupyter

    if [[ "$install_jupyter" == "s" ]]; then
        echo "jupyter" >> temp_requirements.txt
    fi

    # Seleccionar dependencias para instalar
    echo "Selecciona las dependencias a instalar:"
    deps=($(cat temp_requirements.txt))
    selected_deps=()
    for dep in "${deps[@]}"; do
        read -p "¿Deseas instalar $dep? (s/n): " choice
        if [[ "$choice" == "s" ]]; then
            selected_deps+=($dep)
        fi
    done

    # Guardar las dependencias seleccionadas en un nuevo requirements.txt
    echo "${selected_deps[@]}" | tr ' ' '\n' > requirements.txt

    # Instalar dependencias seleccionadas
    if [ ${#selected_deps[@]} -ne 0 ]; then
        pip install "${selected_deps[@]}"
    else
        echo "No se seleccionaron dependencias para instalar."
    fi

    # Eliminar archivos temporales
    rm temp_requirements.txt

    echo "Configuración completada. El entorno está listo para usar."
}

# Ejecutar la configuración del entorno
SetupEnvironment