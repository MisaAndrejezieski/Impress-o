// =========================================================
// SISTEMA DE CASINHA MODULAR - PAREDE 50x50, QUINA E TELHADO
// Auditado para OpenSCAD 2021.01
// =========================================================

// --- Escolha da peca para renderizar / exportar STL ---
// Opcoes: "parede", "quina", "telhado", "montagem_teste"
tipo_peca = "parede";

// --- Dimensoes principais (em mm) ---
lado_parede = 50;          // Parede quadrada: 50 x 50 mm
espessura = 8;             // Espessura da parede e da quina
qtd_paredes_vao = 2;       // Quantidade de paredes de 50 mm no comprimento da casa

// --- Parametros dos pinos e encaixes ---
raio_pino = 2.5;           // Raio nominal do pino
altura_pino = 4.0;         // Altura util do pino
folga_encaixe = 0.25;      // Folga no furo (ajuste conforme teste na Ender 3)
qtd_pinos_lateral = 2;     // Encaixes na altura da parede/quina
qtd_pinos_topo = 2;        // Encaixes no topo da parede (50 mm)
tem_pinos_topo = true;     // Ativa/desativa pinos superiores na parede

// --- Parametros do telhado ---
altura_cumeeira = 26;      // Altura do pico do telhado acima do topo da parede
espessura_telha = 5;       // Espessura da placa de telhado
beiral = 6;                // Beiral externo alem da face da parede

// Resolucao de cilindros
$fn = 48;

// Pino cilindrico com ponta chanfrada para facilitar o encaixe infantil
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

// Furo com folga para receber o pino
module furo_encaixe(r, h, folga) {
    cylinder(h = h + folga + 0.1, r = r + folga);
}

// Parede quadrada 50x50 mm
module parede_50x50() {
    union() {
        difference() {
            cube([lado_parede, espessura, lado_parede]);

            // Furos na lateral direita (+X)
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

// Canto/quina de 90 graus com altura de 50 mm
module quina_90() {
    difference() {
        cube([espessura, espessura, lado_parede]);

        // Furos na face +X
        for (i = [1 : qtd_pinos_lateral]) {
            z_pos = (lado_parede / (qtd_pinos_lateral + 1)) * i;
            translate([
                espessura - (altura_pino + folga_encaixe),
                espessura / 2,
                z_pos
            ])
            rotate([0, 90, 0])
                furo_encaixe(raio_pino, altura_pino, folga_encaixe);
        }

        // Furos na face +Y
        for (i = [1 : qtd_pinos_lateral]) {
            z_pos = (lado_parede / (qtd_pinos_lateral + 1)) * i;
            translate([
                espessura / 2,
                espessura - (altura_pino + folga_encaixe),
                z_pos
            ])
            rotate([-90, 0, 0])
                furo_encaixe(raio_pino, altura_pino, folga_encaixe);
        }
    }
}

// Agua/placa do telhado com furos alinhados aos pinos do topo das paredes
module placa_telhado() {
    comprimento_total = lado_parede * qtd_paredes_vao;
    metade_vao = lado_parede / 2;
    comp_rampa = sqrt(pow(metade_vao + beiral, 2) + pow(altura_cumeeira, 2));
    angulo_rampa = atan2(altura_cumeeira, metade_vao + beiral);

    difference() {
        rotate([0, angulo_rampa, 0])
            cube([comp_rampa, comprimento_total, espessura_telha]);

        // Furos na parte inferior da placa ao longo da rampa e das paredes
        for (p = [0 : qtd_paredes_vao - 1]) {
            for (j = [1 : qtd_pinos_topo]) {
                x_local = (lado_parede / (qtd_pinos_topo + 1)) * j;
                dist_rampa = x_local / cos(angulo_rampa);
                y_furo = (p * lado_parede) + (espessura / 2);

                rotate([0, angulo_rampa, 0])
                    translate([dist_rampa, y_furo, -0.05])
                        furo_encaixe(raio_pino, altura_pino, folga_encaixe);
            }
        }
    }
}

// Selecao da peca ativa
if (tipo_peca == "quina") {
    quina_90();
} else if (tipo_peca == "telhado") {
    placa_telhado();
} else if (tipo_peca == "montagem_teste") {
    parede_50x50();
    translate([0, 0, lado_parede + altura_pino + 2])
        placa_telhado();
} else {
    parede_50x50();
}