// =========================================================
// MÁQUINA INJETORA DE CIGARROS - PADRÃO KING SIZE (84mm x 8mm)
// =========================================================

$fn = 64; // Resolução das curvas

// --- PARÂMETROS PRINCIPAIS (PADRÃO DE MERCADO) ---
comp_tabaco   = 68.0;  // Comprimento da câmara de fumo (84mm total - 16mm filtro)
diam_tubo     = 8.0;   // Diâmetro do tubo de cigarro padrão
folga_bico    = 0.4;   // Redução no bico para o papel entrar sem rasgar
folga_encaixe = 0.25;  // Tolerância para peças móveis (ajuste se necessário)

// --- DIMENSÕES ESTRUTURAIS ---
diam_bico_ext = diam_tubo - folga_bico; // 7.6mm externo
parede_bico   = 1.1;                    // Espessura da parede do bico
diam_camara   = diam_bico_ext - (parede_bico * 2); // 5.4mm interno
comp_bico     = 18.0;                   // Comprimento do bico onde encaixa o papel

largura_corpo = 22.0;
altura_base   = 11.0;
altura_tampa  = 9.0;

// =========================================================
// SELETOR DE VISUALIZAÇÃO / EXPORTAÇÃO
// Mude para "base", "tampa", "empurrador" ou "todas"
// =========================================================
peca = "todas"; 

if (peca == "todas") {
    translate([-35, 0, 0]) base();
    translate([0, 0, 0])   tampa();
    translate([35, 0, 0])  empurrador();
} else if (peca == "base") {
    base();
} else if (peca == "tampa") {
    tampa();
} else if (peca == "empurrador") {
    empurrador();
}

// =========================================================
// MÓDULO 1: BASE (CORPO + METADE INFERIOR DO BICO)
// =========================================================
module base() {
    difference() {
        union() {
            // Bloco principal
            translate([-largura_corpo/2, -comp_tabaco/2, 0])
                cube([largura_corpo, comp_tabaco, altura_base]);
            
            // Abas de apoio para os dedos (ergonomia na hora de empurrar)
            translate([-(largura_corpo+16)/2, comp_tabaco/2 - 12, 0])
                cube([largura_corpo + 16, 12, altura_base]);

            // Metade inferior do bico frontal
            translate([0, comp_tabaco/2, altura_base])
                rotate([-90, 0, 0])
                    difference() {
                        cylinder(h = comp_bico, d = diam_bico_ext);
                        translate([0, 0, -0.1])
                            cylinder(h = comp_bico + 0.2, d = diam_camara);
                        // Corta a metade superior do cilindro para ficar só a calha inferior
                        translate([-diam_bico_ext, -diam_bico_ext, -0.1])
                            cube([diam_bico_ext*2, diam_bico_ext, comp_bico + 0.2]);
                    }
        }

        // Calha interna do tabaco (semicírculo inferior)
        translate([0, -comp_tabaco/2 - 0.1, altura_base])
            rotate([-90, 0, 0])
                cylinder(h = comp_tabaco + 0.2, d = diam_camara);

        // Trilho guia inferior (formato T invertido para o empurrador não escapar)
        translate([-(6 + folga_encaixe*2)/2, -comp_tabaco/2 - 0.1, -0.1])
            cube([6 + folga_encaixe*2, comp_tabaco + 0.2, 3.2]);
        translate([-(10 + folga_encaixe*2)/2, -comp_tabaco/2 - 0.1, 2.0])
            cube([10 + folga_encaixe*2, comp_tabaco + 0.2, 2.2]);

        // Furos para pinos de alinhamento da tampa (4 cantos)
        for (x = [-largura_corpo/2 + 3.5, largura_corpo/2 - 3.5]) {
            for (y = [-comp_tabaco/2 + 6, comp_tabaco/2 - 6]) {
                translate([x, y, altura_base - 4])
                    cylinder(h = 4.2, d = 3.0 + folga_encaixe*2);
            }
        }
    }
}

