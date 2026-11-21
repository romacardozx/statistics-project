# statistics-project
Statistics course project - UNSAM

---
## Consigna

Se quiere predecir la contaminación ambiental en una región urbana, medida en concentración de residuos contaminantes. La misma puede depender de la cantidad de vehículos circulantes, la velocidad del viento, y la temperatura y humedad ambiente

Datos en: "contam.csv" Cada estudiante toma sólo 160 filas, según indicacion aparte

Encontrar un modelo que prediga la concentración, con un valor de R cuadrado mayor a 0.9, y calcularla cuando el número de vehículos es 280000, la temperatura 31 grados, el viento corre a 50 km/h, y la humedad es 60%

Eliminar valores anómales si fuera necesario

Entrega: hasta el 20/11. Debe incluir:

-codigo R (copia del script)

-breve resumen de lo realizado (modelos probados, decisiones sobre agregar o sacar variables u observaciones, etc). Copias de gráficos
-Valor de contaminación obtenido según modelo para: número de vehículos es 280000, la temperatura 31 grados, el viento corre a 50 km/h, y la humedad es 60%
Subir un archivo word, pdf, o similar. Pueden incluir tambien el script R o copiar y pegar el codigo en el archivo

---

## Cómo correrlo

```bash
make run      # corre main.R
make report   # guarda la salida en output/resultados.txt (los gráficos también quedan en output/)
```

## Lo que hice

1. **Columnas cruzadas:** en el csv `t_amb` y `miles_vehic` tienen los nombres al revés (la "temperatura" va de 100 a 500), así que al cargar renombro todas las columnas con nombres claros (`concentracion`, `miles_vehiculos`, `temperatura`, `velocidad_viento`, `humedad`). Los vehículos están en miles, entonces 280000 = 280.

2. **Modelo lineal con todo (`modelo_lineal`):** R² = 0.79. En los residuos aparece un punto muy alejado, la obs 583, con residuo estandarizado de 9.6. Saqué todo lo que pasara de 3.5 y fue la única.

3. **Sin el outlier (`modelo_lineal_sin_outliers`):** R² = 0.907. Ya pasa el 0.9, pero los residuos contra `velocidad_viento` todavía muestran una curva.

4. **Agrego velocidad_viento² (`modelo_cuadratico`):** R² = 0.935. Temperatura y humedad no son significativas.

5. **Saco temperatura y humedad (`modelo_final`):** R² = 0.934, casi igual. El anova entre el cuadrático y el final da p = 0.36, o sea que esas dos variables no aportan. El AIC también da un poco mejor con el final.

| Modelo | R² | AIC |
|---|---|---|
| lineal (160 obs) | 0.792 | - |
| lineal sin outlier | 0.907 | 794.2 |
| + velocidad_viento² | 0.935 | 740.1 |
| final | 0.934 | 738.2 |

Modelo final: `concentracion ~ miles_vehiculos + velocidad_viento + velocidad_viento²`

## Resultado

Con 280000 vehículos, 31 °C, viento de 50 km/h y humedad 60%:

**concentración ≈ 69.25** (intervalo de predicción 95%: 64.19 a 74.31)

El viento de 50 está casi en el máximo de mis datos (50.6), así que la predicción está en el borde del rango.

Roman Cardozo: Fila 481 a 640

