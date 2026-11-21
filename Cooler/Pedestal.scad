
/*
=========================================================
PROJETO: VENTILADOR DE MESA PCYES CALAFRIO 120 MM
PECA 3: PEDESTAL E ARTICULACAO
ARQUIVO: Pedestal.scad

Impressao:
- Sapata apoiada sobre a mesa.
- Torres de articulacao voltadas para cima.
- Sem suportes.

Unidades: milimetros
=========================================================
*/

// ---------------- PARAMETROS ----------------

fan_tamanho = 120.0;

furo_diametro = 4.4;

folga_encaixe = 0.8;

parede = 3.2;

raio_externo = 12.0;

espessura_orelha = 5.0;

altura_pivo = 22.0;

$fn = 64;


// ---------------- DIMENSOES ----------------

interno = fan_tamanho + folga_encaixe;

externo = interno + parede * 2;


// ---------------- ARTICULACAO ----------------

gap_orelha = espessura_orelha + 0.6;

parede_suporte = 4.5;

x_pivo = externo/2 - 22.0;

y_pivo = -externo/2 - 6.0;


// ---------------- BASE ----------------

largura_base = 140.0;

comprimento_base = 170.0;

espessura_base = 5.0;

y_centro_sapata = -25.0;

raio_base = 10.0;


// ---------------- MODULOS ----------------

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


// ---------------- PEDESTAL ----------------

difference() {

    union() {

        // Sapata principal

        translate([
            0,
            y_centro_sapata,
            0
        ])

            caixa_arredondada(
                largura_base,
                comprimento_base,
                espessura_base,
                raio_base
            );


        // Quatro suportes da articulacao

        for (lado = [-1, 1]) {

            for (sub = [-1, 1]) {

                translate([

                    lado * x_pivo +
                    sub * (gap_orelha/2 + parede_suporte/2),

                    y_pivo,

                    0

                ])

                    hull() {

                        // Base do suporte

                        translate([0, 0, 2])

                            cube([
                                parede_suporte,
                                22,
                                4
                            ], center = true);


                        // Cabeca superior do suporte

                        translate([
                            0,
                            0,
                            altura_pivo
                        ])

                            rotate([0, 90, 0])

                                cylinder(
                                    h = parede_suporte,
                                    d = 18,
                                    center = true
                                );
                    }
            }
        }
    }


    // ---------------- FUROS DA ARTICULACAO ----------------

    // Furos passantes M4.
    // O parafuso atravessa os dois suportes
    // e a aba central da carcaca.

    for (lado = [-1, 1]) {

        translate([
            lado * x_pivo,
            y_pivo,
            altura_pivo
        ])

            rotate([0, 90, 0])

                cylinder(
                    h = 30,
                    d = furo_diametro,
                    center = true
                );
    }
}


// ---------------- INFORMACOES ----------------

echo("Largura da base:", largura_base);
echo("Comprimento da base:", comprimento_base);
echo("Espessura da base:", espessura_base);

echo("Pivo X:", x_pivo);
echo("Pivo Y:", y_pivo);
echo("Pivo Z:", altura_pivo);

echo("Espacamento interno das torres:", gap_orelha);
