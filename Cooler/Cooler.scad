// =========================================================
// PEÇA 1: CARCAÇA PRINCIPAL CORRIGIDA (Com 4 Torres de Rosca)
// =========================================================

fan_tamanho = 120.0;
fan_espessura = 25.5;
furo_distancia = 105.0;
furo_diametro = 4.4;
furo_rosca = 3.7;
folga_encaixe = 0.4;

// USB no topo (USB-A: 14.8 x 7.2 | USB-C oval: 9.6 x 3.8)
usb_formato = "retangular"; // ["retangular", "oval"]
usb_largura = 14.8;
usb_altura = 7.2;

parede = 3.2;
parede_fundo = 3.5;
espaco_traseiro = 14.0;
recuo_acustico = 10.0;
raio_canto = 12.0;
espessura_orelha = 5.0;

$fn = 64;

interno = fan_tamanho + folga_encaixe;
externo = interno + parede * 2;
profundidade_carcaca = parede_fundo + espaco_traseiro + fan_espessura + recuo_acustico;

module caixa_arredondada(larg, alt, prof, r) {
    hull() {
        for (x = [-larg/2 + r, larg/2 - r])
            for (y = [-alt/2 + r, alt/2 - r])
                translate([x, y, 0])
                    cylinder(h = prof, r = r);
    }
}

module furos_montagem(diam, alt) {
    for (x = [-furo_distancia/2, furo_distancia/2])
        for (y = [-furo_distancia/2, furo_distancia/2])
            translate([x, y, 0])
                cylinder(h = alt, d = diam);
}

module perfil_usb(larg, alt, prof) {
    if (usb_formato == "retangular") {
        rotate([90, 0, 0])
            caixa_arredondada(larg, alt, prof, 0.8);
    } else {
        hull() {
            for (x = [-larg/2 + alt/2, larg/2 - alt/2])
                translate([x, 0, 0])
                    rotate([90, 0, 0])
                        cylinder(h = prof, d = alt, center = true);
        }
    }
}

union() {
    // 1. Casca externa + abas + abertura USB
    difference() {
        union() {
            caixa_arredondada(externo, externo, profundidade_carcaca, raio_canto);

            // Moldura externa reforçada no topo para o USB
            translate([0, externo/2 + 1.0, parede_fundo + usb_altura/2])
                perfil_usb(usb_largura + 4.0, usb_altura + 3.6, 2.5);

            // Duas abas inferiores de acoplamento na base
            for (lado = [-1, 1]) {
                translate([lado * (externo/2 - 22), -externo/2 - 7, profundidade_carcaca/2])
                rotate([0, 90, 0])
                hull() {
                    cylinder(h = espessura_orelha, d = 18, center = true);
                    translate([-10, 12, 0])
                        cylinder(h = espessura_orelha, d = 18, center = true);
                }
            }
        }

        // Cavidade interna
        translate([0, 0, parede_fundo])
            caixa_arredondada(interno, interno, profundidade_carcaca + 2, raio_canto - parede);

        // Entrada de ar traseira (diâmetro 104mm para não invadir as torres de parafuso)
        translate([0, 0, -1])
            cylinder(h = parede_fundo + 4, d = 104);

        // Janela superior para conector USB fêmea
        translate([0, externo/2 + 4, parede_fundo + usb_altura/2])
            perfil_usb(usb_largura, usb_altura, 16);

        // Furos M4 nas abas inferiores
        for (lado = [-1, 1]) {
            translate([lado * (externo/2 - 22), -externo/2 - 7, profundidade_carcaca/2])
            rotate([0, 90, 0])
                cylinder(h = espessura_orelha + 4, d = furo_diametro, center = true);
        }
    }

    // 2. As 4 Torres internas de fixação (adicionadas DEPOIS da cavidade!)
    difference() {
        for (x = [-1, 1]) for (y = [-1, 1]) {
            hull() {
                // Centro alinhado exatamente com os furos de 105mm do cooler
                translate([x * (furo_distancia/2), y * (furo_distancia/2), parede_fundo - 0.5])
                    cylinder(h = espaco_traseiro + 0.5, r = 5.5);
                // Ancorado no canto da parede interna para máxima rigidez
                translate([x * (interno/2 - 5), y * (interno/2 - 5), parede_fundo - 0.5])
                    cylinder(h = espaco_traseiro + 0.5, r = 5.0);
            }
        }

        // Furos cegos de rosca M4 (3.7mm) nas 4 torres
        translate([0, 0, parede_fundo + 1.5])
            furos_montagem(furo_rosca, espaco_traseiro + 2);
    }
}