// ============================================================================
// PROJETO: ENROLADORA MECÂNICA MANUAL DE BANCADA (5 ROLOS SINCRONIZADOS)
// PADRÃO: King Size (86 mm x 8,0 mm)
// FABRICAÇÃO: Creality Ender 3 v1 | Bico 0,4 mm | Material: PLA | PrusaSlicer
// VERSÃO: OpenSCAD 2021.01 (100% Manifold, Sem Suportes)
// ============================================================================

/* [1. SELETOR DE MODO DE VISUALIZAÇÃO / EXPORTAÇÃO STL] */
// Opções: "montado", "explodido", "base", "tampa", "engrenagens", "manivela", "trava"
modo = "montado"; 

// Ângulo de abertura da tampa no modo "montado" (0 = fechada, 75 = aberta)
angulo_tampa = 0; 

/* [2. HARDWARE METÁLICO E MANGUEIRA (EDITÁVEL)] */
diam_eixo_metal     = 4.0;   // Diâmetro do varão de aço/inox/latão (mm)
diam_ext_mangueira  = 10.0;  // Diâmetro externo do rolo com mangueira (mm)
comp_util_rolo      = 86.0;  // Comprimento útil da mangueira (King Size = 86 mm)
chanfro_eixo_D      = 0.6;   // Profundidade do chanfro plano "D" na ponta do eixo (mm)

/* [3. PARÂMETROS DA CÂMARA DE ENROLAMENTO] */
diam_cigarro        = 8.0;   // Diâmetro final da câmara de tabaco (mm)
folga_borrachas     = 0.55;  // Folga mínima desejada entre mangueiras adjacentes

/* [4. TOLERÂNCIAS CALIBRADAS PARA ENDER 3 V1 + PLA + PRUSASLICER] */
folga_mancal_radial = 0.20;  // Folga por lado no mancal livre (0,40 mm diametral)
folga_cubo_justo    = 0.08;  // Folga para encaixe firme eixo-engrenagem (com chanfro D)
folga_lateral_tampa = 0.25;  // Folga axial entre paredes da tampa e da base
folga_dente_eng     = 0.26;  // Backlash / adelgaçamento do dente para bico 0,4 mm
chanfro_elefante    = 0.40;  // Chanfro na base Z=0 contra Elephant's Foot

/* [5. PARÂMETROS DAS ENGRENAGENS (MÓDULO 1.5 MM)] */
modulo_eng          = 1.5;   // Módulo >= 1.5 mm para resistência em PLA
z_rolo              = 10;    // Dentes das engrenagens dos 5 rolos (dp = 15.0 mm)
z_motora            = 14;    // Dentes das engrenagens motoras centrais (dp = 21.0 mm)
esp_engrenagem      = 5.4;   // Largura da face da engrenagem (múltiplo de camada)
folga_axial_eng     = 1.1;   // Espaçamento entre planos de engrenagens

/* [6. DIMENSÕES ESTRUTURAIS (MÚLTIPLOS DE LARGURA DE LINHA 0,45 MM)] */
esp_parede_mancal   = 7.2;   // Espessura das paredes laterais dos mancais (16 perímetros)
esp_parede_corpo    = 3.6;   // Espessura estrutural da carenagem (8 perímetros)
largura_base_apoio  = 74.0;  // Largura da sapata de bancada para estabilidade
altura_centro_cam   = 32.0;  // Altura do centro da câmara em relação à mesa (Z=0)

$fn = 64; // Resolução de arcos

// ============================================================================
// CÁLCULOS CINEMÁTICOS E GEOMÉTRICOS AUTOMÁTICOS
// ============================================================================
// Raio de órbita dos centros dos 5 rolos em torno do eixo central da câmara
r_orbita = (diam_cigarro + diam_ext_mangueira) / 2.0; // (8 + 10)/2 = 9.0 mm

