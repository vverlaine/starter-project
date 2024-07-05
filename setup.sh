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

# Función para cerrar sesión en GitHub
LogoutGitHub() {
    echo
    echo "--> Cerrando sesión en GitHub"
    echo
    gh auth logout
}

# Función principal para configurar el entorno
SetupEnvironment() {
    # Imprimir el logotipo
    PrintLogo

    # Solicitar información del proyecto
    read -p "Introduce el nombre del proyecto y repositorio: " project_name
    repo_name=$project_name
    read -p "Introduce el autor del proyecto: " author_name
    read -p "Introduce una descripción del proyecto: " project_description

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

    # Cerrar sesión en GitHub si ya hay una sesión iniciada
    if gh auth status &> /dev/null; then
        read -p "Ya hay una sesión de GitHub iniciada. ¿Deseas cerrar sesión y entrar con otra cuenta? (s/n): " logout_choice
        if [[ "$logout_choice" == "s" ]]; then
            LogoutGitHub
        fi
    fi

    # Autenticarse en GitHub
    echo
    echo "--> Iniciando sesión en GitHub"
    echo
    gh auth login

    # Crear y activar el entorno virtual
    CreateVenv

    # Crear un archivo requirements.txt si no existe y seleccionar dependencias
    if [ ! -f requirements.txt ]; then
        echo "Creando archivo requirements.txt por defecto..."
        echo -e "numpy\npandas\nmatplotlib\nscikit-learn\nflake8" > requirements.txt
    fi

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
        echo "pyspark" >> requirements.txt
    fi

    # Preguntar si se quiere instalar Jupyter Notebook
    read -p "¿Deseas instalar Jupyter Notebook? (s/n): " install_jupyter

    if [[ "$install_jupyter" == "s" ]]; then
        echo "jupyter" >> requirements.txt
    fi

    # Seleccionar dependencias para instalar
    echo "Selecciona las dependencias a instalar:"
    deps=($(cat requirements.txt))
    selected_deps=()
    for dep in "${deps[@]}"; do
        read -p "¿Deseas instalar $dep? (s/n): " choice
        if [[ "$choice" == "s" ]]; then
            selected_deps+=($dep)
        fi
    done

    # Guardar las dependencias seleccionadas en requirements.txt
    echo "${selected_deps[@]}" | tr ' ' '\n' > requirements.txt

    # Instalar dependencias seleccionadas
    if [ ${#selected_deps[@]} -ne 0 ]; then
        pip install "${selected_deps[@]}"
    else
        echo "No se seleccionaron dependencias para instalar."
    fi

    # Solicitar la ubicación del nuevo proyecto de manera visual
    project_location=$(zenity --file-selection --directory --title="Selecciona la ubicación del nuevo proyecto")

    # Verificar si se seleccionó una ubicación
    if [ -z "$project_location" ]; then
        echo "No se seleccionó una ubicación. Saliendo..."
        exit 1
    fi

    # Crear una carpeta con el nombre del proyecto
    project_path="$project_location/$project_name"
    mkdir -p "$project_path"

    # Copiar la estructura básica del proyecto desde la plantilla existente
    echo "Copiando estructura del proyecto..."
    rsync -av --progress --exclude 'setup.sh' --exclude 'requirements.txt' . "$project_path"

    # Crear un archivo README.md con la información del proyecto
    echo "# $project_name

## Autor

$author_name

## Descripción

$project_description" > "$project_path/README.md"

    # Configurar usuario y correo electrónico específicos del proyecto
    cd "$project_path"
    read -p "Introduce el nombre de usuario de Git para este proyecto: " git_user_name
    read -p "Introduce el correo electrónico de Git para este proyecto: " git_user_email
    git config user.name "$git_user_name"
    git config user.email "$git_user_email"

    # Inicializar el repositorio Git y hacer el primer commit
    git init
    git add .
    git commit -m "Initial commit"
    git remote add origin https://github.com/$author_name/$repo_name.git
    git push -u origin main

    echo "El entorno está configurado y el repositorio ha sido inicializado correctamente en $project_path."

    # Crear script para cambiar entre cuentas de GitHub
    echo "#!/bin/bash

# Script para cambiar entre cuentas de GitHub
if [ "\$1" == "personal" ]; then
    git config user.name "$git_user_name"
    git config user.email "$git_user_email"
    echo "Configurado para la cuenta personal"
elif [ "\$1" == "work" ]; then
    git config user.name "Tu Nombre de


Trabajo"
    git config user.email "tuemail@trabajo.com"
    echo "Configurado para la cuenta de trabajo"
else
    echo "Uso: ./change_git_account.sh [personal|work]"
fi" > "$project_path/change_git_account.sh"
    
    chmod +x "$project_path/change_git_account.sh"
    echo "change_git_account.sh" >> "$project_path/.gitignore"

    echo "Script para cambiar entre cuentas de GitHub creado y añadido al .gitignore."
}

# Ejecutar la configuración del entorno
SetupEnvironment
