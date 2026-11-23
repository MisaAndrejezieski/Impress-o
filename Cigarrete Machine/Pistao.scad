// =========================================================
// INJETOR MANUAL BASCVULANTE PARA TUBOS KING SIZE (84mm x 8mm)
// ADAPTAÇÃO COMPACTA (SEM MANIVELA / CREMALHEIRA)
// =========================================================

$fn = 72;

// --- PARÂMETROS DE MERCADO E TOLERÂNCIA ---
comp_total_tubo = 84.0;
comp_filtro     = 16.0;
comp_camara     = comp_total_tubo - comp_filtro; // 68.0 mm

diam_tubo_ext   = 8.0;
diam_bico_ext   = 7.35; // Folga radial para vestir tubo de 8mm sem rasgar
esp_parede_bico = 1.25;
diam_furo_bico  = diam_bico_ext - (2 * esp_parede_bico); // 4.85 mm

comp_bico       = 17.0;
folga_movel     = 0.22; // Folga por face em partes móveis/articuladas

// --- DIMENSÕES DO CORPO ---
larg_corpo      = 22.0;
alt_base_camara = 11.0;
comp_bico_offset = 4.0;
curso_pistao    = comp_camara + comp_bico - 2.5; // 82.5 mm

// --- PARÂMETROS DA DOBRADIÇA TRASEIRA ---
diam_pino_eixo  = 2.1; // Passa um pedaço de filamento 1.75mm ou arame fino
y_eixo_hinge    = -comp_camara/2 - 5.5;
z_eixo_hinge    = alt_base_camara + 3.5;

// --- SELETOR: "todas", "base", "tampa", "pistao" ---
peca = "todas";

if (peca == "todas") {
    translate([-38, 0, 0]) base_basculante();
    translate([0, 0, 0])   tampa_articulada();
    translate([38, 0, 0])  pistao_linear();
} else if (peca == "base") {
    base_basculante();
} else if (peca == "tampa") {
    tampa_articulada();
} else if (peca == "pistao") {
    pistao_linear();
}

// =========================================================
// 1. BASE COM CALHA, BICO CONTÍNUO E MANCAL DE DOBRADIÇA
// =========================================================
module base_basculante() {
    y_ini = -comp_camara / 2;
    y_fim =  comp_camara / 2;

    difference() {
        union() {
            // Bloco principal
            translate([-larg_corpo/2, y_ini - 3, 0])
                cube([larg_corpo, comp_camara + comp_bico_offset + 3, alt_base_camara]);

            // Orelhas laterais traseiras para a dobradiça da tampa
            for (lado = [-1, 1]) {
                translate([lado * (larg_corpo/2 - 3.5), y_eixo_hinge - 4.5, 0])
                    cube([3.5, 9.0, z_eixo_hinge + 4.5]);
            }

            // Bico tubular contínuo
            translate([0, y_fim + comp_bico_offset, alt_base_camara])
                rotate([-90, 0, 0])
                    bico_com_chanfro(comp_bico, diam_bico_ext, diam_furo_bico);
        }

        // Calha semicircular da câmara de tabaco
        translate([0, y_ini - 3.2, alt_base_camara])
            rotate([-90, 0, 0])
                cylinder(h = comp_camara + comp_bico_offset + 3.5, d = diam_furo_bico + 0.6);

        // Funil de transição suave para o bico
        translate([0, y_fim + 0.5, alt_base_camara])
            rotate([-90, 0, 0])
                cylinder(h = 3.8, d1 = diam_furo_bico + 0.6, d2 = diam_furo_bico);

        // Furo passante do bico
        translate([0, y_fim + comp_bico_offset - 0.2, alt_base_camara])
            rotate([-90, 0, 0])
                cylinder(h = comp_bico + 0.5, d = diam_furo_bico);

        // Trilho guia inferior em "T" invertido para o pistão
        translate([-(6.0 + 2*folga_movel)/2, y_ini - 3.2, -0.1])
            cube([6.0 + 2*folga_movel, comp_camara + comp_bico_offset + 3.5, 2.5]);
        translate([-(10.0 + 2*folga_movel)/2, y_ini - 3.2, 2.1])
            cube([10.0 + 2*folga_movel, comp_camara + comp_bico_offset + 3.5, 1.8]);

        // Rebaixo superior para assentar a tampa quando fechada
        translate([-(larg_corpo - 4)/2, y_ini, alt_base_camara - 1.0])
            cube([larg_corpo - 4, comp_camara + 1.0, 1.2]);

        // Furo transversal do eixo da dobradiça
        translate([-larg_corpo, y_eixo_hinge, z_eixo_hinge])
            rotate([0, 90, 0])
                cylinder(h = larg_corpo * 2, d = diam_pino_eixo);
    }
}