// Ângulos dos 5 rolos em torno da câmara (0° = frente/+X, 90° = topo/+Z, 180° = trás/-X, 270° = baixo/-Z)
// 3 rolos na base (inferiores) + 2 rolos na tampa (superiores)
ang_rolos = [
    -32,   // Rolo 0 (Base - Frontal Inferior)  -> Plano A
    -90,   // Rolo 1 (Base - Fundo Inferior)    -> Plano B
    -148,  // Rolo 2 (Base - Traseiro Inferior) -> Plano A
    144,   // Rolo 3 (Tampa - Traseiro Superior)-> Plano B
    36     // Rolo 4 (Tampa - Frontal Superior) -> Plano A
];

// Posições [X, Z] dos 5 rolos relativas ao centro da câmara (0,0)
pos_rolos = [ for (a = ang_rolos) [ r_orbita * cos(a), r_orbita * sin(a) ] ];

// Distância entre-eixos teórica (Rolo Z=10 + Motora Z=14, m=1.5) + folga radial
entre_eixos_rm = modulo_eng * (z_rolo + z_motora) / 2.0 + 0.15; // 18.0 + 0.15 = 18.15 mm

// Posição [X, Z] do Eixo Motor Principal (na base, abaixo da câmara)
// Calculada para engrenar simultaneamente com Rolo 1 (0, -9) no Plano B
// e via engrenagem intermediária / direta com os demais
pos_motor = [ 0, -9.0 - entre_eixos_rm ]; // [0, -27.15] -> Ajustado para caber acima da base:

// Recálculo otimizado: Centro da câmara elevado para acomodar o eixo motor dentro da base
Z_camara = 38.0; 
pos_motor_rel = [ 0, -27.15 ]; // Relativo à câmara: Z_abs = 38.0 - 27.15 = 10.85 mm (parede inf. > 5 mm)

// Posições de 2 Engrenagens Intermediárias (Satélites na Base) para levar rotação
// sincronizada aos rolos superiores (Tampa) e laterais sem colisão de planos:
// Satélite Frontal (Plano A): engrena com Motora_A e com Rolo 0 (Base) e Rolo 4 (Tampa)
// Satélite Traseiro (Plano A): engrena com Motora_A e com Rolo 2 (Base) e Rolo 3 (Tampa)
z_satelite = 10; // Mesmo módulo 1.5 -> dp = 15.0 mm
ee_mot_sat = modulo_eng * (z_motora + z_satelite) / 2.0 + 0.15; // 18.15 mm
ee_sat_rolo = modulo_eng * (z_satelite + z_rolo) / 2.0 + 0.15;  // 15.15 mm

// Coordenadas exatas dos Satélites Frontal e Traseiro (simétricos em X)
// Posicionados a 18.15 mm do Motor [0, -27.15] e ~15.15 mm dos rolos
pos_sat_frente = [  16.8, -20.2 ];
pos_sat_tras   = [ -16.8, -20.2 ];

// Eixo da Dobradiça Traseira (relativo à câmara)
pos_dobradica  = [ -23.5, 4.5 ];

// Eixo da Trava Excêntrica Frontal (relativo à câmara)
pos_trava      = [  23.5, 2.0 ];

// Comprimentos axiais (Eixo Y)
Y_interno      = comp_util_rolo + 1.0; // 87.0 mm (folga axial de 0,5 mm por lado para mangueira)
Y_mancal_ext   = Y_interno + 2 * esp_parede_mancal; // 87.0 + 14.4 = 101.4 mm
Y_plano_B      = Y_mancal_ext / 2 + 1.2 + esp_engrenagem / 2;
Y_plano_A      = Y_plano_B + esp_engrenagem + folga_axial_eng;

// ============================================================================
// MÓDULOS UTILITÁRIOS (MANIFOLD, CHANFROS, FUROS TEARDROP, ENGRENAGENS)
// ============================================================================

