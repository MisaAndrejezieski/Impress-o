// =========================================================
// PEÇA 2: GRADE FRONTAL PARAFUSADA (120mm Fan)
// =========================================================

fan_tamanho = 120.0;
furo_distancia = 105.0;
furo_diametro = 4.4;
folga_encaixe = 0.4;

parede = 3.2;
raio_canto = 12.0;
esp_grade = 3.2;

$fn = 64;

interno = fan_tamanho + folga_encaixe;
externo = interno + parede * 2;

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

difference() {
    union() {
        // Aro externo
        caixa_arredondada(externo, externo, esp_grade, raio_canto);

        // Ressalto interno de alinhamento (entra 3mm na carcaça)
        translate([0, 0, esp_grade])
            difference() {
                caixa_arredondada(interno - 0.35, interno - 0.35, 3.0, raio_canto - parede);
                translate([0, 0, -1])
                    cylinder(h = 5, d = fan_tamanho - 4);
            }

        // Cantoneiras reforçadas para os 4 parafusos
        for (x = [-1, 1]) for (y = [-1, 1])
            translate([x * (interno/2 - 9), y * (interno/2 - 9), 0])
                cylinder(h = esp_grade + 3.0, r = 9);
    }

    // Abertura circular do fluxo de ar
    translate([0, 0, -1])
        cylinder(h = esp_grade + 6, d = fan_tamanho - 4);

    // Furos passantes para os 4 parafusos M4
    translate([0, 0, -1])
        furos_montagem(furo_diametro, esp_grade + 8);
}

// Anéis concêntricos finos
for (d = [36, 62, 88]) {
    difference() {
        cylinder(h = esp_grade, d = d + 2.4);
        translate([0, 0, -0.5])
            cylinder(h = esp_grade + 1, d = d);
    }
}

// 6 Hastes radiais finas
for (a = [0 : 60 : 300]) {
    rotate([0, 0, a + 15])
        translate([0, -1.0, 0])
            cube([fan_tamanho/2 - 1, 2.0, esp_grade]);
}

// Cubo central
cylinder(h = esp_grade, d = 38);