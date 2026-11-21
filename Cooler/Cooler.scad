// =========================================================
// VENTILADOR DE MESA SILENCIOSO 120MM - 3 PEÇAS SEPARADAS
// =========================================================

/* [Modo de Visualização / Exportação] */
// "montado" = preview | "carcaca" = STL 1 | "grade" = STL 2 | "base" = STL 3
modo = "montado"; // ["montado", "carcaca", "grade", "base"]

/* [Dimensões do Cooler] */
fan_tamanho = 120.0;      // Padrão 120mm
fan_espessura = 25.5;     // 25mm + 0.5mm de folga
furo_distancia = 105.0;   // Distância padrão entre furos (120mm fan)
furo_diametro = 4.4;      // Folga para parafuso M4 passar livre na grade
furo_rosca = 3.7;         // Diâmetro para o parafuso M4 abrir rosca no plástico
folga_encaixe = 0.4;      // Tolerância para Ender 3

/* [Acústica e Estética] */
parede = 3.2;             // Espessura robusta anti-vibração
raio_canto = 12.0;        // Arredondamento externo
recuo_acustico = 10.0;    // Espaço entre cooler e grade (elimina zumbido)
inclinacao = 15;          // Ângulo padrão da base (graus)
largura_base = 76;        // Profundidade compacta do pé de apoio

$fn = 64;

// Medidas calculadas
interno = fan_tamanho + folga_encaixe;
externo = interno + parede * 2;
profundidade_carcaca = fan_espessura + recuo_acustico + 4; // +4mm fundo
largura_orelha = 22;
espessura_orelha = 5;

// =========================================================
// MÓDULOS AUXILIARES
// =========================================================

module caixa_arredondada(larg, alt, prof, r) {
    hull() {
        for (x = [-larg/2 + r, larg/2 - r])
            for (y = [-alt/2 + r, alt/2 - r])
                translate([x, y, 0])
                    cylinder(h = prof, r = r);
    }
}

module furos_montagem(diam, alt) {
    for (x = [-furo_distancia/2, furo_distancia/2])
        for (y = [-furo_distancia/2, furo_distancia/2])
            translate([x, y, 0])
                cylinder(h = alt, d = diam);
}

// =========================================================
// PEÇA 1: CARCAÇA PRINCIPAL (Imprime de costas, sem suportes)
// =========================================================
module peca_carcaca() {
    difference() {
        union() {
            // Corpo principal
            caixa_arredondada(externo, externo, profundidade_carcaca, raio_canto);

            // Torres internas nos 4 cantos para dar rosca nos parafusos da grade
            for (x = [-1, 1]) for (y = [-1, 1])
                translate([x * (interno/2 - 8.5), y * (interno/2 - 8.5), 3])
                    cylinder(h = recuo_acustico + 1, r = 8.5);

            // Duas abas inferiores de acoplamento na Base
            for (lado = [-1, 1]) {
                translate([lado * (externo/2 - 22), -externo/2 - 7, profundidade_carcaca/2])
                rotate([0, 90, 0])
                hull() {
                    cylinder(h = espessura_orelha, d = 18, center = true);
                    translate([-10, 12, 0])
                        cylinder(h = espessura_orelha, d = 18, center = true);
                }
            }
        }

        // Cavidade interna para o cooler + duto acústico
        translate([0, 0, 4])
            caixa_arredondada(interno, interno, profundidade_carcaca + 2, raio_canto - parede);

        // Abertura traseira de entrada de ar
        translate([0, 0, -1])
            cylinder(h = 10, d = fan_tamanho - 6);

        // Furos de rosca nos 4 cantos (para parafusar a grade + cooler)
        translate([0, 0, 1.5])
            furos_montagem(furo_rosca, profundidade_carcaca);

        // Canaleta inferior traseira para passagem do cabo
        translate([0, -interno/2, 9])
            cube([11, 22, 12], center = true);

        // Furos M4 nas abas inferiores para prender na Base
        for (lado = [-1, 1]) {
            translate([lado * (externo/2 - 22), -externo/2 - 7, profundidade_carcaca/2])
            rotate([0, 90, 0])
                cylinder(h = espessura_orelha + 4, d = furo_diametro, center = true);
        }
    }
}

