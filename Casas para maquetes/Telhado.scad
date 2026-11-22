// =========================================================
// AGUA DO TELHADO (DEITADA, CENTRALIZADA E COM TELHAS)
// Sistema Modular 50x50 mm | Espessura parede: 8 mm
// Auditado e validado para OpenSCAD 2021.01
// =========================================================

// --- Dimensoes do sistema modular (50x50 mm, parede 8 mm) ---
lado_parede      = 50;      // Passo modular da parede
espessura_parede = 8;       // Espessura da parede
qtd_modulos_y    = 1;       // 1 = 50 mm (1 parede), 2 = 100 mm (2 paredes)

// --- Geometria da agua do telhado (deitada na mesa em Z = 0) ---
altura_pico      = 22;      // Altura do pico (define a largura/inclinação da rampa)
beiral_lateral   = 4;       // Sobrinha na borda externa da rampa
beiral_frente    = 3;       // Sobrinha nas extremidades ao longo do comprimento
espessura_base   = 3.5;     // Espessura da base plana da telha

// --- Formato das telhas (fileiras de telhas canal/capa) ---
tem_telhas       = true;    // Ativa o formato de telhas
qtd_fileiras     = 5;       // Quantidade de fileiras de telhas ao longo da rampa
altura_telha     = 2.2;     // Altura do relevo da telha acima da base
sobreposicao_mm  = 1.2;     // Degrau de sobreposicao entre fileiras de telhas

// --- Furos de encaixe (pinos da parede: raio 2.5 mm, folga 0.25 mm) ---
raio_pino        = 2.5;
altura_furo      = 4.0;
folga_encaixe    = 0.25;
qtd_pinos_topo   = 2;

$fn = 48;

module furo_encaixe(r, h, folga) {
    cylinder(h = h + 0.2, r = r + folga);
}

// Perfil 2D de uma fileira de telha (formato abaulado com degrau de encavalamento)
module perfil_fileira_telha(larg_fileira, h_base, h_telha, degrau) {
    passos = 24;
    dx = larg_fileira / passos;

    pts_baixo = [
        [larg_fileira, 0],
        [0, 0]
    ];

    pts_cima = [
        for (i = [0 : passos])
            let(
                u = i / passos,
                // Perfil abaulado suave + leve degrau no inicio da fileira
                curva = h_telha * pow(sin(180 * u), 0.75),
                deg = (u < 0.12) ? (degrau * (1 - u / 0.12)) : 0
            )
            [i * dx, h_base + curva + deg]
    ];

    polygon(points = concat(pts_baixo, pts_cima));
}

module agua_telhado_deitada() {
    // Largura util da rampa da borda externa ate o centro do pico (50/2 = 25 mm)
    metade_base = lado_parede / 2;
    larg_rampa = sqrt(pow(metade_base + beiral_lateral, 2) + pow(altura_pico, 2));
    comp_y = (lado_parede * qtd_modulos_y) + (2 * beiral_frente);

    larg_fileira = larg_rampa / qtd_fileiras;

    // Centralizado em X e Y sobre a mesa (Z = 0)
    translate([-larg_rampa / 2, -comp_y / 2, 0]) {
        difference() {
            union() {
                // Base solida apoiada na mesa (Z = 0)
                cube([larg_rampa, comp_y, espessura_base]);

                // Fileiras de telhas ao longo da rampa (eixo X da peça deitada)
                if (tem_telhas) {
                    for (f = [0 : qtd_fileiras - 1]) {
                        x_f = f * larg_fileira;
                        translate([x_f, comp_y, espessura_base - 0.02])
                            rotate([90, 0, 0])
                                linear_extrude(height = comp_y)
                                    perfil_fileira_telha(
                                        larg_fileira + 0.05,
                                        0,
                                        altura_telha,
                                        sobreposicao_mm
                                    );
                    }
                }
            }

            // Furos alinhados com os pinos do topo das paredes de 50x50 mm
            // Na parede: pinos ficam em X_parede e Y = espessura_parede / 2
            angulo_rampa = atan2(altura_pico, metade_base + beiral_lateral);

            for (m = [0 : qtd_modulos_y - 1]) {
                for (i = [1 : qtd_pinos_topo]) {
                    x_parede = (lado_parede / (qtd_pinos_topo + 1)) * i;
                    dist_rampa = (beiral_lateral + x_parede) / cos(angulo_rampa);

                    y_na_peca = beiral_frente + (m * lado_parede) + (espessura_parede / 2);

                    translate([dist_rampa, y_na_peca, -0.1])
                        furo_encaixe(raio_pino, altura_furo, folga_encaixe);
                }
            }
        }
    }
}

agua_telhado_deitada();