// ============================================================
// DOBRADIÇA FUNCIONAL PARA USO REAL (ROBUSTA) - OPENSCAD
// ============================================================

$fn = 64;

// ---------- VARIÁVEIS PARA USO REAL (DIMENSÕES ROBUSTAS) ----------
ALTURA_TOTAL    = 40.0;   // Altura total da dobradiça (40 mm = 4 cm)
RAIO_CILINDRO   = 6.0;    // Raio externo dos cilindros articulados (diâmetro de 12 mm)
RAIO_FURO       = 2.5;    // Raio do furo interno / eixo (diâmetro de 5 mm)
FOLGA_3D        = 0.3;    // Folga técnica para o eixo girar livremente sem travar
LARGURA_ABA     = 25.0;   // Largura da aba de fixação (25 mm = 2.5 cm)
ESPESSURA_ABA   = 4.0;    // Espessura robusta da chapa para aguentar peso
DISTANCIA_PECAS = 45.0;   // Afastamento entre as peças na tela para exportação

// Parâmetros para furos de fixação com parafusos reais nas abas
RAIO_PARAFUSO   = 2.0;    // Raio do furo para parafuso (diâmetro de 4 mm)

// ----------------------------------------------------
// PARTE 1: LADO DA ESTRUTURA / BATENTE (2 Cilindros nas pontas)
// ----------------------------------------------------
module peca_base() {
    color("LightSteelBlue") {
        difference() {
            union() {
                // Cilindro inferior
                translate([0, 0, 0])
                    cylinder(r=RAIO_CILINDRO, h=ALTURA_TOTAL/3);
                
                // Cilindro superior
                translate([0, 0, (ALTURA_TOTAL/3)*2])
                    cylinder(r=RAIO_CILINDRO, h=ALTURA_TOTAL/3);
                
                // Aba de fixação robusta unida ao lado esquerdo
                translate([-LARGURA_ABA, -ESPESSURA_ABA/2, 0])
                    cube([LARGURA_ABA, ESPESSURA_ABA, ALTURA_TOTAL]);
            }
            
            // Furo central passante para o eixo
            translate([0, 0, -1])
                cylinder(r=RAIO_FURO + FOLGA_3D, h=ALTURA_TOTAL + 2);
            
            // Furos de fixação para parafusos reais (distribuídos na vertical)
            for (z_pos = [ALTURA_TOTAL * 0.25, ALTURA_TOTAL * 0.75]) {
                translate([-LARGURA_ABA / 2, 0, z_pos])
                    rotate([90, 0, 0])
                    cylinder(r=RAIO_PARAFUSO, h=ESPESSURA_ABA * 3, center=true);
            }
        }
    }
}

// ----------------------------------------------------
// PARTE 2: LADO DA PORTA / TAMPA (1 Cilindro central)
// ----------------------------------------------------
module peca_movel() {
    color("WhiteSmoke") {
        difference() {
            union() {
                // Cilindro central (encaixe do meio)
                translate([0, 0, ALTURA_TOTAL/3])
                    cylinder(r=RAIO_CILINDRO, h=ALTURA_TOTAL/3);
                
                // Aba de fixação robusta unida ao lado direito
                translate([0, -ESPESSURA_ABA/2, 0])
                    cube([LARGURA_ABA, ESPESSURA_ABA, ALTURA_TOTAL]);
            }
            
            // Furo central passante para o eixo
            translate([0, 0, -1])
                cylinder(r=RAIO_FURO + FOLGA_3D, h=ALTURA_TOTAL + 2);
            
            // Furos de fixação para parafusos reais (distribuídos na vertical)
            for (z_pos = [ALTURA_TOTAL * 0.25, ALTURA_TOTAL * 0.75]) {
                translate([LARGURA_ABA / 2, 0, z_pos])
                    rotate([90, 0, 0])
                    cylinder(r=RAIO_PARAFUSO, h=ESPESSURA_ABA * 3, center=true);
            }
        }
    }
}

// ----------------------------------------------------
// PARTE 3: PINO / EIXO REAL COM CABEÇOTE
// ----------------------------------------------------
module pino_eixo() {
    color("Gold") {
        union() {
            // Corpo principal do pino
            cylinder(r=RAIO_FURO, h=ALTURA_TOTAL + 2);
            
            // Cabeça do pino para travamento superior
            translate([0, 0, ALTURA_TOTAL + 2])
                cylinder(r=RAIO_FURO * 2.0, h=3.0);
        }
    }
}

// ============================================================
// MONTAGEM FINAL NA TELA
// ============================================================

// Peça base (2 cilindros) à esquerda
translate([-DISTANCIA_PECAS, 0, 0]) 
    peca_base();

// Peça móvel (1 cilindro) à direita
translate([DISTANCIA_PECAS, 0, 0]) 
    peca_movel();

// Pino de articulação posicionado ao fundo
translate([0, DISTANCIA_PECAS * 0.8, 0]) 
    pino_eixo();