// =========================================================
// PEÇA 2: GRADE FRONTAL PARAFUSADA (Imprime de frente na mesa)
// =========================================================
module peca_grade() {
    esp_grade = 3.2;
    difference() {
        union() {
            // Aro externo
            caixa_arredondada(externo, externo, esp_grade, raio_canto);

            // Ressalto interno de alinhamento (encaixa 3mm dentro da carcaça)
            translate([0, 0, esp_grade])
                difference() {
                    caixa_arredondada(interno - 0.35, interno - 0.35, 3.0, raio_canto - parede);
                    translate([0, 0, -1])
                        cylinder(h = 5, d = fan_tamanho - 4);
                }

            // Cantoneiras reforçadas para os parafusos
            for (x = [-1, 1]) for (y = [-1, 1])
                translate([x * (interno/2 - 9), y * (interno/2 - 9), 0])
                    cylinder(h = esp_grade + 3.0, r = 9);
        }

        // Abertura circular do fluxo de ar
        translate([0, 0, -1])
            cylinder(h = esp_grade + 6, d = fan_tamanho - 4);

        // Furos passantes para os 4 parafusos
        translate([0, 0, -1])
            furos_montagem(furo_diametro, esp_grade + 8);
    }

    // Anéis concêntricos finos (baixo ruído)
    for (d = [36, 62, 88]) {
        difference() {
            cylinder(h = esp_grade, d = d + 2.4);
            translate([0, 0, -0.5])
                cylinder(h = esp_grade + 1, d = d);
        }
    }

    // 6 Hastes radiais finas
    for (a = [0 : 60 : 300]) {
        rotate([0, 0, a + 15])
            translate([0, -1.0, 0])
                cube([fan_tamanho/2 - 1, 2.0, esp_grade]);
    }

    // Cubo central (esconde o eixo do motor)
    cylinder(h = esp_grade, d = 38);
}

// =========================================================
// PEÇA 3: BASE / PEDESTAL COMPACTO (Imprime plano na mesa)
// =========================================================
module peca_base() {
    gap_orelha = espessura_orelha + 0.5;
    parede_suporte = 4.5;

    difference() {
        union() {
            // Sapata de apoio na mesa (compacta e estável)
            caixa_arredondada(externo - 12, largura_base, 4.5, 10);

            // Torres de articulação/fixação da carcaça
            for (lado = [-1, 1]) {
                for (sub = [-1, 1]) {
                    translate([lado * (externo/2 - 22) + sub * (gap_orelha/2 + parede_suporte/2), 0, 0])
                    hull() {
                        translate([0, 0, 2])
                            cube([parede_suporte, 34, 4], center = true);
                        translate([0, -2, 18])
                        rotate([0, 90, 0])
                            cylinder(h = parede_suporte, d = 20, center = true);
                    }
                }
            }
        }

        // Furos M4 nos suportes da base (para parafusar na carcaça)
        for (lado = [-1, 1]) {
            translate([lado * (externo/2 - 22), -2, 18])
            rotate([0, 90, 0])
                cylinder(h = 30, d = furo_rosca, center = true);
        }
    }
}

// =========================================================
// RENDERIZAÇÃO CONFORME MODO ESCOLHIDO
// =========================================================
if (modo == "carcaca") {
    peca_carcaca();
} else if (modo == "grade") {
    peca_grade();
} else if (modo == "base") {
    peca_base();
} else {
    // Visualização das 3 peças montadas juntas
    color("#2b2b2b") peca_base();

    translate([0, -2, 18])
    rotate([90 - inclinacao, 0, 0])
    translate([0, externo/2 + 7, -profundidade_carcaca/2]) {
        color("#3a3a3a") peca_carcaca();
        color("#d93829")
        translate([0, 0, profundidade_carcaca + 3.2])
        rotate([180, 0, 0])
            peca_grade();
    }
}