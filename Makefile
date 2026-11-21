.PHONY: help run report data lint clean

help: ## Lista los comandos
	@grep -E '^[a-z]+:.*## ' Makefile | awk -F':.*## ' '{printf "  %-8s %s\n", $$1, $$2}'

run: ## Corre el script
	Rscript main.R

report: ## Corre el script y guarda la salida en output/resultados.txt
	@mkdir -p output
	Rscript main.R > output/resultados.txt 2>&1
	@tail -3 output/resultados.txt

data: ## Muestra mis filas del csv (481-640)
	@sed -n '1p;482,641p' contam.csv

lint: ## Revisa el estilo (necesita lintr)
	Rscript -e 'lintr::lint("main.R")'

clean: ## Borra los graficos y salidas
	rm -rf output Rplots.pdf
