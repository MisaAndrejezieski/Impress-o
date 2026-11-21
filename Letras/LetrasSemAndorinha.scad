// ==========================================================
// 1. CONFIGURAÇÃO DA PALAVRA
// ==========================================================

texto_completo = "Maria"; // Escreva a porra que você quiser aqui!
letra_extra    = "S";     // Letra extra no último bloco (ou "" para desativar)

// ==========================================================
// 2. DIMENSÕES E CONFIGURAÇÕES
// ==========================================================

tam_quadrado        = 20.0;
altura_base         = 3.08;  // EXATO: 1x 0.20mm + 24x 0.12mm = 3.08mm
raio_canto          = 2.2;
espacamento_blocos  = 25.0;  // Distância entre um bloco e outro para ficarem SEPARADOS

// Alturas dos relevos (múltiplos exatos de 0.12mm)
altura_letras = 0.60;        // 5 camadas de 0.12mm (termina em 3.68mm)
altura_extra  = 0.96;        // 8 camadas de 0.12mm (termina em 4.04mm)

// Espessura das letras (compensação para bico 0.4mm)
engordar_maiuscula = 0.24;
engordar_minuscula = 0.14;
engordar_extra     = 0.15;
borda_extra        = 1.6;

$fn = 64;
eps = 0.05;

// ==========================================================
// MOTOR GEOMÉTRICO
// ==========================================================

qtd = len(texto_completo);
tem_extra = (len(letra_extra) > 0);

function eh_minuscula(ch) = 
    (ord(ch) >= 97 && ord(ch) <= 122) || 
    ch == "á" || ch == "à" || ch == "â" || ch == "ã" || 
    ch == "é" || ch == "ê" || 
    ch == "í" || 
    ch == "ó" || ch == "ô" || ch == "õ" || 
    ch == "ú" || ch == "ü" || 
    ch == "ç";

module bloco_arredondado(w, h, r, alt) {
    hull() {
        for (x = [-w/2 + r, w/2 - r]) {
            for (y = [-h/2 + r, h/2 - r]) {
                translate([x, y, 0])
                    cylinder(r = r, h = alt);
            }
        }
    }
}

module texto_gordo_2d(txt, tamanho, extra_gordura) {
    offset(r = extra_gordura)
        text(txt, size = tamanho, font = "Arial Black:style=Regular", halign = "center", valign = "center");
}

module letra_3d(txt, tamanho, alt, extra_gordura) {
    translate([0, 0, -eps])
        linear_extrude(height = alt + eps)
            texto_gordo_2d(txt, tamanho, extra_gordura);
}

// Gera UM bloco individual completo (base + letra + alça se for o último)
module gerar_bloco_com_letra(i) {
    caractere = texto_completo[i];
    eh_ultimo = (i == qtd - 1);
    
    gordura   = eh_minuscula(caractere) ? engordar_minuscula : engordar_maiuscula;
    tam_fonte = eh_minuscula(caractere) ? 13.2 : 12.6;
    desloc_x  = (eh_ultimo && tem_extra) ? -1.4 : 0;

    union() {
        // Base do bloco
        bloco_arredondado(tam_quadrado, tam_quadrado, raio_canto, altura_base);
        
        // Alça e letra extra se for o último bloco
        if (eh_ultimo) {
            pos_y_alca = tem_extra ? -4.5 : 0;
            difference() {
                hull() {
                    translate([tam_quadrado/2 + 2.2, pos_y_alca, 0])
                        cylinder(r = 4.0, h = altura_base);
                    translate([tam_quadrado/2 - 1.5, pos_y_alca, 0])
                        cylinder(r = 4.6, h = altura_base);
                }
                translate([tam_quadrado/2 + 2.2, pos_y_alca, -0.5])
                    cylinder(r = 1.9, h = altura_base + 1);
            }
            
            if (tem_extra) {
                translate([7.0, 7.2, 0])
                    linear_extrude(height = altura_base)
                        offset(r = borda_extra)
                            texto_gordo_2d(letra_extra, 7.2, engordar_extra);
                
                translate([7.0, 7.2, altura_base])
                    letra_3d(letra_extra, 7.2, altura_extra, engordar_extra);
            }
        }
        
        // Letra principal em relevo
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
}

// ==========================================================
// RENDERIZAÇÃO AUTOMÁTICA DE LETRAS SEPARADAS
// ==========================================================

assert(qtd > 0, "ERRO: O texto não pode ficar vazio.");

// Gera automaticamente todas as letras da palavra espalhadas e separadas na tela
for (i = [0 : qtd - 1]) {
    translate([i * espacamento_blocos, 0, 0])
        gerar_bloco_com_letra(i);
}