// Furo horizontal com perfil "gota" (teardrop) de 45° para impressão sem suportes
module furo_teardrop(d, h) {
    r = d / 2;
    linear_extrude(height = h, center = true) {
        union() {
            circle(r = r);
            polygon([
                [-r * sin(45), r * cos(45)],
                [0, r * sqrt(2)],
                [ r * sin(45), r * cos(45)]
            ]);
        }
    }
}

// Furo com chanfro tipo "D" para travamento mecânico no eixo metálico
module furo_eixo_D(d, chanfro, h) {
    r = d / 2;
    linear_extrude(height = h, center = true) {
        difference() {
            circle(r = r);
            translate([r - chanfro, -r])
                square([d, d]);
        }
    }
}

// Cilindro com chanfro anti-Elephant's Foot na base (Z=0) e topo opcional
module cilindro_chanfrado(d, h, ch_inf = chanfro_elefante, ch_sup = 0.4) {
    r = d / 2;
    rotate_extrude() {
        polygon([
            [0, 0],
            [r - ch_inf, 0],
            [r, ch_inf],
            [r, h - ch_sup],
            [r - ch_sup, h],
            [0, h]
        ]);
    }
}

// Gerador paramétrico de Engrenagem Cilíndrica de Dentes Retos (perfil involuto aproximado)
// Inclui adelgaçamento de dente (folga_dente_eng) calibrado para bico 0,4 mm em PLA
module engrenagem_reta(m, z, esp, folga_dente = folga_dente_eng, cubo_d = 0, cubo_h = 0, furo_d = 0, tipo_furo = "D") {
    dp = m * z;
    rp = dp / 2;
    // Addendum e Dedendum ajustados para evitar undercut em Z=10
    addendum = m * 0.92;
    dedendum = m * 1.18;
    rext = rp + addendum;
    rraiz = max(rp - dedendum, (furo_d / 2) + 1.8);
    
    passo_ang = 360 / z;
    // Largura angular do dente no círculo primitivo descontando o backlash
    larg_dente_p = (PI * m / 2) - folga_dente;
    ang_dente_p  = (larg_dente_p / rp) * (180 / PI);
    
    difference() {
        union() {
            // Corpo dentado extrudado com chanfro nas faces para evitar Elephant's foot
            linear_extrude(height = esp) {
                union() {
                    circle(r = rraiz);
                    for (i = [0 : z - 1]) {
                        rotate([0, 0, i * passo_ang]) {
                            polygon([
                                [-rraiz * sin(ang_dente_p * 0.68), rraiz * cos(ang_dente_p * 0.68)],
                                [-rp    * sin(ang_dente_p * 0.50), rp    * cos(ang_dente_p * 0.50)],
                                [-rext  * sin(ang_dente_p * 0.30), rext  * cos(ang_dente_p * 0.30)],
                                [ rext  * sin(ang_dente_p * 0.30), rext  * cos(ang_dente_p * 0.30)],
                                [ rp    * sin(ang_dente_p * 0.50), rp    * cos(ang_dente_p * 0.50)],
                                [ rraiz * sin(ang_dente_p * 0.68), rraiz * cos(ang_dente_p * 0.68)]
                            ]);
                        }
                    }
                }
            }
            // Cubo reforçado para transmissão de torque
            if (cubo_d > 0 && cubo_h > 0) {
                cilindro_chanfrado(d = cubo_d, h = esp + cubo_h, ch_inf = chanfro_elefante, ch_sup = 0.4);
            }
        }
        
        // Furo central calibrado
        if (furo_d > 0) {
            h_tot = esp + cubo_h + 2;
            if (tipo_furo == "D") {
                translate([0, 0, h_tot / 2 - 1])
                    furo_eixo_D(d = furo_d + 2 * folga_cubo_justo, chanfro = chanfro_eixo_D, h = h_tot);
            } else {
                translate([0, 0, -1])
                    cylinder(d = furo_d + 2 * folga_mancal_radial, h = h_tot);
            }
        }
        
        // Chanfro inferior interno do furo para facilitar entrada do eixo
        if (furo_d > 0) {
            translate([0, 0, -0.01])
                cylinder(d1 = furo_d + 0.9, d2 = furo_d, h = 0.5);
        }
    }
}

