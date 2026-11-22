// =========================================================
// AGUA DO TELHADO (40% INCLINACAO, FURACAO INCLINADA)
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
beiral_frente    = 3;       // Sobrinha nas extremidades ao longo do comprimento
espessura_base   = 4.0;     // Base plana da telha (garante corpo ao redor do furo inclinado)

// --- Formato das telhas (fileiras ao longo da rampa) ---
tem_telhas       = true;    // Ativa o formato de telhas
qtd_fileiras     = 5;       // Quantidade de fileiras de telhas
altura_telha     = 2.2;     // Altura do relevo da telha
sobreposicao_mm  = 1.2;     // Degrau de sobreposicao entre fileiras

// --- Encaixes (pinos verticais da parede: raio 2.5 mm, altura 4.0 mm, folga 0.25 mm) ---
raio_pino        = 2.5;
altura_pino      = 4.0;
folga_encaixe    = 0.25;
qtd_pinos_topo   = 2;

$fn = 48;

// Furo inclinado para receber pino vertical quando a rampa esta a 40%
// ang_incl: angulo da rampa em graus (atan(inclinacao_pct / 100))
// sentido_x: +1 se a rampa sobe para +X na mesa, -1 se sobe para -X
module furo_inclinado(r, h_pino, folga, ang_incl, sentido_x = 1) {
    raio_furo = r + folga;
    // Ao cortar um cilindro vertical (eixo Z na casa) com uma rampa inclinada por ang_incl,
    // a secao na rampa alonga por 1/cos(ang_incl) na direcao da inclinacao.
    escala_x = 1 / cos(ang_incl);
    profundidade_furo = (h_pino / cos(ang_incl)) + 1.0;

    // Inclina o eixo do furo em ang_incl em torno de Y
    rotate([0, -sentido_x * ang_incl, 0])
        scale([escala_x, 1, 1])
            cylinder(h = profundidade_furo, r = raio_furo);
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
    ang_rampa = atan(inclinacao_pct / 100); // ~21.80 graus para 40%
    metade_base = lado_parede / 2;         // 25 mm sobre a parede de 50 mm
    alcance_x = metade_base + beiral_lateral;
    larg_rampa = alcance_x / cos(ang_rampa);
    comp_y = (lado_parede * qtd_modulos_y) + (2 * beiral_frente);

    larg_fileira = larg_rampa / qtd_fileiras;

    // Na peca deitada: x = 0 corresponde a borda externa (beiral), e x cresce subindo ate o pico
    translate([-larg_rampa / 2, -comp_y / 2, 0]) {
        difference() {
            union() {
                // Base solida apoiada na mesa (Z = 0)
                cube([larg_rampa, comp_y, espessura_base]);

                // Fileiras de telhas ao longo da rampa
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

            // Furos inclinados alinhados com os pinos verticais do topo da parede
            for (m = [0 : qtd_modulos_y - 1]) {
                for (i = [1 : qtd_pinos_topo]) {
                    x_parede = (lado_parede / (qtd_pinos_topo + 1)) * i;
                    dist_na_rampa = (beiral_lateral + x_parede) / cos(ang_rampa);
                    y_na_peca = beiral_frente + (m * lado_parede) + (espessura_parede / 2);

                    translate([dist_na_rampa, y_na_peca, -0.1])
                        furo_inclinado(
                            raio_pino,
                            altura_pino,
                            folga_encaixe,
                            ang_rampa,
                            sentido_x = 1
                        );
                }
            }
        }
    }
}

agua_telhado_deitada();