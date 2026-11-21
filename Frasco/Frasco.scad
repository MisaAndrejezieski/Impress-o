/* ==========================================================================
   POTE CILINDRICO PARAMETRICO — VERSAO 3.1 (AUDITADA)
   ========================================================================== */

/* [1. PERSONALIZACAO] */
nome_cliente = "MISAEL";
tamanho_fonte = 6.8; // [3.0:0.5:12.0]
relevo_texto = 0.7; // [0.4:0.1:2.0]
engrossar_letra = 0.12; // [0.00:0.05:0.35]
fonte_texto = "Liberation Sans:style=Bold"; // ["Liberation Sans:style=Bold", "Arial:style=Bold", "Roboto:style=Bold", "DejaVu Sans:style=Bold"]
qualidade_texto = 48; // [16:4:64]

/* [2. DIMENSOES DO POTE] */
altura_total = 100; // [40:5:250]
diametro_externo = 20; // [15:1:60]
espessura_parede = 1.6; // [1.2:0.4:4.0]
espessura_fundo = 2.0; // [1.2:0.2:5.0]
espessura_pescoco = 1.2; // [0.8:0.2:2.0]

/* [3. ROSCA E TAMPA] */
folga_rosca = 0.30; // [0.20:0.05:0.60]
folga_axial_rosca = 0.15; // [0.05:0.05:0.40]
altura_rosca = 10; // [6:1:20]
passo_rosca = 2.5; // [1.5:0.5:4.0]
profundidade_rosca = 0.60; // [0.3:0.1:1.0]
altura_tampa = 12; // [8:1:25]
espessura_parede_tampa = 1.2; // [1.0:0.2:3.0]
tampa_recartilhada = true;

/* [4. VISUALIZACAO E EXPORTACAO] */
modo_exibicao = "impressao"; // [impressao:Lado a lado, fechado:Tampa fechada, apenas_pote:Somente pote, apenas_tampa:Somente tampa]
resolucao = 80; // [48:8:160]

/* [5. AJUSTES INTERNOS] */
$fn = resolucao;
PI = 3.141592653589793;
eps = 0.05;
sobreposicao_texto = 0.03;
largura_fatia_texto = 0.25;
penetracao_texto = 0.35;
entrada_rosca = 0.08;

/* ==========================================================================
6. CALCULOS GEOMETRICOS
   ========================================================================== */
raio_ext = diametro_externo / 2;
raio_int = raio_ext - espessura_parede;
altura_util = altura_total - altura_tampa;
altura_corpo = altura_util + altura_rosca;
raio_nucleo_rosca = raio_ext - espessura_parede;
raio_crest_macho = raio_nucleo_rosca + profundidade_rosca;
raio_cavidade_tampa = raio_crest_macho + folga_rosca;
raio_raiz_femea = raio_cavidade_tampa + profundidade_rosca;
raio_interno_pescoco = raio_nucleo_rosca - espessura_pescoco;
raio_ext_tampa = max(raio_ext, raio_raiz_femea + espessura_parede_tampa);
comprimento_filete = altura_rosca - 1.6;
inicio_filete = 0.8;
segmentos_rosca = max(48, round(resolucao * 1.5));

/* ==========================================================================
7. AUDITORIA DE PARAMETROS
   ========================================================================== */
echo("==========================================");
echo("AUDITORIA DO POTE - VERSAO 3.1");
echo("==========================================");
echo("Diametro externo:", diametro_externo);
echo("Raio interno corpo:", raio_int);
echo("Altura util:", altura_util);
echo("Altura corpo:", altura_corpo);
echo("Nucleo macho:", raio_nucleo_rosca);
echo("Crista macho:", raio_crest_macho);
echo("Cavidade femea:", raio_cavidade_tampa);
echo("Raiz femea:", raio_raiz_femea);
echo("Folga radial:", folga_rosca);
echo("Folga axial:", folga_axial_rosca);
echo("Parede do pescoco:", espessura_pescoco);
echo("Parede minima tampa:", espessura_parede_tampa);
echo("Diametro externo tampa:", raio_ext_tampa * 2);
echo("==========================================");

