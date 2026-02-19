# Proyecto corto 1

</h4> <hr style="border: 1px solid #000;"/>

## Descripción del proyecto

Este proyecto se basa en la implementación y comparación de distintas microarquitecturas para multiplicadores en FPGA. Consiste en tres diseños principales: una arquitectura uniciclo utilizando el operador *, una arquitectura segmentada basada en multiplicadores 8x8 con suma de productos parciales y registros intermedios, y un multiplicador multiciclo utilizando el algoritmo de Booth. 

Cada arquitectura fue sintetizada para la plataforma AMD Kria KV260 a una frecuencia de 300 MHz, utilizando la estrategia por defecto de Vivado y sin emplear bloques DSP. Posteriormente, se realizó un análisis comparativo considerando el retardo de la ruta crítica, la frecuencia máxima alcanzada, la latencia en ciclos de reloj y el consumo de recursos (LUTs y Flip-Flops).

El objetivo principal del proyecto es evaluar el impacto reflejado en cada diseño desarrollado en términos de desempeño, latencia y utilización de recursos.

</h4> <hr style="border: 1px solid #000;"/>

## Explicación de los diseños y las instrucciones de contrucción: 

### Uniciclo
Para este diseño se utiliza un multiplicador 64x64 que utiliza el operador *, el cual posee una arquitectura uniciclo, con lógica combinacional delimitada por regsitros de entrada y salida. 

Su funcionalidad se basa en la expresión matemática: 
                    c = a * b. 
Donde:
a y b: Son registros de entrada de 64 bits cada uno. 
c: Es el regsitro de salida de 128 bits, que representa el producto de la multiplicación.


Al compararlo con los diseños siguientes, este diseño se muestra un poco simple, pues no requiere segmentación o máquinas de estado para su funcionamiento. Sin embargo, a la hora de su implementación a nivel de diagrama de bloques se debe tomar en cuenta limitaciones de los IPs de Vivado utilizados. Por ejemplo, el caso de los módulos: axi_gpios.
Estos axi_gpios manejan entradas y salidas de 32 bits, mientras que el diseño del mutiplicador requiere datos de entrada de 64 bits y una salida de 128 bits.

Por tanto, se requiere la utilización de nuevos IPs de Vivado como "Slice" y "Concat". El primero lo que hace es segmentar/particionar un bus de datos para obtener la cantidad de bits deseados en grupos separados. Y el segundo IP (Concat) lo que hace es, justamente como su nombre lo indica, concatenar grupos de bits en un sólo bus, respetando el orden que se le defina según la significancia de los bits.  

<p align="center"> 
  <img width="1245" height="515" alt="mult64x64" src="https://github.com/user-attachments/assets/5c5e72b5-86af-4e5a-9794-5d1e0e064743" />
</p> 
<p align="center">
  Figura 1. Construcción del diseño del multiplicador 64x64 uniciclo
</p>

Tal y como se puede apreciar en la figura 1, para lograr obtener los datos de entrada del multiplicador es necesario concatenar las salidas de ambos axi_gpios con los módulos Concat. Y para extraer el dato resultante de la multiplicación, es necesario seccionar con ayuda de los Slice, el dato de 128 bits en grupos de 32 bits para que los axi_gpios puedan leerlos de vuelta.  

Para la implementación del código, fue propuesta una arquitectura donde el data path consistía en:
```
├── Entrada de datos desde AXI GPIO
└── Almacenamiento de datos en registros de entrada
    ├── Operando A [63:0]
    ├── Operando B [63:0]
└── Operación combinacional (*)
└── Registro de salida
    └──Resultado [127:0]
├── Salida de datos hacia AXI GPIO
```

</h4> <hr style="border: 1px solid #000;"/>


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

</h4> <hr style="border: 1px solid #000;"/>

### Booth

El multiplicador de Booth utiliza una serie de registros para ir guardando los resultados intermedios de la multiplicación, ya que es un algoritmo serial que require $n$ ciclos de ejecución, donde $n$ es el número de bits de los operandos de entrada. Estos registros son:

- $M$: multiplicador.
- $Q$: multiplicando.
- $Q_{-1}$: guarda el LSB del $Q$ del ciclo anterior.
- $Acc$: acumulador donde se guarda el resultado de $Acc ± M$.
- $Count$: contador de operaciones faltantes y condición de parada.

En la figura 2 se puede observar un diagrama de flujo para el algoritmo de Booth, donde se muestran los valores iniciales de los registros mencionados, y su utilización a lo largo del proceso.


<p align="center">
  <img src="fig/booth_multiplier.svg" alt="Booth Multiplier Architecture" width="600">
</p>
<p align="center">
  Figura 2. Diagrama de flujo del algoritmo de Booth
</p>




El algoritmo basa su funcionamiento en la siguiente tabla de decisión:

| $Q_0$ | $Q_{-1}$ | Operación              |
| ----- | -------- | ---------------------- |
| 0     | 0        | Arithmetic Right Shift |
| 0     | 1        | Acc ← Acc + M, ARS     |
| 1     | 0        | Acc ← Acc - M, ARS     |
| 1     | 1        | Arithmetic Right Shift |

En la implementación en HDL de este algoritmo se utilizó una descripción comportamental utilizando SystemVerilog.
</h4> <hr style="border: 1px solid #000;"/>

## Árbol de archivos

```
├── README.md
└── booth/
    ├── booth_multiplier.sv
    ├── booth_multiplier_wrapper.v
    ├── tb_booth_multipler.sv
└── segmented/
    ├── mult_64x64.v
    ├── mult_8x8.v
    ├── tb_mult_64x64.v
└── unicycle/
    ├── design_1.v
    ├── mult64.sv
    ├── mult64_wrapper.v
    ├── tb_mult64.sv
```
- Bajo la carpeta `booth/` se encuentran los archivos relacionados a la arquitectura Booth(multiciclo), donde el archivo que la implementa se llama `booth_multiplier.sv`.
- Bajo la carpeta `segmented/` se encuentran los archivos relacionados a la arquitectura Segmentada, donde el archivo que la implementa se llama `mult_64x64.v`.
- Bajo la carpeta `unicycle/` se encuentran los archivos relacionados a la arquitectura Booth(segmentada), donde el archivo que la implementa se llama `mult64.sv`.

</h4> <hr style="border: 1px solid #000;"/>

## Comparación de arquitecturas

| Arquitectura | Critical Path Delay (ns) | Max Frequency | Latency (cycles) | LUT Usage | FF Usage |
| ------------ | ------------------------ | ------------- | ---------------- | --------- | -------- |
| Uniciclo     | 5.145 (WNS =-1.643 ns)   | 194.36 MHz    | 1                | 161       | 102      |
| Segmentada   | 3.271                    | 305,72MHz     | 6                | 5380      | 245      |
| Booth        | 3.099                    | 322,68 MHz    | 64               | 169       | 265      |

</h4> <hr style="border: 1px solid #000;"/>

### Analisis de Resultados

A partir de los resultados obtenidos, se observa que la arquitectura uniciclo no logra cumplir la restricción de 300 MHz debido a su mayor camino crítico (5.145 ns), lo que limita su frecuencia máxima a 194.36 MHz. Sin embargo, tiene la ventaja de entregar el resultado en un solo ciclo y presentar el menor consumo de LUT y FF. Por su parte, tanto la arquitectura segmentada como el multiplicador de Booth sí superan los 300 MHz, ya que reducen el trabajo realizado en cada ciclo. 

La arquitectura segmentada alcanza una alta frecuencia mediante el uso de pipeline, lo que incrementa significativamente el número de LUT y FF utilizados, además de introducir una latencia de 6 ciclos. El multiplicador de Booth, en cambio, requiere considerablemente menos LUT que la arquitectura segmentada y una cantidad de FF inferior a esta, aunque mayor que la arquitectura uniciclo, presentando además el menor camino crítico, pero con una latencia de 64 ciclos.

En términos de eficiencia en área, Booth ofrece la mejor relación entre frecuencia alcanzada y recursos utilizados, mientras que la arquitectura segmentada proporciona un mejor desempeño cuando se prioriza el rendimiento continuo del sistema.




## Inteligencia Artificial

Las herramientas de Inteligencia Artificial fueron utilizadas para comprender posibles soluciones al desafío de sumas parciales profundas en el caso de la arquitectura segmentada. 
Asimismo, se hizo uso de estas herramientas para la generación de bancos de prueba y patrones de estos, para realizar testbenchs más robustos.


Ejemplos de prompts utilizados:

- In a segmented architecture I have a deep partial sum of products, which needs to be improved to meet the timing constraints. I have come with the idea of a reduction tree to simplify the deep partial sum. Which benefits can be obtained by using this approach on the timing?
- While developing a Multiplier 64x64 in Verilog, I need to produce a TB that verifies that the multiplier is working as expected. Can you please give me examples of patterns, max and min values to be tested to make a robust TB? No code needed.

</h4> <hr style="border: 1px solid #000;"/>

## Información general

Curso de Diseño avanzado con FPGAs

Programa de Maestría en Electrónica

Tecnológico de Costa Rica

Profesor: Luis León Vega (l.leon@itcr.ac.cr)


### Estudiantes

- Arturo Córdoba   (arturocv16@estudiantec.cr)
- Jill Carranza    (gcarranza@estudiantec.cr)
- Juan Pablo Ureña (juurena@estudiantec.cr)
- Víctor Sánchez   (vicsma2409@estudiantec.cr)

## Repositorio

https://github.com/acordobav/multiplier_architectures
