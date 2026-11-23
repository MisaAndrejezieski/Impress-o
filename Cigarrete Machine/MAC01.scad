// ============================================================================
// PROJETO: ENROLADORA MECÂNICA MANUAL DE BANCADA (5 ROLOS SINCRONIZADOS)
// PADRÃO: King Size (86 mm x 8,0 mm)
// FABRICAÇÃO: Creality Ender 3 v1 | Bico 0,4 mm | Material: PLA | PrusaSlicer
// VERSÃO: OpenSCAD 2021.01 (100% Manifold, Sem Suportes, Peças Isoladas)
// ============================================================================

/* [1. SELETOR DE MODO DE VISUALIZAÇÃO / EXPORTAÇÃO STL (1 PEÇA POR VEZ)] */
// Opções:
// "montado", "explodido",
// "base", "tampa",
// "eng_rolo", "eng_motora", "eng_satelite",
// "manivela", "manipulo", "trava"
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
r_orbita = (diam_cigarro + diam_ext_mangueira) / 2.0; // (8 + 10)/2 = 9.0 mm

ang_rolos = [
    -32,   // Rolo 0 (Base - Frontal Inferior)  -> Plano A
    -90,   // Rolo 1 (Base - Fundo Inferior)    -> Plano B
    -148,  // Rolo 2 (Base - Traseiro Inferior) -> Plano A
    144,   // Rolo 3 (Tampa - Traseiro Superior)-> Plano B
    36     // Rolo 4 (Tampa - Frontal Superior) -> Plano A
];

pos_rolos = [ for (a = ang_rolos) [ r_orbita * cos(a), r_orbita * sin(a) ] ];

entre_eixos_rm = modulo_eng * (z_rolo + z_motora) / 2.0 + 0.15; // 18.15 mm
pos_motor = [ 0, -9.0 - entre_eixos_rm ];

Z_camara = 38.0; 
pos_motor_rel = [ 0, -27.15 ];

z_satelite = 10;
ee_mot_sat = modulo_eng * (z_motora + z_satelite) / 2.0 + 0.15; // 18.15 mm
ee_sat_rolo = modulo_eng * (z_satelite + z_rolo) / 2.0 + 0.15;  // 15.15 mm

pos_sat_frente = [  16.8, -20.2 ];
pos_sat_tras   = [ -16.8, -20.2 ];

pos_dobradica  = [ -23.5, 4.5 ];
pos_trava      = [  23.5, 2.0 ];

Y_interno      = comp_util_rolo + 1.0; // 87.0 mm
Y_mancal_ext   = Y_interno + 2 * esp_parede_mancal; // 101.4 mm
Y_plano_B      = Y_mancal_ext / 2 + 1.2 + esp_engrenagem / 2;
Y_plano_A      = Y_plano_B + esp_engrenagem + folga_axial_eng;

// ============================================================================
// MÓDULOS UTILITÁRIOS (MANIFOLD, CHANFROS, FUROS TEARDROP, ENGRENAGENS)
// ============================================================================

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

module engrenagem_reta(m, z, esp, folga_dente = folga_dente_eng, cubo_d = 0, cubo_h = 0, furo_d = 0, tipo_furo = "D") {
    dp = m * z;
    rp = dp / 2;
    addendum = m * 0.92;
    dedendum = m * 1.18;
    rext = rp + addendum;
    rraiz = max(rp - dedendum, (furo_d / 2) + 1.8);
    
    passo_ang = 360 / z;
    larg_dente_p = (PI * m / 2) - folga_dente;
    ang_dente_p  = (larg_dente_p / rp) * (180 / PI);
    
    difference() {
        union() {
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
            if (cubo_d > 0 && cubo_h > 0) {
                cilindro_chanfrado(d = cubo_d, h = esp + cubo_h, ch_inf = chanfro_elefante, ch_sup = 0.4);
            }
        }
        
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
        
        if (furo_d > 0) {
            translate([0, 0, -0.01])
                cylinder(d1 = furo_d + 0.9, d2 = furo_d, h = 0.5);
        }
    }
}

// ============================================================================
// PEÇAS INDIVIDUAIS (DEFINIÇÕES ISOLADAS)
// ============================================================================

module peca_base() {
    y_paredes = [ -(Y_interno/2 + esp_parede_mancal/2), (Y_interno/2 + esp_parede_mancal/2) ];
    
