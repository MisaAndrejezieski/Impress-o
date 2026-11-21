// =========================================================
// PEÇA 3: PEDESTAL / BASE COMPACTA (FINAL VALIDADA)
// =========================================================

fan_tamanho = 120.0;
furo_rosca = 3.7;          // Rosca direta M4
folga_encaixe = 0.8;       // Unificado com carcaça/grade

parede = 3.2;
raio_externo = 12.0;
largura_base = 90.0;       // Base ampla e estável (não tomba)
espessura_orelha = 5.0;
altura_pivo = 22.0;        // Unificado com carcaca.scad

$fn = 64;

interno = fan_tamanho + folga_encaixe; // 120.8mm
externo = interno + parede * 2;        // 127.2mm
gap_orelha = espessura_orelha + 0.6;  // 0.3mm de folga de cada lado
parede_suporte = 4.5;

module caixa_arredondada(larg, alt, prof, r) {
    hull() {
        for (x = [-larg/2 + r, larg/2 - r])
            for (y = [-alt/2 + r, alt/2 - r])
                translate([x, y, 0])
                    cylinder(h = prof, r = r);
    }
}

difference() {
    union() {
        // Sapata de apoio na mesa
        caixa_arredondada(externo - 12, largura_base, 5.0, 10);

        // Torres laterais recuadas para trás (Y = -10) p/ livre inclinação
        for (lado = [-1, 1]) {
            for (sub = [-1, 1]) {
                translate([lado * (externo/2 - 22) + sub * (gap_orelha/2 + parede_suporte/2), -10, 0])
                hull() {
                    translate([0, 0, 2])
                        cube([parede_suporte, 22, 4], center = true);
                    translate([0, 0, altura_pivo])
                    rotate([0, 90, 0])
                        cylinder(h = parede_suporte, d = 18, center = true);
                }
            }
        }
    }

    // Furos M4 nos suportes do pedestal
    for (lado = [-1, 1]) {
        translate([lado * (externo/2 - 22), -10, altura_pivo])
        rotate([0, 90, 0])
            cylinder(h = 30, d = furo_rosca, center = true);
    }
}