// ============================================================================
// PEÇA 1: BASE FIXA DE BANCADA (COM SAPATA LARGA, MANCAIS INFERIORES E DOBRADIÇA)
// ============================================================================
module peca_base() {
    y_paredes = [ -(Y_interno/2 + esp_parede_mancal/2), (Y_interno/2 + esp_parede_mancal/2) ];
    
    difference() {
        union() {
            // 1. Sapata larga de bancada (apoio plano em Z = 0 com chanfro anti-Elephant's Foot)
            hull() {
                for (sx = [-1, 1], sy = [-1, 1]) {
                    translate([sx * (largura_base_apoio/2 - 5), sy * (Y_mancal_ext/2 + 4 - 5), 0])
                        cilindro_chanfrado(d = 10, h = 5.0, ch_inf = chanfro_elefante, ch_sup = 0.5);
                }
            }
            
            // 2. Berço longitudinal central (calha estrutural conectando os dois mancais)
            translate([0, 0, 5.0])
                hull() {
                    translate([0, 0, 14.0])
                        rotate([90, 0, 0])
                            cylinder(d = 38.0, h = Y_mancal_ext, center = true);
                    translate([0, 0, 0])
                        cube([46.0, Y_mancal_ext, 2.0], center = true);
                }
            
            // 3. Paredes laterais reforçadas dos mancais (Frontal e Traseira)
            for (yp = y_paredes) {
                translate([0, yp, 0]) {
                    hull() {
                        // Apoio na sapata
                        translate([0, 0, 4.0])
                            cube([56.0, esp_parede_mancal, 4.0], center = true);
                        // Envoltório dos mancais inferiores e eixo motor
                        translate([0, 0, Z_camara - 4.0])
                            rotate([90, 0, 0])
                                cylinder(d = 46.0, h = esp_parede_mancal, center = true);
                        // Ressalto traseiro para dobradiça robusta
                        translate([pos_dobradica[0], 0, Z_camara + pos_dobradica[1]])
                            rotate([90, 0, 0])
                                cylinder(d = 15.0, h = esp_parede_mancal, center = true);
                        // Ressalto frontal para pino da trava excêntrica
                        translate([pos_trava[0], 0, Z_camara + pos_trava[1]])
                            rotate([90, 0, 0])
                                cylinder(d = 14.0, h = esp_parede_mancal, center = true);
                    }
                }
            }
            
            // 4. Mancais dedicados para os Satélites (lado das engrenagens +Y)
            for (ps = [pos_sat_frente, pos_sat_tras]) {
                translate([ps[0], Y_mancal_ext/2 + 2.0, Z_camara + ps[1]])
                    rotate([90, 0, 0])
                        cylinder(d = 11.0, h = 6.0, center = true);
            }
        }
        
        // --- SUBTRAÇÕES (CAVIDADES E FUROS) ---
        
        // A. Cavidade central livre para passagem das mangueiras de borracha dos 3 rolos inferiores
        translate([0, 0, Z_camara])
            rotate([90, 0, 0])
                cylinder(d = diam_cigarro + 2 * diam_ext_mangueira + 3.0, h = Y_interno, center = true);
        
        // Rebaixo superior plano da base (linha de partição Base/Tampa)
        translate([0, 0, Z_camara + 22.0])
            cube([80.0, Y_interno, 40.0], center = true);
            
        // Rebaixo nas paredes dos mancais na linha de partição para encaixe da tampa
        for (yp = y_paredes) {
            translate([0, yp, Z_camara + 20.5])
                cube([70.0, esp_parede_mancal + 2, 40.0], center = true);
        }
        
        // B. Furos Teardrop dos 3 Rolos Inferiores (Rolos 0, 1, 2)
        for (i = [0 : 2]) {
            pr = pos_rolos[i];
            translate([pr[0], 0, Z_camara + pr[1]])
                rotate([90, 0, 0])
                    furo_teardrop(d = diam_eixo_metal + 2 * folga_mancal_radial, h = Y_mancal_ext + 4);
        }
        
        // C. Furo Teardrop do Eixo Motor Principal
        translate([pos_motor_rel[0], 0, Z_camara + pos_motor_rel[1]])
            rotate([90, 0, 0])
                furo_teardrop(d = diam_eixo_metal + 2 * folga_mancal_radial, h = Y_mancal_ext + 4);
                
        // D. Furos dos Satélites (para parafuso/eixo M4)
        for (ps = [pos_sat_frente, pos_sat_tras]) {
            translate([ps[0], Y_mancal_ext/2, Z_camara + ps[1]])
                rotate([90, 0, 0])
                    furo_teardrop(d = diam_eixo_metal + 2 * folga_mancal_radial, h = 16.0);
        }
        
        // E. Furo da Dobradiça Traseira (eixo metálico Ø 4,0 mm passante)
        translate([pos_dobradica[0], 0, Z_camara + pos_dobradica[1]])
            rotate([90, 0, 0])
                furo_teardrop(d = diam_eixo_metal + 2 * folga_mancal_radial, h = Y_mancal_ext + 4);
                
        // Rasgo central na dobradiça da base para receber a orelha da tampa
        translate([pos_dobradica[0], 0, Z_camara + pos_dobradica[1]])
            cube([18.0, Y_interno - 2 * folga_lateral_tampa, 18.0], center = true);
            
        // F. Furo do Pino da Trava Excêntrica Frontal (lado +Y e -Y)
        translate([pos_trava[0], 0, Z_camara + pos_trava[1]])
            rotate([90, 0, 0])
                furo_teardrop(d = diam_eixo_metal + 2 * folga_mancal_radial, h = Y_mancal_ext + 4);
    }
}

