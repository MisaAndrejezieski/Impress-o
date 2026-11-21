
/*
=========================================================
PROJETO: VENTILADOR DE MESA PCYES CALAFRIO 120 MM
PECA 2: GRADE FRONTAL
ARQUIVO: Grade.scad

Impressao:
- Face externa sobre a mesa.
- Lábio voltado para cima.
- Sem suportes.

Unidades: milimetros
=========================================================
*/

// ---------------- PARAMETROS ----------------

fan_tamanho = 120.0;

furo_distancia = 105.0;
furo_diametro = 4.4;

folga_encaixe = 0.8;

parede = 3.2;

raio_externo = 12.0;
raio_interno = 3.5;

esp_grade = 3.2;

diametro_abertura = fan_tamanho - 4.0;

$fn = 64;


// ---------------- DIMENSOES ----------------

interno = fan_tamanho + folga_encaixe;

externo = interno + parede * 2;


// ---------------- MODULO PRINCIPAL ----------------

module caixa_arredondada(larg, alt, prof, r) {

    hull() {

        for (x = [-larg/2 + r, larg/2 - r])
            for (y = [-alt/2 + r, alt/2 - r])

                translate([x, y, 0])

                    cylinder(
                        h = prof,
                        r = r
                    );
    }
}


// ---------------- ESTRUTURA DA GRADE ----------------

union() {

    difference() {

        union() {

            // Moldura principal

            caixa_arredondada(
                externo,
                externo,
                esp_grade,
                raio_externo
            );


            // Labio de alinhamento

            translate([0, 0, esp_grade])

                difference() {

                    hull() {

                        caixa_arredondada(
                            interno - 0.8,
                            interno - 0.8,
                            3.0,
                            3.1
                        );

                        translate([0, 0, -0.5])

                            caixa_arredondada(
                                interno - 1.4,
                                interno - 1.4,
                                0.5,
                                2.5
                            );
                    }

                    // Abertura central

                    translate([0, 0, -2])

                        cylinder(
                            h = 6,
                            d = diametro_abertura
                        );
                }


            // Reforcos nos quatro parafusos

            for (x = [-1, 1])
                for (y = [-1, 1]) {

                    translate([
                        x * furo_distancia/2,
                        y * furo_distancia/2,
                        0
                    ])

                        cylinder(
                            h = esp_grade + 2.5,
                            d = 13.0
                        );
                }
        }


        // Abertura principal

        translate([0, 0, -1])

            cylinder(
                h = esp_grade + 6,
                d = diametro_abertura
            );


        // Quatro furos passantes M4

        for (x = [-1, 1])
            for (y = [-1, 1]) {

                translate([
                    x * furo_distancia/2,
                    y * furo_distancia/2,
                    -1
                ])

                    cylinder(
                        h = esp_grade + 8,
                        d = furo_diametro
                    );
            }
    }


    // ---------------- ANEIS CONCENTRICOS ----------------

    for (d = [36, 62, 88]) {

        difference() {

            cylinder(
                h = esp_grade,
                d = d + 2.4
            );

            translate([0, 0, -0.5])

                cylinder(
                    h = esp_grade + 1,
                    d = d
                );
        }
    }


    // ---------------- HASTES RADIAIS ----------------

    for (a = [0 : 60 : 300]) {

        rotate([0, 0, a + 15])

            translate([
                0,
                -1.0,
                0
            ])

                cube([
                    fan_tamanho/2 - 1,
                    2.0,
                    esp_grade
                ]);
    }


    // ---------------- CUBO CENTRAL ----------------

    cylinder(
        h = esp_grade,
        d = 38
    );
}


// ---------------- INFORMACOES ----------------

echo("Largura externa:", externo);
echo("Diametro de abertura:", diametro_abertura);
echo("Distancia entre parafusos:", furo_distancia);
echo("Espessura da grade:", esp_grade);