module bico_com_chanfro(comp, d_ext, d_int) {
    chanfro = 1.2;
    difference() {
        union() {
            cylinder(h = comp - chanfro, d = d_ext);
            translate([0, 0, comp - chanfro])
                cylinder(h = chanfro, d1 = d_ext, d2 = d_ext - 1.1);
        }
        translate([0, 0, -0.2])
            cylinder(h = comp + 0.5, d = d_int);
    }
}

// =========================================================
// 2. TAMPA ARTICULADA (IMPRIME DEITADA / PLANA EM Z=0)
// =========================================================
module tampa_articulada() {
    y_ini = -comp_camara / 2;
    larg_miolo = larg_corpo - 4 - 2*folga_movel;
    alt_tampa = 7.0;

    difference() {
        union() {
            // Corpo principal da tampa
            translate([-larg_miolo/2, y_ini, 0])
                cube([larg_miolo, comp_camara + 1.0, alt_tampa - 1.8]);

            // Aba superior mais larga que trava sobre a base ao fechar
            translate([-larg_corpo/2, y_ini, alt_tampa - 1.8])
                cube([larg_corpo, comp_camara + 1.5, 1.8]);

            // Braço traseiro central que entra entre as orelhas da base
            translate([-3.2, y_eixo_hinge - 3.5, 0])
                cube([6.4, abs(y_ini - (y_eixo_hinge - 3.5)), alt_tampa - 1.8]);
        }

        // Canaleta de fechamento/compressão do tabaco
        translate([0, y_ini - 0.2, 0])
            rotate([-90, 0, 0])
                cylinder(h = comp_camara + 1.4, d = diam_furo_bico + 0.4);

        // Furo do eixo da dobradiça na aba traseira da tampa
        // (alinhado com z_eixo_hinge quando fechada; aqui impresso plano em Z=0,
        // mas o furo fica a 3.5mm da face inferior para aceitar o pino)
        translate([-10, y_eixo_hinge, 3.5])
            rotate([0, 90, 0])
                cylinder(h = 20, d = diam_pino_eixo);
    }
}

// =========================================================
// 3. PISTÃO LINEAR SIMPLES
// =========================================================
module pistao_linear() {
    y_ini = -comp_camara / 2;
    diam_haste = diam_furo_bico - (2 * folga_movel);

    union() {
        // Cabo traseiro de empurrar com o polegar
        translate([-larg_corpo/2, y_ini - 13, 0])
            cube([larg_corpo, 10, alt_base_camara + 3.5]);

        // Guia do trilho inferior
        translate([-3.0, y_ini - 13, 0])
            cube([6.0, comp_camara + 10, 2.4]);
        translate([-5.0, y_ini - 13, 2.1])
            cube([10.0, comp_camara + 10, 1.6]);

        // Coluna estrutural traseira
        translate([-diam_haste/2, y_ini - 3, 0])
            cube([diam_haste, 4.0, alt_base_camara]);

        // Haste cilíndrica com base plana anti-ovalização
        translate([0, y_ini, alt_base_camara])
            rotate([-90, 0, 0])
                haste_anti_oval(curso_pistao, diam_haste);
    }
}

module haste_anti_oval(comp, diam) {
    r = diam / 2;
    intersection() {
        cylinder(h = comp, d = diam);
        translate([-r - 1, -r + 0.35, -0.1])
            cube([diam + 2, diam + 1, comp + 0.2]);
    }
}