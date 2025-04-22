#!/bin/bash

# Archivo de salida CSV
output_csv="time_per_file_data.csv"

# Crear encabezado del archivo CSV
echo "fecha,time_per_file" > "$output_csv"

# Iterar sobre las carpetas que coinciden con el patrón
for d in 202*-*-*A2/; do
    echo "Procesando carpeta: $d"
    cd "$d" || continue

    # Buscar el archivo .fil dentro de la carpeta
    filename=$(find . -maxdepth 1 -name "ds*.fil" | head -n 1)

    # Verificar si existe un archivo .fil
    if [ -n "$filename" ]; then
        echo "Archivo encontrado: $filename"

        # Extraer información del nombre del archivo
        src=$(echo "$filename" | cut -d'_' -f2)
        ant=$(echo "$filename" | cut -d'_' -f3)
        date=$(echo "$filename" | cut -d'_' -f4)
        time=$(echo "$filename" | cut -d'_' -f5 | cut -c1-6)

        # Usar readfile para extraer información del header
        salida_lectura="info_header.txt"
        readfile "$filename" > "$salida_lectura" 
	time_per_file=$(grep -i "Time per file (sec)" "$salida_lectura" | awk -F'= ' '{print $2}' | xargs)


        # Verificar que ambos valores hayan sido extraídos correctamente
        if [ -n "$date" ] && [ -n "$time_per_file" ]; then
            # Guardar los datos en el archivo CSV
            echo "$date,$time_per_file" >> "../$output_csv"
            echo "Guardado: fecha=$date, time_per_file=$time_per_file"
        else
            echo "Error extrayendo datos del header en $filename"
        fi

        # Eliminar archivo temporal
        rm -f "$salida_lectura"
    else
        echo "No se encontró un archivo .fil en $d"
    fi

    cd ..
done

echo "Datos guardados en $output_csv"