    difference() {
        union() {
            hull() {
                for (sx = [-1, 1], sy = [-1, 1]) {
                    translate([sx * (largura_base_apoio/2 - 5), sy * (Y_mancal_ext/2 + 4 - 5), 0])
                        cilindro_chanfrado(d = 10, h = 5.0, ch_inf = chanfro_elefante, ch_sup = 0.5);
                }
            }
            
            translate([0, 0, 5.0])
                hull() {
                    translate([0, 0, 14.0])
                        rotate([90, 0, 0])
                            cylinder(d = 38.0, h = Y_mancal_ext, center = true);
                    translate([0, 0, 0])
                        cube([46.0, Y_mancal_ext, 2.0], center = true);
                }
            
            for (yp = y_paredes) {
                translate([0, yp, 0]) {
                    hull() {
                        translate([0, 0, 4.0])
                            cube([56.0, esp_parede_mancal, 4.0], center = true);
                        translate([0, 0, Z_camara - 4.0])
                            rotate([90, 0, 0])
                                cylinder(d = 46.0, h = esp_parede_mancal, center = true);
                        translate([pos_dobradica[0], 0, Z_camara + pos_dobradica[1]])
                            rotate([90, 0, 0])
                                cylinder(d = 15.0, h = esp_parede_mancal, center = true);
                        translate([pos_trava[0], 0, Z_camara + pos_trava[1]])
                            rotate([90, 0, 0])
                                cylinder(d = 14.0, h = esp_parede_mancal, center = true);
                    }
                }
            }
            
            for (ps = [pos_sat_frente, pos_sat_tras]) {
                translate([ps[0], Y_mancal_ext/2 + 2.0, Z_camara + ps[1]])
                    rotate([90, 0, 0])
                        cylinder(d = 11.0, h = 6.0, center = true);
            }
        }
        
        translate([0, 0, Z_camara])
            rotate([90, 0, 0])
                cylinder(d = diam_cigarro + 2 * diam_ext_mangueira + 3.0, h = Y_interno, center = true);
        
        translate([0, 0, Z_camara + 22.0])
            cube([80.0, Y_interno, 40.0], center = true);
            
        for (yp = y_paredes) {
            translate([0, yp, Z_camara + 20.5])
                cube([70.0, esp_parede_mancal + 2, 40.0], center = true);
        }
        
        for (i = [0 : 2]) {
            pr = pos_rolos[i];
            translate([pr[0], 0, Z_camara + pr[1]])
                rotate([90, 0, 0])
                    furo_teardrop(d = diam_eixo_metal + 2 * folga_mancal_radial, h = Y_mancal_ext + 4);
        }
        
        translate([pos_motor_rel[0], 0, Z_camara + pos_motor_rel[1]])
            rotate([90, 0, 0])
                furo_teardrop(d = diam_eixo_metal + 2 * folga_mancal_radial, h = Y_mancal_ext + 4);
                
        for (ps = [pos_sat_frente, pos_sat_tras]) {
            translate([ps[0], Y_mancal_ext/2, Z_camara + ps[1]])
                rotate([90, 0, 0])
                    furo_teardrop(d = diam_eixo_metal + 2 * folga_mancal_radial, h = 16.0);
        }
        
        translate([pos_dobradica[0], 0, Z_camara + pos_dobradica[1]])
            rotate([90, 0, 0])
                furo_teardrop(d = diam_eixo_metal + 2 * folga_mancal_radial, h = Y_mancal_ext + 4);
                
        translate([pos_dobradica[0], 0, Z_camara + pos_dobradica[1]])
            cube([18.0, Y_interno - 2 * folga_lateral_tampa, 18.0], center = true);
            
        translate([pos_trava[0], 0, Z_camara + pos_trava[1]])
            rotate([90, 0, 0])
                furo_teardrop(d = diam_eixo_metal + 2 * folga_mancal_radial, h = Y_mancal_ext + 4);
    }
}

module peca_tampa() {
    y_paredes_tampa = [ -(Y_interno/2 + esp_parede_mancal/2), (Y_interno/2 + esp_parede_mancal/2) ];
    
