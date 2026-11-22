// =========================================================
// AGUA DO TELHADO 40% - FUROS REDONDOS INCLINADOS (SEM MEIA-LUA)
// Sistema Modular 50x50 mm | Espessura parede: 8 mm
// Auditado e validado para OpenSCAD 2021.01
// =========================================================

// --- Dimensoes do sistema modular (50x50 mm, parede 8 mm) ---
lado_parede      = 50;      // Passo modular da parede
espessura_parede = 8;       // Espessura da parede
qtd_modulos_y    = 1;       // 1 = 50 mm (1 parede), 2 = 100 mm (2 paredes)

// --- Inclinacao e geometria da agua do telhado ---
inclinacao_pct   = 40;      // 40% de inclinacao (atan(0.40) = 21.80 graus)
beiral_lateral   = 4;       // Sobrinha na borda externa da rampa
beiral_frente    = 3;       // Sobrinha nas extremidades ao longo de Y
espessura_base   = 5.5;     // Espessura suficiente para o furo de 4 mm nao varar em cima

// --- Formato das telhas ---
tem_telhas       = true;
qtd_fileiras     = 5;
altura_telha     = 2.0;
sobreposicao_mm  = 1.0;

// --- Encaixes (pinos verticais da parede: raio 2.5 mm, altura 4.0 mm, folga 0.25 mm) ---
raio_pino        = 2.5;
altura_pino      = 4.0;
folga_encaixe    = 0.25;
qtd_pinos_topo   = 2;       // 2 pinos por parede de 50 mm (em 16.67 mm e 33.33 mm)

$fn = 48;

// Furo cilindrico redondo inclinado a 40% (sem deformacao de meia-lua)
module furo_cilindrico_inclinado(r, h_pino, folga, ang_incl) {
    raio_furo = r + folga;
    // Comeca levemente abaixo de Z=0 (-0.2) para cortar limpo na face inferior
    rotate([0, -ang_incl, 0])
        translate([0, 0, -0.2])
            cylinder(h = h_pino + 0.4, r = raio_furo);
}

// Perfil 2D de uma fileira de telha
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
                curva = h_telha * pow(sin(180 * u), 0.75),
                deg = (u < 0.12) ? (degrau * (1 - u / 0.12)) : 0
            )
            [i * dx, h_base + curva + deg]
    ];

    polygon(points = concat(pts_baixo, pts_cima));
}

module agua_telhado_deitada() {
    ang_rampa   = atan(inclinacao_pct / 100); // 21.80 graus
    metade_base = lado_parede / 2;            // 25 mm (cada agua cobre metade da largura de 50 mm)
    alcance_x   = metade_base + beiral_lateral;
    larg_rampa  = alcance_x / cos(ang_rampa);
    comp_y      = (lado_parede * qtd_modulos_y) + (2 * beiral_frente);

    larg_fileira = larg_rampa / qtd_fileiras;

    // Centralizado em X e Y, apoiado em Z = 0
    translate([-larg_rampa / 2, -comp_y / 2, 0]) {
        difference() {
            union() {
                // Base solida
                cube([larg_rampa, comp_y, espessura_base]);

                // Fileiras de telhas
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

            // Furos redondos inclinados apenas para os pinos que caem sob esta agua (entre 0 e metade_base)
            for (m = [0 : qtd_modulos_y - 1]) {
                for (i = [1 : qtd_pinos_topo]) {
                    // Distancia medida da borda externa da parede (0 a 50 mm)
                    pos_na_parede = (lado_parede / (qtd_pinos_topo + 1)) * i;

                    // So fura se o pino estiver dentro da metade coberta por esta agua (<= 25 mm)
                    if (pos_na_parede <= metade_base) {
                        dist_na_rampa = (beiral_lateral + pos_na_parede) / cos(ang_rampa);
                        y_na_peca = beiral_frente + (m * lado_parede) + (espessura_parede / 2);

                        translate([dist_na_rampa, y_na_peca, 0])
                            furo_cilindrico_inclinado(
                                raio_pino,
                                altura_pino,
                                folga_encaixe,
                                ang_rampa
                            );
                    }
                }
            }
        }
    }
}

agua_telhado_deitada();