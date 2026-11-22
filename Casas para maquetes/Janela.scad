// =========================================================
// JANELA DE ENCAIXE PARA VAO 22x22 - CASINHA MODULAR
// Auditado para OpenSCAD 2021.01
// =========================================================

// --- Dimensoes do vao na parede ---
largura_vao_janela = 22;      // Largura do recorte na parede
altura_vao_janela  = 22;      // Altura do recorte na parede
espessura_parede   = 8;       // Espessura da parede

// --- Folga e encaixe ---
folga_encaixe      = 0.25;    // Folga perimetral (ajuste conforme Ender 3 + PLA)
profundidade_corpo = 6.0;     // Parte que entra dentro do vao de 8 mm
espessura_borda    = 2.5;     // Largura do aro/moldura da janela
tem_aba_batente    = true;    // Pequena aba para limitar o encaixe
espessura_aba      = 1.5;     // Espessura da aba
folga_aba          = 0.8;     // Quanto a aba avanca alem do vao

// --- Detalhe interno (grade / divisoria) ---
tipo_miolo         = "cruz";  // "cruz", "horizontal", "vertical" ou "nenhum"
espessura_barra    = 2.2;

// Resolucao
$fn = 48;

module janela_encaixe() {
    larg_interna = largura_vao_janela - (2 * folga_encaixe);
    alt_interna  = altura_vao_janela - (2 * folga_encaixe);

    // Garante que a abertura interna do caixilho seja positiva
    abertura_x = max(2, larg_interna - (2 * espessura_borda));
    abertura_z = max(2, alt_interna - (2 * espessura_borda));
    x_abertura = (larg_interna - abertura_x) / 2;
    z_abertura = (alt_interna - abertura_z) / 2;

    union() {
        // Caixilho principal que entra no vao de 22x22 mm
        difference() {
            cube([larg_interna, profundidade_corpo, alt_interna]);

            translate([x_abertura, -0.1, z_abertura])
                cube([abertura_x, profundidade_corpo + 0.2, abertura_z]);
        }

        // Aba/moldura frontal para encosto na face da parede
        if (tem_aba_batente) {
            larg_aba = largura_vao_janela + (2 * folga_aba);
            alt_aba  = altura_vao_janela + (2 * folga_aba);
            dx_aba   = (larg_aba - larg_interna) / 2;
            dz_aba   = (alt_aba - alt_interna) / 2;

            difference() {
                translate([-dx_aba, profundidade_corpo - 0.02, -dz_aba])
                    cube([larg_aba, espessura_aba, alt_aba]);

                translate([x_abertura, profundidade_corpo - 0.12, z_abertura])
                    cube([abertura_x, espessura_aba + 0.24, abertura_z]);
            }
        }

        // Barras internas de acordo com tipo_miolo
        if (tipo_miolo == "cruz" || tipo_miolo == "vertical") {
            translate([
                (larg_interna - espessura_barra) / 2,
                (profundidade_corpo - espessura_barra) / 2,
                espessura_borda - 0.05
            ])
            cube([espessura_barra, espessura_barra, abertura_z + 0.1]);
        }

        if (tipo_miolo == "cruz" || tipo_miolo == "horizontal") {
            translate([
                espessura_borda - 0.05,
                (profundidade_corpo - espessura_barra) / 2,
                (alt_interna - espessura_barra) / 2
            ])
            cube([abertura_x + 0.1, espessura_barra, espessura_barra]);
        }
    }
}

janela_encaixe();