// =========================================================
// PEÇA 3: BASE / PEDESTAL COMPACTO (120mm Fan)
// =========================================================

fan_tamanho = 120.0;
furo_rosca = 3.7;
folga_encaixe = 0.4;

parede = 3.2;
raio_canto = 12.0;
largura_base = 82;
espessura_orelha = 5.0;

$fn = 64;

interno = fan_tamanho + folga_encaixe;
externo = interno + parede * 2;
gap_orelha = espessura_orelha + 0.5;
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
        caixa_arredondada(externo - 12, largura_base, 4.5, 10);

        // Torres laterais de fixação da carcaça
        for (lado = [-1, 1]) {
            for (sub = [-1, 1]) {
                translate([lado * (externo/2 - 22) + sub * (gap_orelha/2 + parede_suporte/2), 0, 0])
                hull() {
                    translate([0, 0, 2])
                        cube([parede_suporte, 34, 4], center = true);
                    translate([0, -2, 18])
                    rotate([0, 90, 0])
                        cylinder(h = parede_suporte, d = 20, center = true);
                }
            }
        }
    }

    // Furos M4 nos suportes da base
    for (lado = [-1, 1]) {
        translate([lado * (externo/2 - 22), -2, 18])
        rotate([0, 90, 0])
            cylinder(h = 30, d = furo_rosca, center = true);
    }
}