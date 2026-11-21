// =========================================================
// PEÇA 2: GRADE FRONTAL PARAFUSADA (CORRIGIDA E VALIDADA)
// =========================================================

fan_tamanho = 120.0;
furo_distancia = 105.0;
furo_diametro = 4.4;       // Passante M4
folga_encaixe = 0.8;       // Unificado com carcaça (120.8mm)

parede = 3.2;
raio_externo = 12.0;       // Mesmo raio externo da carcaça (junta 100% rente)
raio_interno = 3.5;
esp_grade = 3.2;

$fn = 64;

interno = fan_tamanho + folga_encaixe; // 120.8mm
externo = interno + parede * 2;        // 127.2mm

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
        caixa_arredondada(externo, externo, esp_grade, raio_externo);

        // Ressalto interno de alinhamento (0.4mm de folga radial)
        translate([0, 0, esp_grade])
            difference() {
                caixa_arredondada(interno - 0.8, interno - 0.8, 3.0, raio_interno);
                translate([0, 0, -1])
                    cylinder(h = 5, d = fan_tamanho - 4);
            }

        // Cantoneiras reforçadas nos 4 furos de 105mm
        for (x = [-1, 1]) for (y = [-1, 1])
            translate([x * (furo_distancia/2), y * (furo_distancia/2), 0])
                cylinder(h = esp_grade + 3.0, r = 6.5);
    }

    // Abertura circular do fluxo de ar
    translate([0, 0, -1])
        cylinder(h = esp_grade + 6, d = fan_tamanho - 4);

    // Furos passantes M4 nos 4 cantos (105mm entre centros)
    translate([0, 0, -1])
        furos_montagem(furo_diametro, esp_grade + 8);
}

// Anéis concêntricos finos (baixo ruído)
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

// Cubo central (esconde o eixo do motor)
cylinder(h = esp_grade, d = 38);