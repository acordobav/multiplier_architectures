# Proyecto corto 1

## Descripción del proyecto

## Explicación de los diseños

### Uniciclo

### Segmentada

### Booth

El multiplicador de Booth utiliza una serie de registros para ir guardando los resultados intermedios de la multiplicación, ya que es un algoritmo serial que require $n$ ciclos de ejecución, donde $n$ es el número de bits de los operandos de entrada. Estos registros son:

- $M$: multiplicador.
- $Q$: multiplicando.
- $Q_{-1}$: guarda el LSB del $Q$ del ciclo anterior.
- $Acc$: acumulador donde se guarda el resultado de $Acc ± M$.
- $Count$: contador de operaciones faltantes y condición de parada.

En la siguiente imagen se puede observar un diagrama de flujo para el algoritmo de Booth, donde se muestran los valores iniciales de los registros mencionados, y su utilización a lo largo del proceso.

![Booth Multiplier Architecture](fig/booth_multiplier.svg)

El algoritmo basa su funcionamiento en la siguiente tabla de decisión:

| $Q_0$ | $Q_{-1}$ | Operación              |
| ----- | -------- | ---------------------- |
| 0     | 0        | Arithmetic Right Shift |
| 0     | 1        | Acc ← Acc + M, ARS     |
| 1     | 0        | Acc ← Acc - M, ARS     |
| 1     | 1        | Arithmetic Right Shift |

En la implementación en HDL de este algoritmo se utilizó una descripción comportamental utilizando SystemVerilog.

## Instrucciones de construcción

## Árbol de archivos

- Bajo la carpeta `booth/` se encuentran los archivos relacionados a la arquitectura Booth, donde el archivo que la implementa se llama `booth_multiplier.sv`.

```
├── README.md
└── booth/
    ├── booth_multiplier.sv
```

## Comparación de arquitecturas

| Arquitectura | Critical Path Delay (ns) | Max Frequency | Latency (cycles) | LUT Usage | FF Usage |
| ------------ | ------------------------ | ------------- | ---------------- | --------- | -------- |
| Uniciclo     | TBD                      | TBD           | TBD              | TBD       | TBD      |
| Segmentada   | TBD                      | TBD           | TBD              | TBD       | TBD      |
| Booth        | 3.099                    | 322,68 MHz    | 64               | 169       | 265      |

## Información general

Curso de Diseño avanzado con FPGAs

Programa de Maestría en Electrónica

Tecnológico de Costa Rica

Profesor Luis León Vega (l.leon@itcr.ac.cr)

### Estudiantes

- Arturo Córdoba (arturocv16@estudiantec.cr)

## Repositorio

https://github.com/acordobav/multiplier_architectures
