// ==========================================
// PAREDE 50x50 E QUINA 90° - CASINHA MODULAR
// ==========================================

lado_parede    = 50;     // 50 x 50 mm
espessura      = 8;      // Espessura firme

// Tipo de peça: "parede" ou "quina"
tipo_peca      = "parede";

// Parâmetros do encaixe
raio_pino      = 2.5;
altura_pino    = 4.0;
folga_encaixe  = 0.25;   // Ajuste fino para sua Ender 3 + PLA
qtd_pinos      = 2;

$fn = 48;

module pino_com_ponta(r, h) {
    // Corpo principal (75%)
    cylinder(h = h * 0.75, r = r);
    // Ponta chanfrada (25%) para facilitar o encaixe das crianças
    translate([0, 0, h * 0.75 - 0.01])
        cylinder(h = h * 0.25 + 0.01, r1 = r, r2 = r * 0.78);
}

module parede_50x50() {
    difference() {
        cube([lado_parede, espessura, lado_parede]);

        // Furos na face direita (X = lado_parede)
        for (i = [1 : qtd_pinos]) {
            z_pos = (lado_parede / (qtd_pinos + 1)) * i;
            translate([
                lado_parede - (altura_pino + folga_encaixe) + 0.05,
                espessura / 2,
                z_pos
            ])
            rotate([0, 90, 0])
                cylinder(
                    h = altura_pino + folga_encaixe + 0.1,
                    r = raio_pino + folga_encaixe
                );
        }
    }

    // Pinos na face esquerda (X = 0)
    for (i = [1 : qtd_pinos]) {
        z_pos = (lado_parede / (qtd_pinos + 1)) * i;
        translate([-altura_pino, espessura / 2, z_pos])
        rotate([0, 90, 0])
            pino_com_ponta(raio_pino, altura_pino);
    }
}

module quina_90_graus() {
    // Pilar/quina de 50 mm de altura com encaixes em +X e +Y
    difference() {
        cube([espessura, espessura, lado_parede]);

        // Furos na face +X (encaixa parede vindo pela direita)
        for (i = [1 : qtd_pinos]) {
            z_pos = (lado_parede / (qtd_pinos + 1)) * i;
            translate([
                espessura - (altura_pino + folga_encaixe) + 0.05,
                espessura / 2,
                z_pos
            ])
            rotate([0, 90, 0])
                cylinder(
                    h = altura_pino + folga_encaixe + 0.1,
                    r = raio_pino + folga_encaixe
                );
        }

        // Furos na face +Y (encaixa parede vindo pela frente/trás)
        for (i = [1 : qtd_pinos]) {
            z_pos = (lado_parede / (qtd_pinos + 1)) * i;
            translate([
                espessura / 2,
                espessura - (altura_pino + folga_encaixe) + 0.05,
                z_pos
            ])
            rotate([-90, 0, 0])
                cylinder(
                    h = altura_pino + folga_encaixe + 0.1,
                    r = raio_pino + folga_encaixe
                );
        }
    }
}

if (tipo_peca == "quina") {
    quina_90_graus();
} else {
    parede_50x50();
}