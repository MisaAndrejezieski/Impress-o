// =========================================================
// PAREDE COM PORTA 50x50 (SEM SOLEIRA + DOBRADICA)
// Auditado para OpenSCAD 2021.01
// =========================================================

// --- Dimensoes principais (em mm) ---
lado_parede       = 50;      // Parede quadrada: 50 x 50 mm
espessura         = 8;       // Espessura da parede

// --- Dimensoes da porta ---
largura_porta     = 22;      // Largura do vao da porta
altura_porta      = 38;      // Altura do vao da porta (aberto ate o chao)

// --- Dobradica / pivo para a folha da porta ---
usar_dobradica    = true;    // Furos na face interna esquerda do batente
raio_pivo_porta   = 1.6;     // Raio do furo para o pino da porta
prof_pivo_porta   = 3.0;     // Profundidade do furo no batente
altura_pivo_inf   = 6.0;     // Distancia do chao ate o pivo inferior
altura_pivo_sup   = 32.0;    // Distancia do chao ate o pivo superior

// --- Parametros dos pinos e encaixes da parede ---
raio_pino         = 2.5;     // Raio nominal do pino
altura_pino       = 4.0;     // Altura util do pino
folga_encaixe     = 0.25;    // Folga no furo (ajuste conforme teste na Ender 3)
qtd_pinos_lateral = 2;       // Encaixes na altura lateral
qtd_pinos_topo    = 2;       // Encaixes no topo para o telhado
tem_pinos_topo    = true;    // Pinos no topo da parede

// Resolucao de cilindros
$fn = 48;

module pino_chanfrado(r, h) {
    h_corpo = h * 0.75;
    h_ponta = h * 0.25;
    r_ponta = r * 0.78;

    union() {
        cylinder(h = h_corpo + 0.02, r = r);
        translate([0, 0, h_corpo])
            cylinder(h = h_ponta, r1 = r, r2 = r_ponta);
    }
}

module furo_encaixe(r, h, folga) {
    cylinder(h = h + folga + 0.1, r = r + folga);
}

module parede_com_porta_50x50() {
    x_porta = (lado_parede - largura_porta) / 2;

    union() {
        difference() {
            // Bloco principal da parede 50x50
            cube([lado_parede, espessura, lado_parede]);

            // Recorte da porta aberto direto ate o chao (Z = -0.1)
            translate([x_porta, -0.1, -0.1])
                cube([largura_porta, espessura + 0.2, altura_porta + 0.1]);

            // Furos de dobradica na lateral interna esquerda do batente
            if (usar_dobradica) {
                for (z_pivo = [altura_pivo_inf, altura_pivo_sup]) {
                    translate([x_porta - prof_pivo_porta, espessura / 2, z_pivo])
                    rotate([0, 90, 0])
                        cylinder(h = prof_pivo_porta + 0.1, r = raio_pivo_porta);
                }
            }

            // Furos de encaixe na lateral direita (+X)
            for (i = [1 : qtd_pinos_lateral]) {
                z_pos = (lado_parede / (qtd_pinos_lateral + 1)) * i;
                translate([
                    lado_parede - (altura_pino + folga_encaixe),
                    espessura / 2,
                    z_pos
                ])
                rotate([0, 90, 0])
                    furo_encaixe(raio_pino, altura_pino, folga_encaixe);
            }
        }

        // Pinos na lateral esquerda (-X)
        for (i = [1 : qtd_pinos_lateral]) {
            z_pos = (lado_parede / (qtd_pinos_lateral + 1)) * i;
            translate([-altura_pino, espessura / 2, z_pos])
            rotate([0, 90, 0])
                pino_chanfrado(raio_pino, altura_pino);
        }

        // Pinos no topo (+Z) para encaixar o telhado
        if (tem_pinos_topo) {
            for (j = [1 : qtd_pinos_topo]) {
                x_pos = (lado_parede / (qtd_pinos_topo + 1)) * j;
                translate([x_pos, espessura / 2, lado_parede - 0.01])
                    pino_chanfrado(raio_pino, altura_pino);
            }
        }
    }
}

parede_com_porta_50x50();