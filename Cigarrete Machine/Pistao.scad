// =========================================================
// INJETOR MANUAL PARA TUBOS KING SIZE (84mm x 8mm) - REV. 2
// =========================================================

$fn = 72;

// --- PARÂMETROS DE MERCADO E TOLERÂNCIA ---
comp_total_tubo = 84.0;
comp_filtro     = 16.0;
comp_camara     = comp_total_tubo - comp_filtro; // 68.0 mm

diam_tubo_ext   = 8.0;
diam_bico_ext   = 7.35; // Folga radial para vestir tubo de 8mm sem rasgar
esp_parede_bico = 1.25; // Parede robusta para não trincar
diam_furo_bico  = diam_bico_ext - (2 * esp_parede_bico); // 4.85 mm

comp_bico       = 17.0; // Comprimento útil para encaixar o tubo
folga_movel     = 0.20; // Folga por face em partes deslizantes/encaixes

// --- DIMENSÕES DO CORPO ---
larg_corpo      = 24.0;
alt_base_camara = 11.5;
comp_bloco      = comp_camara + 8.0; // Margem frontal e traseira

// --- SELETOR: "todas", "base", "tampa", "pistao" ---
peca = "todas";

if (peca == "todas") {
    translate([-42, 0, 0]) base_injetor();
    translate([0, 0, 0])   tampa_prensadora();
    translate([42, 0, 0])  pistao_empurrador();
} else if (peca == "base") {
    base_injetor();
} else if (peca == "tampa") {
    tampa_prensadora();
} else if (peca == "pistao") {
    pistao_empurrador();
}

// =========================================================
// 1. BASE: CÂMARA + BICO TUBULAR INTEIRIÇO + TRILHO INFERIOR
// =========================================================
module base_injetor() {
    y_ini = -comp_camara / 2;
    y_fim =  comp_camara / 2;
    z_eixo = alt_base_camara;

    difference() {
        union() {
            // Bloco principal
            translate([-larg_corpo/2, y_ini - 4, 0])
                cube([larg_corpo, comp_camara + 8, alt_base_camara]);

            // Abas laterais ergonômicas na frente
            translate([-(larg_corpo + 18)/2, y_fim - 12, 0])
                cube([larg_corpo + 18, 12, alt_base_camara]);

            // Bico tubular contínuo (evita abertura longitudinal sob pressão)
            translate([0, y_fim, z_eixo])
                rotate([-90, 0, 0])
                    bico_com_chanfro(comp_bico, diam_bico_ext, diam_furo_bico);
        }

        // Calha semicircular inferior da câmara
        translate([0, y_ini - 0.2, z_eixo])
            rotate([-90, 0, 0])
                cylinder(h = comp_camara + 0.4, d = diam_furo_bico + 0.6);

        // Transição cônica (funil) da câmara para o furo do bico
        translate([0, y_fim - 0.1, z_eixo])
            rotate([-90, 0, 0])
                cylinder(h = 4.0, d1 = diam_furo_bico + 0.6, d2 = diam_furo_bico);

        // Furo passante do bico
        translate([0, y_fim - 0.2, z_eixo])
            rotate([-90, 0, 0])
                cylinder(h = comp_bico + 0.5, d = diam_furo_bico);

        // Trilho inferior em "T" invertido com folga controlada
        translate([-(6.0 + 2*folga_movel)/2, y_ini - 4.2, -0.1])
            cube([6.0 + 2*folga_movel, comp_camara + 8.4, 2.6]);
        translate([-(10.0 + 2*folga_movel)/2, y_ini - 4.2, 2.2])
            cube([10.0 + 2*folga_movel, comp_camara + 8.4, 2.0]);

        // Rebaixo de assentamento da tampa (evita deslocamento lateral)
        translate([-(larg_corpo - 4)/2, y_ini, alt_base_camara - 1.2])
            cube([larg_corpo - 4, comp_camara, 1.4]);
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
// 2. TAMPA: FECHAMENTO SUPERIOR + GUIA DE ALIMENTAÇÃO
// =========================================================
module tampa_prensadora() {
    y_ini = -comp_camara / 2;
    alt_tampa = 7.5;

    difference() {
        union() {
            // Corpo da tampa apoiado plano em Z=0 para impressão
            translate([-(larg_corpo - 4 - 2*folga_movel)/2, y_ini, 0])
                cube([larg_corpo - 4 - 2*folga_movel, comp_camara, alt_tampa]);

            // Aba superior externa de contenção (impede que a tampa suba)
            translate([-larg_corpo/2, y_ini, alt_tampa - 2.0])
                cube([larg_corpo, comp_camara, 2.0]);
        }

        // Canaleta superior de alívio/prensagem
        translate([0, y_ini - 0.2, 0])
            rotate([-90, 0, 0])
                cylinder(h = comp_camara + 0.4, d = diam_furo_bico + 0.4);
    }
}

// =========================================================
// 3. PISTÃO: HASTE COM BASE CHANFRADA + GUIA DO TRILHO
// =========================================================
module pistao_empurrador() {
    y_ini = -comp_camara / 2;
    comp_haste = comp_camara + comp_bico - 3.0;
    diam_haste = diam_furo_bico - (2 * folga_movel);

    union() {
        // Cabo traseiro
        translate([-larg_corpo/2, y_ini - 14, 0])
            cube([larg_corpo, 10, alt_base_camara + 4]);

        // Guia inferior do trilho (com folga de 0.20 mm por lado)
        translate([-3.0, y_ini - 14, 0])
            cube([6.0, comp_camara + 10, 2.5]);
        translate([-5.0, y_ini - 14, 2.2])
            cube([10.0, comp_camara + 10, 1.8]);

        // Coluna estrutural traseira
        translate([-diam_haste/2, y_ini - 4, 0])
            cube([diam_haste, 4.5, alt_base_camara]);

        // Haste cilíndrica com chanfro inferior (evita ovalização na mesa)
        translate([0, y_ini, alt_base_camara])
            rotate([-90, 0, 0])
                haste_anti_oval(comp_haste, diam_haste);
    }
}

module haste_anti_oval(comp, diam) {
    r = diam / 2;
    // Corta levemente a base (-Z no espaço local antes da rotação)
    // para criar uma pequena base plana que impede deformação no espelho
    intersection() {
        cylinder(h = comp, d = diam);
        translate([-r - 1, -r + 0.35, -0.1])
            cube([diam + 2, diam + 1, comp + 0.2]);
    }
}