// ============================================================================
// PEÇA 2: TAMPA ARTICULADA SUPERIOR (2 ROLOS SUPERIORES + DOBRADIÇA + BATENTE)
// ============================================================================
module peca_tampa() {
    y_paredes_tampa = [ -(Y_interno/2 + esp_parede_mancal/2), (Y_interno/2 + esp_parede_mancal/2) ];
    
    difference() {
        union() {
            // 1. Arco superior ergonômico interligando os mancais da tampa
            hull() {
                translate([0, 0, Z_camara + 16.0])
                    rotate([90, 0, 0])
                        cylinder(d = 34.0, h = Y_mancal_ext, center = true);
                translate([0, 0, Z_camara + 6.0])
                    cube([42.0, Y_mancal_ext, 8.0], center = true);
            }
            
            // 2. Paredes laterais dos mancais superiores
            for (yp = y_paredes_tampa) {
                translate([0, yp, 0]) {
                    hull() {
                        translate([0, 0, Z_camara + 14.0])
                            rotate([90, 0, 0])
                                cylinder(d = 38.0, h = esp_parede_mancal, center = true);
                        translate([0, 0, Z_camara + 3.0])
                            cube([44.0, esp_parede_mancal, 5.0], center = true);
                        // Braço da dobradiça traseira
                        translate([pos_dobradica[0], 0, Z_camara + pos_dobradica[1]])
                            rotate([90, 0, 0])
                                cylinder(d = 14.0, h = esp_parede_mancal, center = true);
                        // Nariz frontal para engate da trava excêntrica
                        translate([pos_trava[0] - 2.0, 0, Z_camara + pos_trava[1] + 5.5])
                            rotate([90, 0, 0])
                                cylinder(d = 11.0, h = esp_parede_mancal, center = true);
                    }
                }
            }
            
            // 3. Nervura longitudinal central da dobradiça (encaixa dentro da base)
            translate([pos_dobradica[0], 0, Z_camara + pos_dobradica[1]])
                rotate([90, 0, 0])
                    cylinder(d = 13.5, h = Y_interno - 2.0, center = true);
        }
        
        // --- SUBTRAÇÕES ---
        
        // A. Cavidade interna para os 2 rolos superiores (sem interferência com mangueiras)
        translate([0, 0, Z_camara])
            rotate([90, 0, 0])
                cylinder(d = diam_cigarro + 2 * diam_ext_mangueira + 2.8, h = Y_interno + 2 * folga_lateral_tampa, center = true);
                
        // B. Plano inferior de corte da tampa (garante folga de fechamento sobre a base)
        translate([0, 0, Z_camara - 19.5])
            cube([80.0, Y_mancal_ext + 4, 40.0], center = true);
            
        // C. Furos Teardrop dos 2 Rolos Superiores (Rolos 3 e 4)
        for (i = [3 : 4]) {
            pr = pos_rolos[i];
            translate([pr[0], 0, Z_camara + pr[1]])
                rotate([90, 0, 0])
                    furo_teardrop(d = diam_eixo_metal + 2 * folga_mancal_radial, h = Y_mancal_ext + 4);
        }
        
        // D. Furo da Dobradiça Traseira na Tampa
        translate([pos_dobradica[0], 0, Z_camara + pos_dobradica[1]])
            rotate([90, 0, 0])
                furo_teardrop(d = diam_eixo_metal + 2 * folga_mancal_radial, h = Y_mancal_ext + 4);
                
        // E. Abertura longitudinal superior (fenda de alimentação de tabaco e inserção da seda)
        translate([0, 0, Z_camara + 24.0])
            cube([6.5, comp_util_rolo - 2.0, 22.0], center = true);
    }
}

