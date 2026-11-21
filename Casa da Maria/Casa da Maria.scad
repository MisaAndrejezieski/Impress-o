// ============================================================
// MAQUETE CASA 12x12 m — ESCALA 1:50 (CORREÇÃO FUNDO)
// ============================================================

// ---------- DIMENSÕES GERAIS ----------
L = 20.0;  // Largura
H = 5.6;   // Altura
T = 0.3;   // Espessura da parede

// ---------- PARÂMETROS DOS BATENTES ----------
BAT_W = 0.2;  
BAT_S = 0.15; 
BAT_D = 0.1;  
CRZ_W = 0.08; 

$fn = 48;

// ============================================================
// VARIÁVEIS DE AJUSTE MANUAL
// ============================================================

// --- PAREDE FRONTAL (Y = 0) ---
F_P_W = 2.4;  F_P_H = 4.2;
F_P_X = (L - F_P_W) / 2;  
F_P_Y = 0.0;  
F_J_W = 2.4;  F_J_H = 2.4; F_J_Y = 1.8;
F_J1_X = 2.4;             
F_J2_X = L - F_J_W - 2.4; 

// --- PAREDE FUNDO (Y = L - T) ---
FUN_J_W = 3.0; FUN_J_H = 2.4; FUN_J_Y = 1.8;
FUN_J_X = (L - FUN_J_W) / 2; 

// --- PAREDE LATERAL ESQUERDA (X = 0) ---
LAT = L - 2*T;
E_J_W = 2.0; E_J_H = 2.4; E_J_Z = 1.8;
E_J_Y = (L - 2*T - E_J_W) / 2; 

// --- PAREDE LATERAL DIREITA (X = L - T) ---
D_J_W = 2.0; D_J_H = 2.4; D_J_Z = 1.8;
D_J_Y = (L - 2*T - D_J_W) / 2; 

// ============================================================
// MÓDULOS DE BATENTES (PROJETADOS PARA FORA)
// ============================================================

// Batente Plano X-Z (Frente e Fundo)
module batente_xz(w, h, t, frente=true, is_porta=false) {
    // Se for frente, projeta para -Y. Se for fundo, projeta para +Y.
    y_base = frente ? -BAT_S : 0;
    
    module anel(esp, prof) {
        if (!is_porta) translate([-esp, y_base, -esp]) cube([w + 2*esp, prof, esp]);
        translate([-esp, y_base, h]) cube([w + 2*esp, prof, esp]);
        translate([-esp, y_base, 0]) cube([esp, prof, h]);
        translate([w, y_base, 0]) cube([esp, prof, h]);
    }
    
    color("SaddleBrown") {
        anel(BAT_W, BAT_S);
        translate([0, frente ? (BAT_S - BAT_D) : BAT_S, 0])
            anel(BAT_W * 0.7, BAT_D);
            
        if (!is_porta) {
            y_cruz = y_base + (BAT_S / 2) - (CRZ_W / 2);
            translate([w/2 - CRZ_W/2, y_cruz, 0]) cube([CRZ_W, CRZ_W, h]);
            translate([0, y_cruz, h/2 - CRZ_W/2]) cube([w, CRZ_W, CRZ_W]);
        }
    }
}

// Batente Plano Y-Z (Laterais)
module batente_yz(w, h, t, esquerda=true, is_porta=false) {
    // Se for esquerda, projeta para -X. Se for direita, projeta para +X.
    x_base = esquerda ? -BAT_S : 0;
    
    module anel(esp, prof) {
        if (!is_porta) translate([x_base, -esp, -esp]) cube([prof, w + 2*esp, esp]);
        translate([x_base, -esp, h]) cube([prof, w + 2*esp, esp]);
        translate([x_base, -esp, 0]) cube([prof, esp, h]);
        translate([x_base, w, 0]) cube([prof, esp, h]);
    }
    
    color("SaddleBrown") {
        anel(BAT_W, BAT_S);
        translate([esquerda ? (BAT_S - BAT_D) : BAT_S, 0, 0])
            anel(BAT_W * 0.7, BAT_D);
            
        if (!is_porta) {
            x_cruz = x_base + (BAT_S / 2) - (CRZ_W / 2);
            translate([x_cruz, w/2 - CRZ_W/2, 0]) cube([CRZ_W, CRZ_W, h]);
            translate([x_cruz, 0, h/2 - CRZ_W/2]) cube([CRZ_W, w, CRZ_W]);
        }
    }
}

// ============================================================
// MONTAGEM DIRETA DAS PAREDES
// ============================================================

// 1. PAREDE FRONTAL (Y = 0)
color("LightBlue") {
    difference() {
        cube([L, T, H]);
        translate([F_J1_X, -1, F_J_Y]) cube([F_J_W, T+2, F_J_H]);
        translate([F_P_X,  -1, F_P_Y ]) cube([F_P_W,  T+2, F_P_H ]);
        translate([F_J2_X, -1, F_J_Y]) cube([F_J_W, T+2, F_J_H]);
    }
}
translate([F_J1_X, 0, F_J_Y]) batente_xz(F_J_W, F_J_H, T, frente=true, is_porta=false);
translate([F_P_X,  0, F_P_Y ]) batente_xz(F_P_W,  F_P_H,  T, frente=true, is_porta=true);
translate([F_J2_X, 0, F_J_Y]) batente_xz(F_J_W, F_J_H, T, frente=true, is_porta=false);


// 2. PAREDE FUNDO (Y = L - T)
translate([0, L - T, 0]) {
    color("LightBlue") {
        difference() {
            cube([L, T, H]);
            translate([FUN_J_X, -1, FUN_J_Y]) cube([FUN_J_W, T+2, FUN_J_H]);
        }
    }
    // Ajustado para colar na face externa traseira (Y global = L)
    translate([FUN_J_X, T, FUN_J_Y]) batente_xz(FUN_J_W, FUN_J_H, T, frente=false, is_porta=false);
}


// 3. PAREDE LATERAL ESQUERDA (X = 0)
translate([0, T, 0]) {
    color("LightBlue") {
        difference() {
            cube([T, LAT, H]);
            translate([-1, E_J_Y, E_J_Z]) cube([T+2, E_J_W, E_J_H]);
        }
    }
    translate([0, E_J_Y, E_J_Z]) batente_yz(E_J_W, E_J_H, T, esquerda=true, is_porta=false);
}


// 4. PAREDE LATERAL DIREITA (X = L - T)
translate([L - T, T, 0]) {
    color("LightBlue") {
        difference() {
            cube([T, LAT, H]);
            translate([-1, D_J_Y, D_J_Z]) cube([T+2, D_J_W, D_J_H]);
        }
    }
    translate([T, D_J_Y, D_J_Z]) batente_yz(D_J_W, D_J_H, T, esquerda=false, is_porta=false);
}