// =========================================================
// MÓDULO 2: TAMPA PRENSADORA (IMPRIME DE CABEÇA PARA BAIXO)
// =========================================================
module tampa() {
    union() {
        // Bloco da tampa
        translate([-largura_corpo/2, -comp_tabaco/2, 0])
            cube([largura_corpo, comp_tabaco, altura_tampa]);

        // Calha interna superior (que prensa o tabaco ao fechar)
        // Na posição invertida de impressão, ela fica voltada para cima
        difference() {
            // Pinos de alinhamento (4 cantos)
            for (x = [-largura_corpo/2 + 3.5, largura_corpo/2 - 3.5]) {
                for (y = [-comp_tabaco/2 + 6, comp_tabaco/2 - 6]) {
                    translate([x, y, altura_tampa])
                        cylinder(h = 3.8, d = 3.0);
                }
            }
        }

        // Metade superior do bico (orientada para imprimir plana na mesa)
        translate([0, comp_tabaco/2, altura_tampa])
            rotate([-90, 0, 0])
                difference() {
                    cylinder(h = comp_bico, d = diam_bico_ext);
                    translate([0, 0, -0.1])
                        cylinder(h = comp_bico + 0.2, d = diam_camara);
                    translate([-diam_bico_ext, 0, -0.1])
                        cube([diam_bico_ext*2, diam_bico_ext, comp_bico + 0.2]);
                }
    }
    
    // Nota: A tampa fecha plana sobre a calha da base, formando o cilindro
    // completo com a calha inferior da base + calha do bico.
    // Vamos adicionar um rebaixo semicircular na tampa para formar o tubo completo:
    // (Substitua o bloco simples acima por um bloco com calha)
}

// Redefinindo a tampa com a calha semicircular correta e chanfros no bico
module tampa() {
    difference() {
        union() {
            // Corpo da tampa
            translate([-largura_corpo/2, -comp_tabaco/2, 0])
                cube([largura_corpo, comp_tabaco, altura_tampa]);

            // Pinos guia
            for (x = [-largura_corpo/2 + 3.5, largura_corpo/2 - 3.5]) {
                for (y = [-comp_tabaco/2 + 6, comp_tabaco/2 - 6]) {
                    translate([x, y, altura_tampa])
                        cylinder(h = 3.6, d = 2.9);
                }
            }

            // Metade superior do bico
            translate([0, comp_tabaco/2, altura_tampa])
                rotate([-90, 0, 0])
                    difference() {
                        cylinder(h = comp_bico, d = diam_bico_ext);
                        translate([0, 0, -0.1])
                            cylinder(h = comp_bico + 0.2, d = diam_camara);
                        translate([-diam_bico_ext, 0, -0.1])
                            cube([diam_bico_ext*2, diam_bico_ext, comp_bico + 0.2]);
                    }
        }

        // Calha semicircular superior da câmara de tabaco
        translate([0, -comp_tabaco/2 - 0.1, altura_tampa])
            rotate([-90, 0, 0])
                cylinder(h = comp_tabaco + 0.2, d = diam_camara);
    }
}

// =========================================================
// MÓDULO 3: EMPURRADOR (PISTÃO DESLIZANTE)
// =========================================================
module empurrador() {
    comp_haste = comp_tabaco + comp_bico - 2.0; // Vai até a ponta do bico
    diam_pistao = diam_camara - (folga_encaixe * 2);

    union() {
        // Pegador traseiro (apoio para o polegar)
        translate([-largura_corpo/2, -comp_tabaco/2 - 12, 0])
            cube([largura_corpo, 12, altura_base + 4]);

        // Barra deslizante que corre no trilho inferior da base
        translate([-5.8/2, -comp_tabaco/2, 0])
            cube([5.8, comp_tabaco - 5, 3.0]);
        translate([-9.8/2, -comp_tabaco/2, 2.0])
            cube([9.8, comp_tabaco - 5, 1.8]);

        // Coluna de ligação traseira
        translate([-diam_pistao/2, -comp_tabaco/2 - 4, 0])
            cube([diam_pistao, 6, altura_base]);

        // Haste cilíndrica que empurra o tabaco
        translate([0, -comp_tabaco/2, altura_base])
            rotate([-90, 0, 0])
                cylinder(h = comp_haste, d = diam_pistao);
    }
}