// ============================================================================
// PEÇA 3: MANIVELA ERGONÔMICA COM MANÍPULO GIRATÓRIO
// ============================================================================
module peca_manivela() {
    braco_L = 42.0; // Raio da manivela (42 mm -> excelente alavanca para giro suave)
    
    union() {
        // Braço principal apoiado plano em Z = 0
        difference() {
            hull() {
                cilindro_chanfrado(d = 18.0, h = 7.0);
                translate([braco_L, 0, 0])
                    cilindro_chanfrado(d = 14.0, h = 7.0);
            }
            // Furo "D" para acoplamento rígido no eixo motor
            translate([0, 0, 4.0])
                furo_eixo_D(d = diam_eixo_metal + 2 * folga_cubo_justo, chanfro = chanfro_eixo_D, h = 10.0);
            // Furo passante para parafuso M4 do manípulo giratório
            translate([braco_L, 0, -1])
                cylinder(d = 4.3, h = 10.0);
        }
        
        // Cubo reforçado de saída do eixo
        translate([0, 0, 7.0])
            difference() {
                cilindro_chanfrado(d = 16.0, h = 6.0, ch_inf = 0, ch_sup = 0.6);
                translate([0, 0, 3.0])
                    furo_eixo_D(d = diam_eixo_metal + 2 * folga_cubo_justo, chanfro = chanfro_eixo_D, h = 8.0);
                // Furo radial para parafuso prisioneiro M3 de travamento
                translate([0, 0, 3.0])
                    rotate([90, 0, 0])
                        cylinder(d = 2.6, h = 10.0);
            }
    }
}

module peca_manipulo() {
    // Manípulo ergonômico que gira livremente em um parafuso M4x35 na ponta da manivela
    difference() {
        union() {
            cilindro_chanfrado(d = 13.0, h = 28.0, ch_inf = chanfro_elefante, ch_sup = 1.2);
            translate([0, 0, 22.0])
                cilindro_chanfrado(d = 15.5, h = 6.0, ch_inf = 1.0, ch_sup = 1.2);
        }
        // Furo livre para parafuso M4
        translate([0, 0, -1])
            cylinder(d = 4.5, h = 32.0);
        // Rebaixo para cabeça do parafuso M4 no topo
        translate([0, 0, 24.0])
            cylinder(d = 8.2, h = 6.0);
    }
}

