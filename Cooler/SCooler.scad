
/*
=========================================================
PROJETO: VENTILADOR DE MESA PCYES CALAFRIO 120 MM
PECA 1: CARCACA PRINCIPAL
ARQUIVO: Cooler.scad

Impressao:
- Fundo fechado sobre a mesa.
- Abertura voltada para cima.
- Sem suportes.

Unidades: milimetros
=========================================================
*/

// ---------------- PARAMETROS PRINCIPAIS ----------------

fan_tamanho = 120.0;
fan_espessura = 26.0;

furo_distancia = 105.0;
furo_diametro = 4.4;
furo_rosca = 3.3;

folga_encaixe = 0.8;

usb_formato = "retangular";
// ["retangular", "oval"]

usb_largura = 14.8;
usb_altura = 7.2;

parede = 3.2;
parede_fundo = 3.5;

espaco_traseiro = 14.0;
recuo_acustico = 10.0;

raio_externo = 12.0;
raio_interno = 3.5;

espessura_orelha = 5.0;
altura_pivo = 22.0;

diametro_torre = 12.4;
furo_torre_profundidade = 12.0;

$fn = 64;

// ---------------- DIMENSOES CALCULADAS ----------------

interno = fan_tamanho + folga_encaixe;

externo = interno + parede * 2;

z_costas_cooler = parede_fundo + espaco_traseiro;

profundidade_carcaca =
    z_costas_cooler +
    fan_espessura +
    recuo_acustico;

// Coordenadas compartilhadas com o pedestal

x_pivo = externo / 2 - 22.0;
y_pivo = -externo / 2 - 6.0;

// ---------------- MODULOS ----------------

module caixa_arredondada(larg, alt, prof, r) {

    hull() {

        for (x = [-larg/2 + r, larg/2 - r])
            for (y = [-alt/2 + r, alt/2 - r])

                translate([x, y, 0])
                    cylinder(h = prof, r = r);
    }
}


module perfil_usb(larg, alt, prof) {

    if (usb_formato == "retangular") {

        rotate([90, 0, 0])
            caixa_arredondada(
                larg,
                alt,
                prof,
                0.8
            );

    } else {

        hull() {

            for (x = [
                -larg/2 + alt/2,
                 larg/2 - alt/2
            ])

                translate([x, 0, 0])
                    rotate([90, 0, 0])
                        cylinder(
                            h = prof,
                            d = alt
                        );
        }
    }
}


// ---------------- CARCACA ----------------

union() {

    difference() {

        union() {

            // Corpo principal

            caixa_arredondada(
                externo,
                externo,
                profundidade_carcaca,
                raio_externo
            );


            // Reforco externo da abertura USB

            translate([
                0,
                externo/2 + 1.0,
                parede_fundo + usb_altura/2
            ])

                perfil_usb(
                    usb_largura + 4.0,
                    usb_altura + 3.6,
                    2.5
                );


            // Abas de articulacao

            for (lado = [-1, 1]) {

                translate([
                    lado * x_pivo,
                    y_pivo,
                    altura_pivo
                ])

                    rotate([0, 90, 0])

                        hull() {

                            cylinder(
                                h = espessura_orelha,
                                d = 18,
                                center = true
                            );

                            translate([0, 12, 0])

                                cylinder(
                                    h = espessura_orelha,
                                    d = 18,
                                    center = true
                                );
                        }
            }
        }


        // Cavidade interna

        translate([0, 0, parede_fundo])

            caixa_arredondada(
                interno,
                interno,
                profundidade_carcaca + 2,
                raio_interno
            );


        // Entrada traseira de ar

        translate([0, 0, -1])

            cylinder(
                h = parede_fundo + 4,
                d = 96
            );


        // Janela USB

        translate([
            0,
            externo/2 + 4,
            parede_fundo + usb_altura/2
        ])

            perfil_usb(
                usb_largura,
                usb_altura,
                16
            );


        // Furos das abas de articulacao

        for (lado = [-1, 1]) {

            translate([
                lado * x_pivo,
                y_pivo,
                altura_pivo
            ])

                rotate([0, 90, 0])

                    cylinder(
                        h = espessura_orelha + 6,
                        d = furo_diametro,
                        center = true
                    );
        }
    }


    // ---------------- TORRES DO COOLER ----------------

    difference() {

        union() {

            for (x = [-1, 1])
                for (y = [-1, 1]) {

                    translate([
                        x * furo_distancia/2,
                        y * furo_distancia/2,
                        parede_fundo - 0.5
                    ])

                        cylinder(
                            h = espaco_traseiro + 0.5,
                            d = diametro_torre
                        );
                }
        }


        // Furos cegos para rosqueamento M4

        for (x = [-1, 1])
            for (y = [-1, 1]) {

                translate([
                    x * furo_distancia/2,
                    y * furo_distancia/2,
                    z_costas_cooler -
                    furo_torre_profundidade
                ])

                    cylinder(
                        h = furo_torre_profundidade + 0.5,
                        d = furo_rosca
                    );
            }


        // Alivio do chicote de fios.
        // Mantem distancia da torre inferior direita.

        translate([
            furo_distancia/2 - 13.0,
            -furo_distancia/2 - 3.0,
            z_costas_cooler - 3.0
        ])

            cube(
                [8, 12, 8],
                center = true
            );
    }
}


// ---------------- INFORMACOES DE REFERENCIA ----------------

echo("Largura externa:", externo);
echo("Profundidade:", profundidade_carcaca);
echo("Posicao traseira do cooler:", z_costas_cooler);
echo("Posicao do pivo Y:", y_pivo);
echo("Posicao do pivo Z:", altura_pivo);
