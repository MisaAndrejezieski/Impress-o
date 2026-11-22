// =========================================================
// PAREDE COM JANELA 50x50 (SEM ENCAIXE PARA FOLHA DE JANELA)
// Auditado para OpenSCAD 2021.01
// =========================================================

// --- Dimensoes principais (em mm) ---
lado_parede       = 50;      // Parede quadrada: 50 x 50 mm
espessura         = 8;       // Espessura da parede

// --- Dimensoes da janela ---
largura_janela    = 22;      // Largura do vao da janela
altura_janela     = 22;      // Altura do vao da janela
altura_peitoril   = 16;      // Altura da base ate o peitoril

// --- Parametros dos pinos e encaixes da parede ---
raio_pino         = 2.5;     // Raio nominal do pino
altura_pino       = 4.0;     // Altura util do pino
folga_encaixe     = 0.25;    // Folga no furo (ajuste conforme teste na Ender 3)
qtd_pinos_lateral = 2;       // Quantidade de pinos/furos na lateral
qtd_pinos_topo    = 2;       // Quantidade de pinos no topo
tem_pinos_topo    = true;    // Ativa/desativa pinos no topo

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

module parede_com_janela_50x50() {
    x_janela = (lado_parede - largura_janela) / 2;

    union() {
        difference() {
            // Bloco principal da parede 50x50
            cube([lado_parede, espessura, lado_parede]);

            // Recorte central da janela
            translate([x_janela, -0.1, altura_peitoril])
                cube([largura_janela, espessura + 0.2, altura_janela]);

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

parede_com_janela_50x50();