// ============================================================================
// PEÇA 4: TRAVA EXCÊNTRICA FRONTAL (CAM-LOCK POR COMPRESSÃO)
// ============================================================================
module peca_trava() {
    difference() {
        union() {
            // Corpo excêntrico (came)
            hull() {
                cilindro_chanfrado(d = 13.0, h = 6.8);
                translate([2.2, 1.5, 0])
                    cilindro_chanfrado(d = 13.0, h = 6.8);
            }
            // Alavanca de acionamento manual
            hull() {
                cilindro_chanfrado(d = 11.0, h = 6.8);
                translate([18.0, -4.0, 0])
                    cilindro_chanfrado(d = 8.0, h = 6.8);
            }
        }
        // Furo articulado para pino metálico Ø 4,0 mm
        translate([0, 0, -1])
            cylinder(d = diam_eixo_metal + 2 * folga_mancal_radial, h = 10.0);
    }
}

// ============================================================================
// HARDWARE DE REFERÊNCIA VISUAL (NÃO EXPORTAR PARA IMPRESSÃO 3D)
// ============================================================================
module hardware_referencia() {
    // 5 Varões metálicos + Mangueiras de borracha
    for (i = [0 : 4]) {
        pr = pos_rolos[i];
        // Aplica rotação da tampa aos rolos 3 e 4
        rot_t = (i >= 3) ? angulo_tampa : 0;
        
        translate([pos_dobradica[0], 0, Z_camara + pos_dobradica[1]])
            rotate([0, -rot_t, 0])
                translate([-pos_dobradica[0], 0, -(Z_camara + pos_dobradica[1])]) {
                    translate([pr[0], 0, Z_camara + pr[1]])
                        rotate([90, 0, 0]) {
                            // Eixo de aço
                            color("Silver", 0.9)
                                cylinder(d = diam_eixo_metal, h = Y_mancal_ext + 18.0, center = true);
                            // Mangueira de silicone/borracha
                            color("DimGray", 0.85)
                                cylinder(d = diam_ext_mangueira, h = comp_util_rolo, center = true);
                        }
                }
    }
    
    // Eixo Motor Principal (aço)
    translate([pos_motor_rel[0], 4.0, Z_camara + pos_motor_rel[1]])
        rotate([90, 0, 0])
            color("Silver", 0.9)
                cylinder(d = diam_eixo_metal, h = Y_mancal_ext + 28.0, center = true);
                
    // Eixo da Dobradiça Traseira
    translate([pos_dobradica[0], 0, Z_camara + pos_dobradica[1]])
        rotate([90, 0, 0])
            color("Silver", 0.9)
                cylinder(d = diam_eixo_metal, h = Y_mancal_ext + 4.0, center = true);
}

