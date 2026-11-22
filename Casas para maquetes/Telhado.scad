// =========================================================
// AGUA DO TELHADO (40% INCLINACAO) - AUDITADO OPENSCAD 2021.01
// Sistema modular 50x50 mm | Espessura da parede: 8 mm
// Pino: raio 2.5 mm, altura 4.0 mm | Folga: 0.25 mm
// =========================================================

lado_parede      = 50;
espessura_parede = 8;
qtd_modulos_y    = 1;       // 1 = 50 mm, 2 = 100 mm

inclinacao_pct   = 40;      // 40% de inclinacao -> atan(0.40) = 21.80 graus
beiral_lateral   = 4;
beiral_frente    = 3;
espessura_base   = 5.0;

// --- Telhas ---
tem_telhas       = true;
qtd_fileiras     = 5;
altura_telha     = 2.2;
prof_canal       = 0.8;     // Profundidade do canal entre telhas

// --- Encaixe (pino da parede: raio 2.5 mm, folga 0.25 mm) ---
raio_pino        = 2.5;
altura_pino      = 4.0;
folga_encaixe    = 0.25;
qtd_pinos_topo   = 2;

$fn = 48;

// Furo inclinado atravessando a base para alojar o pino com folga
module furo_pino_inclinado(r, folga, ang_incl, prof_total) {
    raio_furo = r + folga;
    // Inclina o eixo do furo conforme a inclinacao da rampa (40%)
    rotate([0, -ang_incl, 0])
        translate([0, 0, -0.5])
            cylinder(h = prof_total + 1.0, r = raio_furo);
}

// Perfil 2D de cada telha com canal lateral e aba arredondada
module perfil_telha_2d(larg, h_base, h_telha, canal) {
    passos = 28;
    dx = larg / passos;

    pts_baixo = [
        [larg, 0],
        [0, 0]
    ];

    pts_cima = [
        for (i = [0 : passos])
            let(
                u = i / passos,
                // Aba principal arredondada + pequeno canal rebaixado na transicao
                aba = h_telha * sin(180 * u),
                cava = (u < 0.15) ? (-canal * sin(180 * (u / 0.15))) : 0,
                z_topo = max(0.5, h_base + aba + cava)
            )
            [i * dx, z_topo]
    ];

    polygon(points = concat(pts_baixo, pts_cima));
}

module agua_telhado_deitada() {
    ang_rampa   = atan(inclinacao_pct / 100); // ~21.80 graus
    metade_base = lado_parede / 2;            // 25 mm
    alcance_x   = metade_base + beiral_lateral;
    larg_rampa  = alcance_x / cos(ang_rampa);
    comp_y      = (lado_parede * qtd_modulos_y) + (2 * beiral_frente);

    larg_fileira = larg_rampa / qtd_fileiras;
    prof_furo    = (altura_pino + 0.5) / cos(ang_rampa);

    translate([-larg_rampa / 2, -comp_y / 2, 0]) {
        difference() {
            union() {
                cube([larg_rampa, comp_y, espessura_base]);

                if (tem_telhas) {
                    for (f = [0 : qtd_fileiras - 1]) {
                        x_f = f * larg_fileira;
                        translate([x_f, comp_y, espessura_base - 0.02])
                            rotate([90, 0, 0])
                                linear_extrude(height = comp_y)
                                    perfil_telha_2d(
                                        larg_fileira + 0.04,
                                        0,
                                        altura_telha,
                                        prof_canal
                                    );
                    }
                }
            }

            // Furos inclinados alinhados com os pinos da parede que ficam sob esta meia-agua
            for (m = [0 : qtd_modulos_y - 1]) {
                for (i = [1 : qtd_pinos_topo]) {
                    pos_na_parede = (lado_parede / (qtd_pinos_topo + 1)) * i;
                    if (pos_na_parede <= metade_base) {
                        dist_na_rampa = (beiral_lateral + pos_na_parede) / cos(ang_rampa);
                        y_na_peca = beiral_frente + (m * lado_parede) + (espessura_parede / 2);

                        translate([dist_na_rampa, y_na_peca, 0])
                            furo_pino_inclinado(
                                raio_pino,
                                folga_encaixe,
                                ang_rampa,
                                prof_furo
                            );
                    }
                }
            }
        }
    }
}

agua_telhado_deitada();