if (raio_int <= 0) echo("ERRO: Parede do pote invalida.");
if (raio_interno_pescoco <= 0) echo("ERRO: Abertura do pescoco invalida.");
if (espessura_fundo >= altura_util) echo("ERRO: Fundo maior que altura util.");
if (altura_rosca <= 1.6) echo("ERRO: Altura da rosca insuficiente.");
if (comprimento_filete <= 0) echo("ERRO: Comprimento do filete invalido.");
if (raio_crest_macho >= raio_ext) echo("AVISO: Crista da rosca ultrapassa o corpo.");
if (raio_ext_tampa - raio_raiz_femea < espessura_parede_tampa) echo("ERRO: Parede da tampa insuficiente.");
if (folga_axial_rosca * 2 >= passo_rosca * 0.24) echo("AVISO: Folga axial elevada para o perfil.");
if (comprimento_filete / passo_rosca < 1) echo("AVISO: Menos de uma volta de rosca.");

/* ==========================================================================
8. MONTAGEM
   ========================================================================== */
if (modo_exibicao == "impressao") {
    pote();
    translate([diametro_externo + 2 * raio_ext_tampa + 14, 0, altura_tampa])
        rotate([180, 0, 0])
            tampa();
} else if (modo_exibicao == "fechado") {
    pote();
    translate([0, 0, altura_util])
        tampa();
} else if (modo_exibicao == "apenas_pote") {
    pote();
} else if (modo_exibicao == "apenas_tampa") {
    translate([0, 0, altura_tampa])
        rotate([180, 0, 0])
            tampa();
}

/* ==========================================================================
9. MODULO DO POTE
   ========================================================================== */
module pote() {
    union() {
        // Corpo principal
        difference() {
            cylinder(h = altura_util, r = raio_ext);
            translate([0, 0, espessura_fundo])
                cylinder(h = altura_util + eps, r = raio_int);
        }

        // Pescoco reforcado
        translate([0, 0, altura_util - eps])
            difference() {
                cylinder(h = altura_rosca + eps, r = raio_nucleo_rosca);
                translate([0, 0, -eps])
                    cylinder(h = altura_rosca + 3 * eps, r = raio_interno_pescoco);
            }

        // Rosca macho
        translate([0, 0, altura_util + inicio_filete])
            rosca_macho();

        // Texto envelopado verticalmente
        if (len(nome_cliente) > 0) {
            texto_envelopado_vertical(
                texto = nome_cliente,
                raio = raio_ext,
                relevo = relevo_texto,
                tamanho = tamanho_fonte,
                comprimento_max = altura_util - 6,
                engrossamento = engrossar_letra
            );
        }
    }
}

/* ==========================================================================
10. MODULO DA TAMPA
   ========================================================================== */
module tampa() {
    difference() {
        union() {
            cylinder(h = altura_tampa, r = raio_ext_tampa);
            if (tampa_recartilhada) {
                num_frisos = max(12, floor(2 * PI * raio_ext_tampa / 2.6));
                for (i = [0 : num_frisos - 1]) {
                    rotate([0, 0, i * 360 / num_frisos])
                        translate([raio_ext_tampa, 0, 1.5])
                            cylinder(h = altura_tampa - 3, r = 0.30, $fn = 12);
                }
            }
        }

        // Cavidade interna
        translate([0, 0, -eps])
            cylinder(h = altura_tampa - espessura_fundo + eps, r = raio_cavidade_tampa);

        // Rosca femea: canal helicoidal cortado na parede
        translate([0, 0, inicio_filete])
            rosca_femea_cortadora();
    }
}

/* ==========================================================================
11. ROSCA MACHO
   ========================================================================== */
module rosca_macho() {
    largura_base = passo_rosca * 0.72;
    largura_crista = passo_rosca * 0.24;

    // CORRIGIDO: multiplicacao (*) em vez de subtracao (-)
    fatias = max(48, ceil((comprimento_filete / passo_rosca) * segmentos_rosca));

