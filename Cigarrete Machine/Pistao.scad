// =========================================================
// INJETOR MANUAL BASCULANTE - KING SIZE (84mm x 8mm)
// REV. 6 - CORRIGIDO E AUDITADO (EIXOS, DOBRADIÇA E TRILHO)
// =========================================================

$fn = 64; // Resolução otimizada para gerar o STL rápido

// --- PARÂMETROS DE MERCADO E TOLERÂNCIA ---
comp_total_tubo  = 84.0;
comp_filtro      = 16.0;
comp_camara      = comp_total_tubo - comp_filtro; // 68.0 mm

diam_tubo_ext    = 8.0;
diam_bico_ext    = 7.35; // Folga para o tubo de 8mm
esp_parede_bico  = 1.25;
diam_furo_bico   = diam_bico_ext - (2 * esp_parede_bico); // 4.85 mm

comp_bico        = 17.0;
folga_movel      = 0.25; // Folga segura para impressão FDM

// --- DIMENSÕES DO CORPO E CÂMARA ---
larg_corpo       = 24.0;
alt_base_camara  = 12.0;
diam_camara_fumo = 6.5;   // Câmara de fumo levemente maior que o bico
curso_pistao     = comp_camara + comp_bico - 2.0; 

// --- DOBRADIÇA TRASEIRA ---
diam_pino_eixo   = 1.9;   // Para passar filamento 1.75mm (com folga)
y_eixo_hinge     = -comp_camara/2 - 8.0;
z_eixo_hinge     = alt_base_camara + 2.0; // Altura em relação a Z=0

// --- SELETOR DE PEÇA ("todas", "base", "tampa", "pistao") ---
peca = "todas";

if (peca == "todas") {
    translate([-45, 0, 0]) base_basculante();
    translate([0, 0, 0])   tampa_articulada();
    translate([45, 0, 0])  pistao_linear();
} else if (peca == "base") {
    base_basculante();
} else if (peca == "tampa") {
    tampa_articulada();
} else if (peca == "pistao") {
    pistao_linear();
}

// =========================================================
// 1. BASE: BICO INTEGRADO, CALHA DE FURO E TRILHO
// =========================================================
module base_basculante() {
    y_ini = -comp_camara / 2;
    y_fim =  comp_camara / 2;

    difference() {
        union() {
            // Corpo principal (fundo até a metade da câmara)
            translate([-larg_corpo/2, y_ini - 4, 0])
                cube([larg_corpo, comp_camara + comp_bico + 8, alt_base_camara - 1.5]);

            // Corpo frontal do bico (integrado à base)
            translate([-larg_corpo/2, y_fim + 4, 0])
                cube([larg_corpo, comp_bico, alt_base_camara]);

            // Orelhas laterais traseiras para a dobradiça
            for (lado = [-1, 1]) {
                translate([lado * (larg_corpo/2 - 3), y_eixo_hinge - 3, 0])
                    cube([3, 6, z_eixo_hinge + 3]);
            }
            
            // Bico frontal (ponta cônica/reta) unificado à base
            translate([0, y_fim + comp_bico + 4, alt_base_camara])
                rotate([-90, 0, 0])
                    bico_com_chanfro(comp_bico, diam_bico_ext, diam_furo_bico);
        }

        // Calha de fumo (aberta no topo)
        translate([0, y_ini - 1, alt_base_camara])
            rotate([-90, 0, 0])
                cylinder(h = comp_camara + 2, d = diam_camara_fumo);

        // Abertura superior para o fumo descer
        translate([-diam_camara_fumo/2, y_ini - 4, alt_base_camara - 1.0])
            cube([diam_camara_fumo, comp_camara + 8, 5.0]);

        // Funil de transição (da câmara de 6.5mm para o furo do bico de 4.85mm)
        translate([0, y_fim + 2, alt_base_camara])
            rotate([-90, 0, 0])
                cylinder(h = 4.0, d1 = diam_camara_fumo, d2 = diam_furo_bico);

        // Furo passante do bico
        translate([0, y_fim + 2, alt_base_camara])
            rotate([-90, 0, 0])
                cylinder(h = comp_bico + 4, d = diam_furo_bico);

        // Trilho guia (T invertido)
        translate([-(8 + 2*folga_movel)/2, y_ini - 4, -0.1])
            cube([8 + 2*folga_movel, comp_camara + comp_bico + 8, 2.5]);
        translate([-(12 + 2*folga_movel)/2, y_ini - 4, 2.1])
            cube([12 + 2*folga_movel, comp_camara + comp_bico + 8, 1.8]);

        // Furo passante do eixo da dobradiça (atravessa as duas orelhas)
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
                cylinder(h = chanfro, d1 = d_ext, d2 = d_ext - 1.0);
        }
        translate([0, 0, -0.2])
            cylinder(h = comp + 0.5, d = d_int);
    }
}

// =========================================================
// 2. TAMPA ARTICULADA (LÍNGUA DE PRENSAR)
// =========================================================
module tampa_articulada() {
    y_ini = -comp_camara / 2;
    larg_miolo = larg_corpo - 4 - 2*folga_movel;
    alt_tampa = 7.0;

    difference() {
        union() {
            // Corpo da tampa
            translate([-larg_miolo/2, y_ini, 0])
                cube([larg_miolo, comp_camara + 1.0, alt_tampa]);

            // Braço da dobradiça
            translate([-3, y_eixo_hinge - 3, 0])
                cube([6, abs(y_ini - (y_eixo_hinge - 3)), alt_tampa]);

            // Língua de prensar o fumo (desce dentro da calha da base)
            translate([-diam_camara_fumo/2 + 0.1, y_ini, -2.0])
                cube([diam_camara_fumo - 0.2, comp_camara, 3.0]);
        }

        // Furo passante da dobradiça no braço da tampa
        translate([-5, y_eixo_hinge, z_eixo_hinge])
            rotate([0, 90, 0])
                cylinder(h = 10, d = diam_pino_eixo);
    }
}

// =========================================================
// 3. PISTÃO LINEAR (HASTE E TRILHO)
// =========================================================
module pistao_linear() {
    y_ini = -comp_camara / 2;
    diam_haste = diam_furo_bico - (2 * folga_movel);

    union() {
        // Bloco traseiro
        translate([-larg_corpo/2, y_ini - 15, 0])
            cube([larg_corpo, 12, alt_base_camara + 3]);

        // Guia inferior (encaixa no trilho T da base)
        translate([-4.0, y_ini - 15, 0])
            cube([8.0, comp_camara + 15, 2.4]);
        translate([-6.0, y_ini - 15, 2.1])
            cube([12.0, comp_camara + 15, 1.6]);

        // Haste cilíndrica (passa pelo funil e pelo bico)
        translate([0, y_ini - 3, alt_base_camara])
            rotate([-90, 0, 0])
                haste_anti_oval(curso_pistao, diam_haste);
    }
}

module haste_anti_oval(comp, diam) {
    r = diam / 2;
    intersection() {
        cylinder(h = comp, d = diam);
        // Corte para base plana na mesa
        translate([-r - 1, -r + 0.35, -0.1])
            cube([diam + 2, diam + 1, comp + 0.2]);
    }
}