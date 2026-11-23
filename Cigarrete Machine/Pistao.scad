// =========================================================
// INJETOR MANUAL BASCULANTE - KING SIZE (84mm x 8mm)
// VERSÃO OTIMIZADA (PARAMÉTRICA, LIMPA E PRONTA PARA EXPORTAR)
// =========================================================

$fn = 72;

// --- PARÂMETROS DE MERCADO E TOLERÂNCIA ---
comp_total_tubo  = 84.0;
comp_filtro      = 16.0;
comp_camara      = comp_total_tubo - comp_filtro; // 68.0 mm

diam_tubo_ext    = 8.0;
diam_bico_ext    = 7.35; // Vestir tubo de 8.0 mm sem rasgar
esp_parede_bico  = 1.25;
diam_furo_bico   = diam_bico_ext - (2 * esp_parede_bico); // 4.85 mm

comp_bico        = 17.0;
comp_bico_offset = 4.0;
folga_movel      = 0.22; // Folga por face em trilhos e articulações

// --- CÂMARA DE ACOMODAÇÃO DO TABACO ---
diam_camara_fumo = 6.2;  // Acomoda o fumo solto antes da redução no bico
larg_corpo       = 24.0;
alt_base_camara  = 12.0;
curso_pistao     = comp_camara + comp_bico - 2.0; // 83.0 mm

// --- DOBRADIÇA TRASEIRA ---
diam_pino_eixo   = 2.1;  // Para filamento 1.75 mm ou pino/arame fino
y_eixo_hinge     = -comp_camara / 2 - 7.5;
z_eixo_hinge     = alt_base_camara + 3.5;

// --- SELETOR DE PEÇA ("todas", "base", "tampa", "pistao") ---
peca = "todas";

if (peca == "todas") {
    translate([-44, 0, 0]) base_basculante();
    translate([0, 0, 0])   tampa_articulada();
    translate([44, 0, 0])  pistao_linear();
} else if (peca == "base") {
    base_basculante();
} else if (peca == "tampa") {
    tampa_articulada();
} else if (peca == "pistao") {
    pistao_linear();
}

// =========================================================
// 1. BASE: CALHA ABERTA, FUNIL, BICO CONTÍNUO E DOBRADIÇA
// =========================================================
module base_basculante() {
    y_ini = -comp_camara / 2;
    y_fim =  comp_camara / 2;
    larg_canal_t = 6.0 + 2 * folga_movel;
    larg_aba_t   = 10.0 + 2 * folga_movel;

    difference() {
        union() {
            // Corpo principal apoiado em Z=0
            translate([-larg_corpo / 2, y_ini - 3, 0])
                cube([larg_corpo, comp_camara + comp_bico_offset + 3, alt_base_camara]);

            // Orelhas laterais para o pino da dobradiça
            for (lado = [-1, 1]) {
                translate([lado * (larg_corpo / 2 - 3.5), y_eixo_hinge - 4.5, 0])
                    cube([3.5, 9.0, z_eixo_hinge + 4.5]);
            }

            // Bico tubular inteiriço com chanfro frontal
            translate([0, y_fim + comp_bico_offset, alt_base_camara])
                rotate([-90, 0, 0])
                    bico_com_chanfro(comp_bico, diam_bico_ext, diam_furo_bico);
        }

        // Calha cilíndrica para acomodar o tabaco
        translate([0, y_ini - 1.0, alt_base_camara])
            rotate([-90, 0, 0])
                cylinder(h = comp_camara + 2.0, d = diam_camara_fumo);

        // Abertura superior para inserir o tabaco
        translate([-(diam_camara_fumo + 2.0) / 2, y_ini - 1.0, alt_base_camara])
            cube([diam_camara_fumo + 2.0, comp_camara + 2.0, 4.0]);

        // Transição cônica da câmara para o diâmetro interno do bico
        translate([0, y_fim + 0.5, alt_base_camara])
            rotate([-90, 0, 0])
                cylinder(h = 4.0, d1 = diam_camara_fumo, d2 = diam_furo_bico);

        // Furo passante do bico
        translate([0, y_fim + comp_bico_offset - 0.2, alt_base_camara])
            rotate([-90, 0, 0])
                cylinder(h = comp_bico + 0.5, d = diam_furo_bico);

        // Trilho inferior em "T" invertido
        translate([-larg_canal_t / 2, y_ini - 3.2, -0.1])
            cube([larg_canal_t, comp_camara + comp_bico_offset + 3.5, 2.5]);
        translate([-larg_aba_t / 2, y_ini - 3.2, 2.1])
            cube([larg_aba_t, comp_camara + comp_bico_offset + 3.5, 1.8]);

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
// 2. TAMPA ARTICULADA: FECHAMENTO E ACOMODAÇÃO SUPERIOR
// =========================================================
module tampa_articulada() {
    y_ini      = -comp_camara / 2;
    larg_miolo = larg_corpo - 4 - 2 * folga_movel;
    alt_tampa  = 7.5;
    comp_braco = abs(y_ini - (y_eixo_hinge - 3.5));

    difference() {
        union() {
            // Corpo central (apoiado plano em Z=0)
            translate([-larg_miolo / 2, y_ini, 0])
                cube([larg_miolo, comp_camara + 1.0, alt_tampa - 2.0]);

            // Aba superior externa de contenção
            translate([-larg_corpo / 2, y_ini, alt_tampa - 2.0])
                cube([larg_corpo, comp_camara + 1.5, 2.0]);

            // Braço traseiro entre as orelhas da base
            translate([-3.2, y_eixo_hinge - 3.5, 0])
                cube([6.4, comp_braco, alt_tampa - 2.0]);
        }

        // Canaleta superior para acomodar o tabaco sem pinçar nas bordas
        translate([0, y_ini - 0.2, 0])
            rotate([-90, 0, 0])
                cylinder(h = comp_camara + 1.4, d = diam_camara_fumo);

        // Furo do pino da dobradiça
        translate([-10, y_eixo_hinge, 3.5])
            rotate([0, 90, 0])
                cylinder(h = 20, d = diam_pino_eixo);
    }
}

// =========================================================
// 3. PISTÃO LINEAR: HASTE REFORÇADA E GUIA INFERIOR
// =========================================================
module pistao_linear() {
    y_ini           = -comp_camara / 2;
    diam_haste      = diam_furo_bico - (2 * folga_movel); // ~4.41 mm
    comp_bloco_tras = 12.0;

    union() {
        // Bloco traseiro de empunhadura
        translate([-larg_corpo / 2, y_ini - comp_bloco_tras, 0])
            cube([larg_corpo, comp_bloco_tras, alt_base_camara + 3.5]);

        // Guia inferior para o trilho "T" da base
        translate([-3.0, y_ini - comp_bloco_tras, 0])
            cube([6.0, comp_camara + comp_bloco_tras, 2.4]);
        translate([-5.0, y_ini - comp_bloco_tras, 2.1])
            cube([10.0, comp_camara + comp_bloco_tras, 1.6]);

        // Coluna estrutural de conexão (avança 3 mm na base da haste)
        translate([-diam_haste / 2, y_ini - 2.0, 0])
            cube([diam_haste, 5.0, alt_base_camara + 1.5]);

        // Haste cilíndrica com base plana anti-ovalização
        translate([0, y_ini + 2.0, alt_base_camara])
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