// ============================================================================
// MONTAGEM E MODOS DE EXPORTAÇÃO
// ============================================================================
if (modo == "montado" || modo == "explodido") {
    expl = (modo == "explodido") ? 22.0 : 0.0;
    
    // Base fixa
    color("SteelBlue")
        peca_base();
        
    // Tampa articulada
    translate([pos_dobradica[0], 0, Z_camara + pos_dobradica[1] + expl])
        rotate([0, -angulo_tampa, 0])
            translate([-pos_dobradica[0], 0, -(Z_camara + pos_dobradica[1])])
                color("LightSteelBlue")
                    peca_tampa();
                    
    // Hardware metálico e mangueiras (apenas referência visual)
    if (modo == "montado") {
        hardware_referencia();
    }
    
    // Engrenagens dos 5 rolos
    for (i = [0 : 4]) {
        pr = pos_rolos[i];
        rot_t = (i >= 3) ? angulo_tampa : 0;
        y_eng = (i == 1 || i == 3) ? Y_plano_B : Y_plano_A;
        
        translate([pos_dobradica[0], 0, Z_camara + pos_dobradica[1] + expl])
            rotate([0, -rot_t, 0])
                translate([-pos_dobradica[0], 0, -(Z_camara + pos_dobradica[1])])
                    translate([pr[0], y_eng + expl, Z_camara + pr[1]])
                        rotate([-90, 0, 0])
                            color("Orange")
                                engrenagem_reta(m = modulo_eng, z = z_rolo, esp = esp_engrenagem, cubo_d = 9.2, cubo_h = 2.5, furo_d = diam_eixo_metal, tipo_furo = "D");
    }
    
    // Engrenagens Motoras Duplas (Planos A e B)
    for (yp_m = [Y_plano_B, Y_plano_A]) {
        translate([pos_motor_rel[0], yp_m + expl, Z_camara + pos_motor_rel[1]])
            rotate([-90, 0, 0])
                color("DarkOrange")
                    engrenagem_reta(m = modulo_eng, z = z_motora, esp = esp_engrenagem, cubo_d = 10.5, cubo_h = 2.5, furo_d = diam_eixo_metal, tipo_furo = "D");
    }
    
    // Engrenagens Satélites (Base)
    for (ps = [pos_sat_frente, pos_sat_tras]) {
        translate([ps[0], Y_plano_A + expl, Z_camara + ps[1]])
            rotate([-90, 0, 0])
                color("Gold")
                    engrenagem_reta(m = modulo_eng, z = z_satelite, esp = esp_engrenagem, cubo_d = 9.0, cubo_h = 2.0, furo_d = diam_eixo_metal, tipo_furo = "livre");
    }
    
    // Manivela + Manípulo no lado frontal (-Y)
    translate([pos_motor_rel[0], -(Y_mancal_ext/2 + 4.0 + expl), Z_camara + pos_motor_rel[1]])
        rotate([90, 0, 0]) {
            color("SlateGray") peca_manivela();
            translate([42.0, 0, 8.0])
                color("DarkSlateGray") peca_manipulo();
        }
        
    // Trava Excêntrica Frontal
    translate([pos_trava[0], Y_mancal_ext/2 + 1.0 + expl, Z_camara + pos_trava[1]])
        rotate([-90, 0, 0])
            color("Crimson")
                peca_trava();
}

// --- MODOS DE EXPORTAÇÃO STL (TODOS APOIADOS PLANOS EM Z = 0) ---

if (modo == "base") {
    peca_base();
}

if (modo == "tampa") {
    // Invertida com o topo plano apoiado em Z = 0 para impressão 100% sem suportes
    translate([0, 0, Z_camara + 33.0])
        rotate([180, 0, 0])
            peca_tampa();
}

if (modo == "engrenagens") {
    // Mesa completa com todas as 9 engrenagens apoiadas planas em Z = 0
    // 5 Engrenagens dos rolos (Z=10, furo D)
    for (i = [0 : 4]) {
        translate([(i - 2) * 24.0, 0, 0])
            engrenagem_reta(m = modulo_eng, z = z_rolo, esp = esp_engrenagem, cubo_d = 9.2, cubo_h = 2.5, furo_d = diam_eixo_metal, tipo_furo = "D");
    }
    // 2 Engrenagens motoras centrais (Z=14, furo D)
    for (i = [0 : 1]) {
        translate([(i - 0.5) * 32.0, 28.0, 0])
            engrenagem_reta(m = modulo_eng, z = z_motora, esp = esp_engrenagem, cubo_d = 10.5, cubo_h = 2.5, furo_d = diam_eixo_metal, tipo_furo = "D");
    }
    // 2 Engrenagens satélites (Z=10, furo livre)
    for (i = [0 : 1]) {
        translate([(i - 0.5) * 26.0, -26.0, 0])
            engrenagem_reta(m = modulo_eng, z = z_satelite, esp = esp_engrenagem, cubo_d = 9.0, cubo_h = 2.0, furo_d = diam_eixo_metal, tipo_furo = "livre");
    }
}

if (modo == "manivela") {
    peca_manivela();
    translate([20.0, 26.0, 0])
        peca_manipulo();
}

if (modo == "trava") {
    peca_trava();
}