# Proyecto corto 1

## Descripción del proyecto

## Explicación de los diseños

### Uniciclo

### Segmentada

El multiplicador 64x64 segmentado se basa en la segmentación de una arquitectura uniciclo (esto puede variar) mediante registros intermedios y sumas parciales (contemplando la utilización de multiplicadores 8x8, completamente combinacionales). 

En principio se muestra como una arquitectura simple, sin embargo, presenta una serie de desafíos interesantes a nivel de implementación, principalmente relacionados con el cumplimiento de los requerimientos a nivel de timing establecidos por un reloj de 300MHz. La idea inicial de esta arquitectura, y su posterior mejora, son discutidas a continuación.

Para la implementación del código base para el multiplicador objetivo, fue propuesta una arquitectura donde el data path consistía en:
```
├── Entrada de Datos a Módulo Mult 64x64
└── Almacentamiento de datos en registros de entrada
    ├── Banco de 64 registros 8x8
    ├── Partial results
    └── Final result
```

La arquitectura anterior, aunque de implementación sencilla, probó no cumplir con las limitaciones establecidas en el timing análisis, obteniendo rutas críticas con tiempos negativos.

Puntos clave:

- Banco de Multiplicadores 8x8.
- Sumador profundo (sumas parciales a suma total en un ciclo).
- Registros de salida.
- FSM para contar los ciclos mínimos para tener un resultado válido a la salida del módulo.

Al obtener dicho resultado, se investigó sobre formas en las cuáles se pudiera mejorar la arquitectura manteniendo su naturaleza de arquitectura segementada. De esta forma, en lugar de una única suma parcial de productos (profundidad elevada) se implementó un árbol de reducción de 3 niveles, donde en lugar de una única suma gigante se poseen sumas menos exigentes que se producen en varios ciclos.

```
├── Entrada de Datos a Módulo Mult 64x64
└── Almacentamiento de datos en registros de entrada
    ├── Banco de 64 registros 8x8
    ├── Reduction Tree
        └── 3 levels of reduction tree
    └── Final result
```

De esta forma, se obtuvo una arquitectura segmentada con árbol de reducción que cumple con las limitaciones a nivel de timing, y permite mantener la naturaleza de la arquitectura objetivo.

Puntos clave:

- Banco de Multiplicadores 8x8 (no mejoras).
- Sumador basado en una disposición Reduction Tree de 3 niveles (incrementa número de ciclos para obtener resultado válido pero diminuyé sustancialmente ruta crítica).
- Registros de salida.
- Pipeline con Valid Shift (len=5) (mejora al Multiplicador 64x64 a nivel de estabilidad y re-trabajo. Permite el ingreso de múltiples operaciones en ciclos de reloj contiguos sin necesidad de resetear una posible FSM).

Para la implementación de esta arquitectura se utilizó Verilog.

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
└── segmented/
    ├── mult_64x64.v
    ├── mult_8x8.v
```

## Comparación de arquitecturas

| Arquitectura | Critical Path Delay (ns) | Max Frequency | Latency (cycles) | LUT Usage | FF Usage |
| ------------ | ------------------------ | ------------- | ---------------- | --------- | -------- |
| Uniciclo     | 5.145 (WNS =-1.643 ns)   | 194.36 MHz    | 1                | 161       | 102      |
| Segmentada   | 3.271                    | 305,72MHz     | 6                | 5380      | 245      |
| Booth        | 3.099                    | 322,68 MHz    | 64               | 169       | 265      |

## Inteligencia Artificial

## Segmented Multiplier
En el caso de la arquitectura del Segmented Multiplier, herramientas de Inteligencia Artificial fueron utilizadas para comprender posibles soluciones al desafío de sumas parciales profundas, así como patrones de prueba para realizar testbenchs más robustos.

Prompt utilizados:

- In a segmented architecture I have a deep partial sum of products, which needs to be improved to meet the timing constraints. I have come with the idea of a reduction tree to simplify the deep partial sum. Which benefits can be obtained by using this approach on the timing?
- While developing a Multiplier 64x64 in Verilog, I need to produce a TB that verifies that the multiplier is working as expected. Can you please give me examples of patterns, max and min values to be tested to make a robust TB? No code needed.

## Información general

Curso de Diseño avanzado con FPGAs

Programa de Maestría en Electrónica

Tecnológico de Costa Rica

Profesor Luis León Vega (l.leon@itcr.ac.cr)

### Estudiantes

- Arturo Córdoba (arturocv16@estudiantec.cr)
- Víctor Sánchez (vicsma2409@estudiantec.cr)

## Repositorio

https://github.com/acordobav/multiplier_architectures