    linear_extrude(
        height = comprimento_filete,
        twist = -360 * comprimento_filete / passo_rosca, // Twist negativo = rosca direita padrao
        slices = fatias,
        convexity = 10
    )
        polygon(points = [
            [raio_nucleo_rosca - eps, -largura_base / 2],
            [raio_crest_macho, -largura_crista / 2],
            [raio_crest_macho, largura_crista / 2],
            [raio_nucleo_rosca - eps, largura_base / 2]
        ]);
}

/* ==========================================================================
12. ROSCA FEMEA - FERRAMENTA DE SUBTRACAO
   ========================================================================== */
module rosca_femea_cortadora() {
    largura_base = passo_rosca * 0.72;
    largura_crista = passo_rosca * 0.24;
    largura_base_femea = largura_base + 2 * folga_axial_rosca;
    largura_crista_femea = largura_crista + 2 * folga_axial_rosca;

    // CORRIGIDO: multiplicacao (*) e mesmo sentido de twist (-360)
    fatias = max(48, ceil((comprimento_filete / passo_rosca) * segmentos_rosca));

    linear_extrude(
        height = comprimento_filete,
        twist = -360 * comprimento_filete / passo_rosca,
        slices = fatias,
        convexity = 10
    )
        polygon(points = [
            [raio_cavidade_tampa - entrada_rosca, -largura_crista_femea / 2],
            [raio_raiz_femea + entrada_rosca, -largura_base_femea / 2],
            [raio_raiz_femea + entrada_rosca, largura_base_femea / 2],
            [raio_cavidade_tampa - entrada_rosca, largura_crista_femea / 2]
        ]);
}

/* ==========================================================================
13. TEXTO ENVELOPADO NA SUPERFICIE CILINDRICA
   ========================================================================== */
module texto_envelopado_vertical(
    texto,
    raio,
    relevo,
    tamanho,
    comprimento_max,
    engrossamento
) {
    comprimento_estimado = len(texto) * (tamanho * 0.72 + engrossamento * 2);
    fator_escala = comprimento_estimado > comprimento_max
        ? comprimento_max / comprimento_estimado
        : 1.0;

    tamanho_final = tamanho * fator_escala;

    // CORRIGIDO: margem de 1.4x para nao cortar topo/base das letras
    largura_total = (tamanho_final + 2 * engrossamento) * 1.4;

    fatias = max(qualidade_texto, ceil(largura_total / largura_fatia_texto));
    largura_fatia = largura_total / fatias;
    centro_z = altura_util / 2;
    profundidade_extrusao = relevo + penetracao_texto;

    // CORRIGIDO: ancora penetrando na parede para gerar malha solida (manifold)
    raio_ancoragem = raio - penetracao_texto;

    union() {
        for (i = [0 : fatias - 1]) {
            y_centro = -largura_total / 2 + (i + 0.5) * largura_fatia;

            // CORRIGIDO: sinal negativo para leitura normal (nao espelhada)
            angulo = -(y_centro / raio) * (180 / PI);
            c = cos(angulo);
            s = sin(angulo);

            // CORRIGIDO: orientacao destra (Y local -> sentido horario ao redor de +Z)
            multmatrix([
                [0,  s, c, raio_ancoragem * c],
                [0, -c, s, raio_ancoragem * s],
                [1,  0, 0, centro_z],
                [0,  0, 0, 1]
            ])
                linear_extrude(
                    height = profundidade_extrusao,
                    center = false,
                    convexity = 5
                )
                    translate([0, -y_centro])
                        intersection() {
                            offset(r = engrossamento)
                                text(
                                    texto,
                                    size = tamanho_final,
                                    font = fonte_texto,
                                    halign = "center",
                                    valign = "center",
                                    spacing = 1
                                );

                            translate([0, y_centro])
                                square([
                                    comprimento_max + 2,
                                    largura_fatia + sobreposicao_texto
                                ], center = true);
                        }
        }
    }
}