    difference() {
        union() {
            hull() {
                translate([0, 0, Z_camara + 16.0])
                    rotate([90, 0, 0])
                        cylinder(d = 34.0, h = Y_mancal_ext, center = true);
                translate([0, 0, Z_camara + 6.0])
                    cube([42.0, Y_mancal_ext, 8.0], center = true);
            }
            
            for (yp = y_paredes_tampa) {
                translate([0, yp, 0]) {
                    hull() {
                        translate([0, 0, Z_camara + 14.0])
                            rotate([90, 0, 0])
                                cylinder(d = 38.0, h = esp_parede_mancal, center = true);
                        translate([0, 0, Z_camara + 3.0])
                            cube([44.0, esp_parede_mancal, 5.0], center = true);
                        translate([pos_dobradica[0], 0, Z_camara + pos_dobradica[1]])
                            rotate([90, 0, 0])
                                cylinder(d = 14.0, h = esp_parede_mancal, center = true);
                        translate([pos_trava[0] - 2.0, 0, Z_camara + pos_trava[1] + 5.5])
                            rotate([90, 0, 0])
                                cylinder(d = 11.0, h = esp_parede_mancal, center = true);
                    }
                }
            }
            
            translate([pos_dobradica[0], 0, Z_camara + pos_dobradica[1]])
                rotate([90, 0, 0])
                    cylinder(d = 13.5, h = Y_interno - 2.0, center = true);
        }
        
        translate([0, 0, Z_camara])
            rotate([90, 0, 0])
                cylinder(d = diam_cigarro + 2 * diam_ext_mangueira + 2.8, h = Y_interno + 2 * folga_lateral_tampa, center = true);
                
        translate([0, 0, Z_camara - 19.5])
            cube([80.0, Y_mancal_ext + 4, 40.0], center = true);
            
        for (i = [3 : 4]) {
            pr = pos_rolos[i];
            translate([pr[0], 0, Z_camara + pr[1]])
                rotate([90, 0, 0])
                    furo_teardrop(d = diam_eixo_metal + 2 * folga_mancal_radial, h = Y_mancal_ext + 4);
        }
        
        translate([pos_dobradica[0], 0, Z_camara + pos_dobradica[1]])
            rotate([90, 0, 0])
                furo_teardrop(d = diam_eixo_metal + 2 * folga_mancal_radial, h = Y_mancal_ext + 4);
                
        translate([0, 0, Z_camara + 24.0])
            cube([6.5, comp_util_rolo - 2.0, 22.0], center = true);
    }
}

module peca_eng_rolo() {
    engrenagem_reta(
        m = modulo_eng, z = z_rolo, esp = esp_engrenagem,
        cubo_d = 9.2, cubo_h = 2.5, furo_d = diam_eixo_metal, tipo_furo = "D"
    );
}

module peca_eng_motora() {
    engrenagem_reta(
        m = modulo_eng, z = z_motora, esp = esp_engrenagem,
        cubo_d = 10.5, cubo_h = 2.5, furo_d = diam_eixo_metal, tipo_furo = "D"
    );
}

module peca_eng_satelite() {
    engrenagem_reta(
        m = modulo_eng, z = z_satelite, esp = esp_engrenagem,
        cubo_d = 9.0, cubo_h = 2.0, furo_d = diam_eixo_metal, tipo_furo = "livre"
    );
}

module peca_manivela() {
    braco_L = 42.0;
    
    union() {
        difference() {
            hull() {
                cilindro_chanfrado(d = 18.0, h = 7.0);
                translate([braco_L, 0, 0])
                    cilindro_chanfrado(d = 14.0, h = 7.0);
            }
            translate([0, 0, 4.0])
                furo_eixo_D(d = diam_eixo_metal + 2 * folga_cubo_justo, chanfro = chanfro_eixo_D, h = 10.0);
            translate([braco_L, 0, -1])
                cylinder(d = 4.3, h = 10.0);
        }
        
        translate([0, 0, 7.0])
            difference() {
                cilindro_chanfrado(d = 16.0, h = 6.0, ch_inf = 0, ch_sup = 0.6);
                translate([0, 0, 3.0])
                    furo_eixo_D(d = diam_eixo_metal + 2 * folga_cubo_justo, chanfro = chanfro_eixo_D, h = 8.0);
                translate([0, 0, 3.0])
                    rotate([90, 0, 0])
                        cylinder(d = 2.6, h = 10.0);
            }
    }
}

module peca_manipulo() {
    difference() {
        union() {
            cilindro_chanfrado(d = 13.0, h = 28.0, ch_inf = chanfro_elefante, ch_sup = 1.2);
            translate([0, 0, 22.0])
                cilindro_chanfrado(d = 15.5, h = 6.0, ch_inf = 1.0, ch_sup = 1.2);
        }
        translate([0, 0, -1])
            cylinder(d = 4.5, h = 32.0);
        translate([0, 0, 24.0])
            cylinder(d = 8.2, h = 6.0);
    }
}

