# Susana Beatriz Araujo Furlan, Agosto 2024, with the help of chatgpt

import plotly.graph_objects as go
import argparse
import os
import your

def crear_plot(file_name, nstart=0, nsamp=32):
    # Asegurarse de que el archivo de entrada esté en una ruta completa
    file_name = os.path.abspath(file_name)
    yout_object = your.Your(file_name)

    # Obtener los datos
    data = yout_object.get_data(nstart=nstart, nsamp=nsamp)

    # Extraer información del nombre del archivo
    file_parts = os.path.basename(file_name).split('_')

    # Extraer la fuente (palabra después del primer '_')
    source = file_parts[1]

    # Extraer la fecha (palabra después del tercer '_')
    date = file_parts[3]

    # Crear el nombre del archivo de salida basado en la información extraída
    output_file_name = f"{source}_{date}_nstart{nstart}_nsamp{nsamp}.html"

    # Obtener el directorio del archivo de entrada
    output_directory = os.path.dirname(file_name)

    # Crear la ruta completa del archivo de salida
    output_file_path = os.path.join(output_directory, output_file_name)

    # Crear la figura interactiva
    fig = go.Figure(data=go.Heatmap(
        z=data.T,
        colorscale='Viridis',
        colorbar=dict(title="Intensidad"),
        hoverongaps=False
    ))

    # Configurar los ejes
    fig.update_layout(
        title="Gráfico interactivo de datos",
        xaxis_title="Time Samples",
        yaxis_title="Frequency Channels"
    )

    # Guardar la figura interactiva en un archivo HTML con el nombre dinámico
    fig.write_html(output_file_path)

    print(f"Gráfico guardado como {output_file_path}")

if __name__ == "__main__":
    # Crear el parser de argumentos
    parser = argparse.ArgumentParser(description="Crear un gráfico interactivo de datos y guardarlo en HTML.")
    
    # Agregar el argumento para el nombre del archivo
    parser.add_argument("file_name", type=str, help="Nombre del archivo de entrada (.fil)")
    
    # Leer los argumentos
    args = parser.parse_args()
    
    # Llamar a la función con el archivo proporcionado
    crear_plot(args.file_name)
cipt
