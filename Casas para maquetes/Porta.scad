// =========================================================
// FOLHA DA PORTA (GIRO LIVRE - PAREDE COM PORTA 50x50)
// Auditado para OpenSCAD 2021.01
// =========================================================

// --- Referencia do vao da porta (deve bater com a parede) ---
largura_vao_porta = 22;      // Largura do recorte na parede
altura_vao_porta  = 38;      // Altura do recorte na parede

// --- Dimensoes da folha da porta ---
folga_largura     = 3.2;     // Folga extra para giro livre sem raspar
folga_chao        = 1.5;     // Folga abaixo da porta para nao arrastar
folga_topo        = 1.0;     // Folga acima da porta
espessura_porta   = 4.0;     // Espessura da folha da porta

// --- Pinos de dobradica (alinhados com os furos da parede) ---
tem_pinos_pivo    = true;
raio_pivo         = 1.35;    // Cabe em furo de 1.6 mm com folga de ~0.25 mm
comp_pivo         = 2.6;     // Entra no furo de 3.0 mm sem bater no fundo
altura_pivo_inf   = 6.0;     // Mesma altura do furo inferior na parede
altura_pivo_sup   = 32.0;    // Mesma altura do furo superior na parede

// --- Puxador / macaneta compacto ---
tem_puxador       = true;
raio_puxador      = 1.8;     // Raio compacto para nao enroscar
comp_puxador      = 2.5;     // Comprimento curto para girar livre
puxador_ambos_lados = false; // false = apenas um lado; true = ambos os lados

// Resolucao de cilindros
$fn = 48;

module pino_pivo(r, h) {
    union() {
        cylinder(h = h * 0.75 + 0.02, r = r);
        translate([0, 0, h * 0.75])
            cylinder(h = h * 0.25, r1 = r, r2 = r * 0.75);
    }
}

module folha_da_porta() {
    largura_folha = largura_vao_porta - folga_largura;
    altura_folha  = altura_vao_porta - folga_chao - folga_topo;

    z_pivo_inf_rel = altura_pivo_inf - folga_chao;
    z_pivo_sup_rel = altura_pivo_sup - folga_chao;

    union() {
        // Corpo da folha da porta
        cube([largura_folha, espessura_porta, altura_folha]);

        // Pinos de pivo na borda esquerda (-X)
        if (tem_pinos_pivo) {
            for (z_rel = [z_pivo_inf_rel, z_pivo_sup_rel]) {
                if (z_rel > 0 && z_rel < altura_folha) {
                    translate([-comp_pivo + 0.02, espessura_porta / 2, z_rel])
                    rotate([0, 90, 0])
                        pino_pivo(raio_pivo, comp_pivo);
                }
            }
        }

        // Puxador compacto na borda direita da folha
        if (tem_puxador) {
            z_macaneta = altura_folha * 0.45;
            x_macaneta = largura_folha - 3.0;

            // Lado frontal (+Y)
            translate([x_macaneta, espessura_porta - 0.02, z_macaneta])
            rotate([-90, 0, 0])
                cylinder(h = comp_puxador, r = raio_puxador);

            // Lado traseiro (-Y), opcional
            if (puxador_ambos_lados) {
                translate([x_macaneta, 0.02, z_macaneta])
                rotate([90, 0, 0])
                    cylinder(h = comp_puxador, r = raio_puxador);
            }
        }
    }
}

folha_da_porta();