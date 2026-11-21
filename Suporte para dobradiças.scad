// ============================================
// GABARITO COMPACTO PARA DOBRADIÇA (CANECO 35mm)
// Tamanho reduzido para uso em portas pequenas
// ============================================

/* [Dimensões Compactas] */
largura = 55;      // Largura total (X) - Fica escondido atrás da dobradiça
altura  = 55;      // Altura total (Y)
espessura = 1.5 ;     // Espessura (Z)

/* [Furo Central] */
caneco_diam = 35;  // Furo do caneco
furo_guia_central = 6; // Furo para marcar o centro com prego/lápis

/* [Furação Guia (Base da Dobradiça)] */
furo_guia_diam = 4.2; 
furo_base_x = 37;  // Distância horizontal da sua imagem
furo_base_y = 32;  // Distância vertical da sua imagem

/* [Furação de Fixação (Grampos/Parafusos)] */
furo_fixacao_diam = 4.5;
margem = 6; // Distância da borda

/* [Qualidade] */
$fn = 64;

// ============================================
// MÓDULOS
// ============================================

module furo_passante(d) {
    cylinder(h = espessura + 2, d = d, center = true);
}

module furo_escareado(d_furo) {
    cylinder(h = espessura + 2, d = d_furo, center = true);
    translate([0, 0, espessura/2 - 1])
        cylinder(h = 2, d1 = d_furo, d2 = d_furo + 3, center = true);
}

module gabarito_compacto() {
    difference() {
        // Corpo principal (Bloco arredondado)
        hull() {
            for (x = [-largura/2 + 5, largura/2 - 5])
                for (y = [-altura/2 + 5, altura/2 - 5])
                    translate([x, y, 0]) cylinder(r = 5, h = espessura, center = true);
        }
        
        // 1. Furo do Caneco (35mm)
        furo_passante(caneco_diam);
        
        // 2. Furo Central de Marcação (6mm)
        furo_passante(furo_guia_central);
        
        // 3. Furos Guias da Base (37x32mm)
        for (x = [-furo_base_x/2, furo_base_x/2]) {
            for (y = [-furo_base_y/2, furo_base_y/2]) {
                translate([x, y, 0])
                    furo_passante(furo_guia_diam);
            }
        }
        
        // 4. Furos de Fixação (4 cantos para parafusos M4)
        for (x = [-largura/2 + margem, largura/2 - margem]) {
            for (y = [-altura/2 + margem, altura/2 - margem]) {
                translate([x, y, 0])
                    furo_escareado(furo_fixacao_diam);
            }
        }
    }
}

// ============================================
// RENDERIZAÇÃO
// ============================================

color("Silver") gabarito_compacto();