module peca_trava() {
    difference() {
        union() {
            hull() {
                cilindro_chanfrado(d = 13.0, h = 6.8);
                translate([2.2, 1.5, 0])
                    cilindro_chanfrado(d = 13.0, h = 6.8);
            }
            hull() {
                cilindro_chanfrado(d = 11.0, h = 6.8);
                translate([18.0, -4.0, 0])
                    cilindro_chanfrado(d = 8.0, h = 6.8);
            }
        }
        translate([0, 0, -1])
            cylinder(d = diam_eixo_metal + 2 * folga_mancal_radial, h = 10.0);
    }
}

// ============================================================================
// HARDWARE DE REFERÊNCIA VISUAL (NÃO EXPORTAR PARA IMPRESSÃO 3D)
// ============================================================================
module hardware_referencia() {
    for (i = [0 : 4]) {
        pr = pos_rolos[i];
        rot_t = (i >= 3) ? angulo_tampa : 0;
        
        translate([pos_dobradica[0], 0, Z_camara + pos_dobradica[1]])
            rotate([0, -rot_t, 0])
                translate([-pos_dobradica[0], 0, -(Z_camara + pos_dobradica[1])]) {
                    translate([pr[0], 0, Z_camara + pr[1]])
                        rotate([90, 0, 0]) {
                            color("Silver", 0.9)
                                cylinder(d = diam_eixo_metal, h = Y_mancal_ext + 18.0, center = true);
                            color("DimGray", 0.85)
                                cylinder(d = diam_ext_mangueira, h = comp_util_rolo, center = true);
                        }
                }
    }
    
    translate([pos_motor_rel[0], 4.0, Z_camara + pos_motor_rel[1]])
        rotate([90, 0, 0])
            color("Silver", 0.9)
                cylinder(d = diam_eixo_metal, h = Y_mancal_ext + 28.0, center = true);
                
    translate([pos_dobradica[0], 0, Z_camara + pos_dobradica[1]])
        rotate([90, 0, 0])
            color("Silver", 0.9)
                cylinder(d = diam_eixo_metal, h = Y_mancal_ext + 4.0, center = true);
}

// ============================================================================
// MONTAGEM E EXPORTAÇÃO STL (1 PEÇA ISOLADA POR MODO DE EXPORTAÇÃO)
// ============================================================================
if (modo == "montado" || modo == "explodido") {
    expl = (modo == "explodido") ? 22.0 : 0.0;
    
    color("SteelBlue")
        peca_base();
        
    translate([pos_dobradica[0], 0, Z_camara + pos_dobradica[1] + expl])
        rotate([0, -angulo_tampa, 0])
            translate([-pos_dobradica[0], 0, -(Z_camara + pos_dobradica[1])])
                color("LightSteelBlue")
                    peca_tampa();
                    
    if (modo == "montado") {
        hardware_referencia();
    }
    
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
                                peca_eng_rolo();
    }
    
    for (yp_m = [Y_plano_B, Y_plano_A]) {
        translate([pos_motor_rel[0], yp_m + expl, Z_camara + pos_motor_rel[1]])
            rotate([-90, 0, 0])
                color("DarkOrange")
                    peca_eng_motora();
    }
    
    for (ps = [pos_sat_frente, pos_sat_tras]) {
        translate([ps[0], Y_plano_A + expl, Z_camara + ps[1]])
            rotate([-90, 0, 0])
                color("Gold")
                    peca_eng_satelite();
    }
    
    translate([pos_motor_rel[0], -(Y_mancal_ext/2 + 4.0 + expl), Z_camara + pos_motor_rel[1]])
        rotate([90, 0, 0]) {
            color("SlateGray") peca_manivela();
            translate([42.0, 0, 8.0])
                color("DarkSlateGray") peca_manipulo();
        }
        
    translate([pos_trava[0], Y_mancal_ext/2 + 1.0 + expl, Z_camara + pos_trava[1]])
        rotate([-90, 0, 0])
            color("Crimson")
                peca_trava();
}

// --- MODOS DE EXPORTAÇÃO STL ISOLADA (CADA UM GERA APENAS 1 PEÇA EM Z = 0) ---

if (modo == "base") {
    peca_base();
}

if (modo == "tampa") {
    // Topo plano em Z_camara + 33.0 (71.0 mm) rotacionado 180° assenta exatamente em Z = 0
    translate([0, 0, Z_camara + 33.0])
        rotate([180, 0, 0])
            peca_tampa();
}

if (modo == "eng_rolo") {
    peca_eng_rolo();
}

if (modo == "eng_motora") {
    peca_eng_motora();
}

if (modo == "eng_satelite") {
    peca_eng_satelite();
}

if (modo == "manivela") {
    peca_manivela();
}

if (modo == "manipulo") {
    peca_manipulo();
}

if (modo == "trava") {
    peca_trava();
}