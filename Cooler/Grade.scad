
/*
============================================================
 PROJETO: SAKURA RED EDITION - GRADE DECORATIVA 120 MM
 Arquivo: Sakura_Red_120.scad

 Cooler: PCYES Calafrio 120 x 120 x 25 mm
 Furação: 105 x 105 mm
 Impressora: Ender 3 V1 32 bits
 Fatiador: PrusaSlicer 2.9.6

 CARACTERISTICAS:
 - Flores Sakura de cinco petalas
 - Ramos organicos
 - Area central livre para o logo original
 - Faixa circular reservada para o LED
 - Quatro pontos de fixacao M4
 - Impressao plana, sem suportes

 Unidades: milimetros
============================================================
*/


// ============================================================
// 1. DIMENSOES PRINCIPAIS
// ============================================================

fan_tamanho = 120.0;

dimensao_externa = 127.2;

esp_grade = 3.2;

raio_cantos = 12.0;

largura_moldura = 5.0;


// ============================================================
// 2. FIXACAO DO COOLER
// ============================================================

furo_distancia = 105.0;

furo_diametro = 4.4;

diametro_reforco = 15.0;


// ============================================================
// 3. CIRCULO DE LED
// ============================================================

// VALOR PROVISORIO.
// Ajustar conforme a medida real do LED.

led_diametro = 110.0;

// Faixa livre ao redor do LED.

led_folga = 2.5;

// Largura dos quatro pequenos conectores
// que atravessam a faixa luminosa.

largura_conector_led = 2.4;


// ============================================================
// 4. LOGOTIPO CENTRAL
// ============================================================

// Abertura livre para mostrar o dragao original.

logo_diametro = 44.0;


// ============================================================
// 5. FLORES E RAMOS
// ============================================================

numero_flores = 8;

petala_raio = 3.0;

petala_distancia = 3.3;

centro_flor = 1.5;

largura_ramo = 2.8;

largura_ramo_fino = 2.0;

posicao_flores = 35.0;


// ============================================================
// 6. RESOLUCAO
// ============================================================

$fn = 64;


// ============================================================
// 7. MODULO: RETANGULO ARREDONDADO
// ============================================================

module retangulo_arredondado(largura, altura, raio)
{
    offset(r = raio)
        square(
            [
                largura - 2 * raio,
                altura - 2 * raio
            ],
            center = true
        );
}


// ============================================================
// 8. MOLDURA EXTERNA
// ============================================================

module moldura_externa()
{
    difference()
    {
        retangulo_arredondado(
            dimensao_externa,
            dimensao_externa,
            raio_cantos
        );

        // Abertura circular interna.
        // Mantem a moldura quadrada nos cantos.

        circle(
            d = led_diametro + led_folga * 2 + 2
        );
    }
}


// ============================================================
// 9. REFORCOS DOS QUATRO PARAFUSOS
// ============================================================

module reforcos_fixacao()
{
    for (x = [-1, 1])
    {
        for (y = [-1, 1])
        {
            translate(
                [
                    x * furo_distancia / 2,
                    y * furo_distancia / 2
                ]
            )
                circle(
                    d = diametro_reforco
                );
        }
    }
}


// ============================================================
// 10. FLOR SAKURA - CINCO PETALAS
// ============================================================

module flor_sakura()
{
    union()
    {
        for (a = [0 : 72 : 288])
        {
            rotate(a)
                translate(
                    [
                        petala_distancia,
                        0
                    ]
                )
                    circle(
                        r = petala_raio
                    );
        }

        circle(
            r = centro_flor
        );
    }
}


// ============================================================
// 11. RAMO ORGANICO
// ============================================================

module segmento_ramo(x1, y1, x2, y2, largura)
{
    hull()
    {
        translate([x1, y1])
            circle(d = largura);

        translate([x2, y2])
            circle(d = largura);
    }
}


// ============================================================
// 12. GALHO PRINCIPAL
// ============================================================

module galho_sakura(angulo)
{
    rotate(angulo)
    {
        // Tronco principal

        segmento_ramo(
            22, 0,
            47, 0,
            largura_ramo
        );

        // Galho superior

        segmento_ramo(
            32, 0,
            39, 9,
            largura_ramo_fino
        );

        segmento_ramo(
            39, 9,
            46, 13,
            largura_ramo_fino
        );

        // Galho inferior

        segmento_ramo(
            35, 0,
            41, -8,
            largura_ramo_fino
        );

        segmento_ramo(
            41, -8,
            47, -11,
            largura_ramo_fino
        );
    }
}


// ============================================================
// 13. DISTRIBUICAO DAS FLORES
// ============================================================

module distribuicao_flores()
{
    for (i = [0 : numero_flores - 1])
    {
        angulo = i * 360 / numero_flores + 15;

        rotate(angulo)
            translate(
                [
                    posicao_flores,
                    0
                ]
            )
                rotate(angulo + 35)
                    flor_sakura();
    }
}


// ============================================================
// 14. CONECTORES DA FAIXA DE LED
// ============================================================

// Quatro conectores estreitos.
// Posicionados diagonalmente, como os quatro
// pontos de passagem dos clips do cooler.
//
// ATENCAO: estes conectores cruzam pequenas
// partes da faixa luminosa.

module conectores_led()
{
    for (a = [45, 135, 225, 315])
    {
        rotate(a)
        {
            segmento_ramo(
                led_diametro / 2 - 4,
                0,
                dimensao_externa / 2 - 8,
                0,
                largura_conector_led
            );
        }
    }
}


// ============================================================
// 15. ESTRUTURA SAKURA
// ============================================================

module estrutura_sakura()
{
    union()
    {
        // Galhos em diferentes direcoes

        for (a = [0, 90, 180, 270])
        {
            galho_sakura(a);
        }

        // Flores

        distribuicao_flores();

        // Ligacoes com a moldura

        conectores_led();
    }
}


// ============================================================
// 16. MONTAGEM BIDIMENSIONAL
// ============================================================

module grade_2d()
{
    difference()
    {
        union()
        {
            moldura_externa();

            reforcos_fixacao();

            estrutura_sakura();
        }

        // Furos M4

        for (x = [-1, 1])
        {
            for (y = [-1, 1])
            {
                translate(
                    [
                        x * furo_distancia / 2,
                        y * furo_distancia / 2
                    ]
                )
                    circle(
                        d = furo_diametro
                    );
            }
        }

        // Abertura central do logotipo

        circle(
            d = logo_diametro
        );
    }
}


// ============================================================
// 17. EXTRUSAO FINAL
// ============================================================

linear_extrude(
    height = esp_grade,
    convexity = 10
)
    grade_2d();


// ============================================================
// 18. RELATORIO DE DIMENSOES
// ============================================================

echo("==================================");

echo("SAKURA RED EDITION");

echo("Dimensao externa:", dimensao_externa);

echo("Espessura:", esp_grade);

echo("Furacao:", furo_distancia);

echo("Furos M4:", furo_diametro);

echo("Diametro LED:", led_diametro);

echo("Folga LED:", led_folga);

echo("Abertura logo:", logo_diametro);

echo("Quantidade flores:", numero_flores);

echo("==================================");
