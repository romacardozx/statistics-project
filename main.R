# TP Regresión - Contaminación ambiental
# Roman Cardozo - filas 481 a 640

datos_completos <- read.csv("contam.csv", row.names = 1)
datos <- datos_completos[481:640, ]

# t_amb y miles_vehic vienen cruzadas en el csv
names(datos) <- c("concentracion", "miles_vehiculos", "temperatura", "velocidad_viento", "humedad")
summary(datos)

dir.create("output", showWarnings = FALSE)

guardar_grafico <- function(nombre_archivo, grafico, ancho = 900, alto = 700) {
  png(file.path("output", nombre_archivo), width = ancho, height = alto)
  grafico
  invisible(dev.off())
}

graficar_residuos <- function(modelo, datos_modelo) {
  residuos <- resid(modelo)
  par(mfrow = c(2, 3))
  for (variable in c("miles_vehiculos", "temperatura", "velocidad_viento", "humedad")) {
    plot(datos_modelo[[variable]], residuos, xlab = variable, ylab = "residuos")
    abline(h = 0, col = "red")
  }
  plot(fitted(modelo), residuos, xlab = "valores ajustados", ylab = "residuos")
  abline(h = 0, col = "red")
}

guardar_grafico("01_pairs.png", pairs(datos), 1000, 1000)


modelo_lineal <- lm(concentracion ~ miles_vehiculos + temperatura + velocidad_viento + humedad,
                    data = datos)
summary(modelo_lineal)
guardar_grafico("02_residuos_modelo_lineal.png", graficar_residuos(modelo_lineal, datos))

residuos_estandarizados <- rstandard(modelo_lineal)
umbral_outlier <- 3.5

guardar_grafico("03_outliers.png", {
  plot(residuos_estandarizados, ylab = "residuo estandarizado")
  abline(h = c(-umbral_outlier, umbral_outlier), col = "red", lty = 2)
})

filas_outlier <- which(abs(residuos_estandarizados) > umbral_outlier)
datos[filas_outlier, ]
datos_sin_outliers <- datos[-filas_outlier, ]


modelo_lineal_sin_outliers <- lm(
  concentracion ~ miles_vehiculos + temperatura + velocidad_viento + humedad,
  data = datos_sin_outliers
)
summary(modelo_lineal_sin_outliers)
guardar_grafico("04_residuos_modelo_sin_outliers.png",
                graficar_residuos(modelo_lineal_sin_outliers, datos_sin_outliers))

modelo_cuadratico <- lm(
  concentracion ~ miles_vehiculos + temperatura + velocidad_viento + I(velocidad_viento^2) + humedad,
  data = datos_sin_outliers
)
summary(modelo_cuadratico)

modelo_final <- lm(
  concentracion ~ miles_vehiculos + velocidad_viento + I(velocidad_viento^2),
  data = datos_sin_outliers
)
summary(modelo_final)

anova(modelo_final, modelo_cuadratico)
AIC(modelo_lineal_sin_outliers, modelo_cuadratico, modelo_final)

guardar_grafico("05_residuos_modelo_final.png",
                graficar_residuos(modelo_final, datos_sin_outliers))
guardar_grafico("06_diagnostico_modelo_final.png", {
  par(mfrow = c(2, 2))
  plot(modelo_final)
})
guardar_grafico("07_observado_vs_predicho.png", {
  plot(fitted(modelo_final), datos_sin_outliers$concentracion,
       xlab = "concentración predicha", ylab = "concentración observada")
  abline(0, 1, col = "red")
})


condiciones_a_predecir <- data.frame(
  miles_vehiculos = 280,  # 280000 vehiculos
  temperatura = 31,
  velocidad_viento = 50,
  humedad = 60
)
predict(modelo_final, condiciones_a_predecir, interval = "prediction")
