// ==========================================
// GERADOR MODULAR COM ENCAIXE RABO DE ANDORINHA OCULTO
// ==========================================

// 1. CONFIGURAÇÃO DO TEXTO E EXPORTAÇÃO
texto_principal     = "Ana"; // Palavra completa
letra_extra         = "S";   // Letra extra no último bloco (ou "")
bloco_para_exportar = 0;     // 0 = Mostra todos na tela (visualização)
                             // 1, 2, 3... = Exporta apenas o bloco escolhido para STL

// 2. CORES (apenas para visualização no OpenSCAD)
cores_blocos = ["red", "blue", "gold", "limegreen", "darkorange", "deepskyblue"];

// 3. DIMENSÕES E TOLERÂNCIA DO ENCAIXE
tam_quadrado  = 20.0;
altura_base   = 3.0;
raio_canto    = 2.2;
folga_encaixe = 0.22;        // Folga ideal para encaixe justo na Ender 3 (bico 0.4mm)

// 4. ALTURAS DOS RELEVOS (múltiplos de camada 0.20mm)
altura_letras = 0.6;
altura_extra  = 1.0;

// 5. ESPESSURA DAS LETRAS
engordar_maiuscula = 0.25;
engordar_minuscula = 0.14;
engordar_extra     = 0.16;
borda_extra        = 1.6;

$fn = 60;

// ==========================================
// MOTOR AUTOMÁTICO
// ==========================================

qtd = len(texto_principal);
tem_extra = (len(letra_extra) > 0);
function eh_minuscula(ch) = (ord(ch) >= 97 && ord(ch) <= 122);

module bloco_arredondado(w, h, r, alt) {
    hull() {
        for (x = [-w/2 + r, w/2 - r]) {
            for (y = [-h/2 + r, h/2 - r]) {
                translate([x, y, 0])
                    cylinder(r=r, h=alt);
            }
        }
    }
}

module texto_gordo_2d(txt, tamanho, extra_gordura) {
    offset(r = extra_gordura)
        text(txt, size = tamanho, font = "Arial Black:style=Regular", halign = "center", valign = "center");
}

module letra_3d(txt, tamanho, alt, extra_gordura) {
    linear_extrude(height = alt) {
        texto_gordo_2d(txt, tamanho, extra_gordura);
    }
}

// Plugue trapezoidal (Rabo de Andorinha) apoiado na mesa (Z=0 a 1.6mm)
// Fica 100% invisível por cima e trava contra tração!
module plug_rabo_andorinha(folga = 0) {
    profundidade = 3.2;      // Quanto entra dentro do próximo bloco
    largura_base = 5.0;      // Gargalo mais estreito na junção
    largura_ponta = 6.8;     // Ponta mais larga que trava dentro do bloco
    altura_plug  = 1.6;      // Metade da altura da base (fica coberto pela parte de cima)

    linear_extrude(height = altura_plug + folga) {
        offset(r = folga) {
            polygon(points = [
                [-0.5, -largura_base/2],
                [profundidade, -largura_ponta/2],
                [profundidade,  largura_ponta/2],
                [-0.5,  largura_base/2]
            ]);
        }
    }
}

module gerar_bloco(i) {
    caractere   = texto_principal[i];
    eh_primeiro = (i == 0);
    eh_ultimo   = (i == qtd - 1);
    cor_atual   = cores_blocos[i % len(cores_blocos)];
    
    gordura   = eh_minuscula(caractere) ? engordar_minuscula : engordar_maiuscula;
    tam_fonte = eh_minuscula(caractere) ? 13.2 : 12.6;
    desloc_x  = (eh_ultimo && tem_extra) ? -1.4 : 0;

    color(cor_atual) {
        difference() {
            union() {
                bloco_arredondado(tam_quadrado, tam_quadrado, raio_canto, altura_base);
                
                // Plugue macho à direita (APENAS se NÃO for o último bloco)
                if (!eh_ultimo) {
                    translate([tam_quadrado/2, 0, 0])
                        plug_rabo_andorinha(0);
                }
                
                // Alça externa no último bloco (início e fim ficam 100% discretos e limpos)
                if (eh_ultimo) {
                    translate([tam_quadrado/2 + 2.0, tem_extra ? -4.5 : 0, 0])
                        difference() {
                            cylinder(r = 3.8, h = altura_base);
                            translate([0, 0, -0.5])
                                cylinder(r = 1.8, h = altura_base + 1);
                        }
                }
                
                // Contorno da letra extra ("S")
                if (eh_ultimo && tem_extra) {
                    translate([7.0, 7.2, 0])
                        linear_extrude(height = altura_base)
                            offset(r = borda_extra)
                                texto_gordo_2d(letra_extra, 7.2, engordar_extra);
                }
            }
            
            // Cavidade fêmea à esquerda (APENAS se NÃO for o primeiro bloco)
            if (!eh_primeiro) {
                translate([-tam_quadrado/2, 0, -0.01])
                    plug_rabo_andorinha(folga_encaixe);
            }
        }
    }
    
    // Letra Principal (Branca)
    color("white") {
        translate([desloc_x, 0, altura_base]) {
            if (caractere == "C" || caractere == "c") {
                difference() {
                    letra_3d(caractere, tam_fonte, altura_letras, gordura);
                    translate([4.0, 0, altura_letras/2])
                        cube([6.5, 2.8, altura_letras + 1], center = true);
                }
            } else {
                letra_3d(caractere, tam_fonte, altura_letras, gordura);
            }
        }
    }
    
    // Letra Extra no canto (Roxa)
    if (eh_ultimo && tem_extra) {
        color("purple")
            translate([7.0, 7.2, altura_base])
                letra_3d(letra_extra, 7.2, altura_extra, engordar_extra);
    }
}

// Exibição: todos lado a lado (0) ou apenas o bloco selecionado para exportar STL
if (bloco_para_exportar == 0) {
    for (i = [0 : qtd - 1]) {
        translate([i * (tam_quadrado + 4.5), 0, 0]) // Espaçados na visualização para você ver os plugs!
            gerar_bloco(i);
    }
} else if (bloco_para_exportar >= 1 && bloco_para_exportar <= qtd) {
    gerar_bloco(bloco_para_exportar - 1);
}