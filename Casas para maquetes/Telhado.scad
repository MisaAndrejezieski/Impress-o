// =========================================================
// AGUA DO TELHADO (40% INCLINACAO) - CASINHA MODULAR 50x50
// Auditado e validado para OpenSCAD 2021.01
// Furo redondo limpo por baixo e teto fechado por cima
// =========================================================

// --- Modo de visualizacao / exportacao ---
// "impressao"      -> deitada em Z=0 e centralizada (pronta para STL / Ender 3)
// "montagem_teste" -> inclinada a 40% sobre parede 50x50 de referencia
modo = "impressao";

// --- Dimensoes do sistema modular (50x50 mm, parede 8 mm) ---
lado_parede      = 50;      // Passo modular da parede
espessura_parede = 8;       // Espessura da parede
qtd_modulos_y    = 1;       // 1 = 50 mm (1 parede), 2 = 100 mm (2 paredes)

// --- Inclinacao e geometria da agua do telhado ---
inclinacao_pct   = 40;      // 40% de inclinacao -> atan(0.40) = 21.80 graus
beiral_lateral   = 4;       // Sobrinha na borda externa da rampa
beiral_frente    = 3;       // Sobrinha nas extremidades ao longo de Y
espessura_base   = 8.0;     // Espessura da base para manter o teto fechado em cima

// --- Formato das telhas (relevo nitido com degrau e calha) ---
tem_telhas       = true;
qtd_fileiras     = 5;       // Quantidade de fileiras de telhas ao longo da rampa
altura_telha     = 2.6;     // Altura do relevo da telha
degrau_telha     = 1.4;     // Degrau frontal da telha
prof_calha       = 0.7;     // Rebaixo da calha lateral

// --- Encaixe (pino vertical da parede: raio 2.5 mm, altura 4.0 mm, folga 0.25 mm) ---
raio_pino        = 2.5;     // Raio nominal do pino da parede
altura_pino      = 4.0;     // Altura util do pino da parede
folga_encaixe    = 0.25;    // Folga no furo
qtd_pinos_topo   = 2;       // 2 pinos por parede de 50 mm

$fn = 64;

// Furo cilindrico redondo inclinado a 40%:
// - Comeca bem abaixo de Z=0 (-2.5) para o plano Z=0 cortar um circulo completo (sem meia-lua)
// - Termina antes do topo (max ~5.0 no eixo inclinado) para nao varar o teto
module furo_encaixe_limpo(r, h_pino, folga, ang_incl) {
    raio_furo = r + folga;
    z_inicio  = -2.5;
    // Profundidade util para o pino de 4.0 mm entrar com folga, sem chegar ao topo
    z_fim     = min(espessura_base - 1.2, h_pino + folga + 0.6);

    rotate([0, -ang_incl, 0])
        translate([0, 0, z_inicio])
            cylinder(h = z_fim - z_inicio, r = raio_furo);
}

// Perfil 2D de uma telha com degrau frontal e calha lateral bem marcados
module perfil_telha_nitido_2d(larg, h_base, h_telha, degrau, calha) {
    passos = 36;
    dx = larg / passos;

    pts_baixo = [
        [larg, 0],
        [0, 0]
    ];

    pts_cima = [
        for (i = [0 : passos])
            let(
                u = i / passos,
                deg_z = (u < 0.14) ? (degrau * (1 - u / 0.14)) : 0,
                corpo_z = (u >= 0.10) ? (h_telha * pow(sin(180 * ((u - 0.10) / 0.90)), 0.55)) : 0,
                calha_z = (u > 0.78) ? (-calha * sin(180 * ((u - 0.78) / 0.22))) : 0,
                z_val = max(0.4, h_base + deg_z + corpo_z + calha_z)
            )
            [i * dx, z_val]
    ];

    polygon(points = concat(pts_baixo, pts_cima));
}

// Agua do telhado deitada em Z=0 e centralizada em X e Y
module agua_telhado_deitada() {
    ang_rampa   = atan(inclinacao_pct / 100); // ~21.80 graus
    metade_base = lado_parede / 2;            // 25 mm
    alcance_x   = metade_base + beiral_lateral;
    larg_rampa  = alcance_x / cos(ang_rampa);
    comp_y      = (lado_parede * qtd_modulos_y) + (2 * beiral_frente);

    larg_fileira = larg_rampa / qtd_fileiras;

    translate([-larg_rampa / 2, -comp_y / 2, 0]) {
        difference() {
            union() {
                // Base apoiada em Z = 0
                cube([larg_rampa, comp_y, espessura_base]);

                // Fileiras de telhas
                if (tem_telhas) {
                    for (f = [0 : qtd_fileiras - 1]) {
                        x_f = f * larg_fileira;
                        translate([x_f, comp_y, espessura_base - 0.02])
                            rotate([90, 0, 0])
                                linear_extrude(height = comp_y)
                                    perfil_telha_nitido_2d(
                                        larg_fileira + 0.04,
                                        0,
                                        altura_telha,
                                        degrau_telha,
                                        prof_calha
                                    );
                    }
                }
            }

            // Furos redondos inclinados alinhados com os pinos da parede sob esta agua
            for (m = [0 : qtd_modulos_y - 1]) {
                for (i = [1 : qtd_pinos_topo]) {
                    pos_na_parede = (lado_parede / (qtd_pinos_topo + 1)) * i;
                    if (pos_na_parede <= metade_base) {
                        dist_na_rampa = (beiral_lateral + pos_na_parede) / cos(ang_rampa);
                        y_na_peca = beiral_frente + (m * lado_parede) + (espessura_parede / 2);

                        translate([dist_na_rampa, y_na_peca, 0])
                            furo_encaixe_limpo(
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

// Parede de referencia de 50x50 mm (espessura 8 mm) com pinos verticais no topo
module parede_referencia_50x50() {
    union() {
        cube([lado_parede, espessura_parede, lado_parede]);
        for (i = [1 : qtd_pinos_topo]) {
            x_p = (lado_parede / (qtd_pinos_topo + 1)) * i;
            translate([x_p, espessura_parede / 2, lado_parede - 0.01])
                cylinder(h = altura_pino, r = raio_pino);
        }
    }
}

// --- Execucao ---
if (modo == "montagem_teste") {
    ang_rampa   = atan(inclinacao_pct / 100);
    metade_base = lado_parede / 2;
    alcance_x   = metade_base + beiral_lateral;
    larg_rampa  = alcance_x / cos(ang_rampa);
    comp_y      = (lado_parede * qtd_modulos_y) + (2 * beiral_frente);

    for (m = [0 : qtd_modulos_y - 1]) {
        translate([0, m * lado_parede, 0])
            parede_referencia_50x50();
    }

    translate([lado_parede + beiral_lateral, (lado_parede * qtd_modulos_y) / 2, lado_parede])
        rotate([0, -ang_rampa, 0])
            translate([larg_rampa / 2, 0, 0])
                agua_telhado_deitada();
} else {
    agua_telhado_deitada();
}