// ============================================================
// CONJUNTO MECANICO BASCULANTE - REVISAO 6
// Modelo paramétrico para OpenSCAD
// Unidades: mm
//
// IMPORTANTE:
// - Esta revisão abandona a cremalheira/manivela e usa tampa basculante.
// - O pino da dobradiça é uma peça metálica separada (2 mm nominal).
// - "assembly" mostra a montagem fechada; "exploded" separa as peças.
// - A geometria é um protótipo CAD: exige inspeção e teste físico antes
//   de qualquer uso. O código não substitui validação dimensional.
// ============================================================

$fn = 80;

// ---------------- PARÂMETROS PRINCIPAIS ----------------
comprimento_camara = 68;
raio_camara        = 3.40;   // canal inferior/superior: diâmetro 6,8
largura_corpo      = 22;
altura_eixo        = 10.50;   // centro da câmara
altura_base        = altura_eixo;
comprimento_bico   = 17;
diametro_bico_ext  = 7.35;
diametro_bico_int  = 4.85;
comprimento_funil  = 5.0;

// Folgas para FDM: valores iniciais; dependem da calibração da impressora.
folga_pino         = 0.25;    // folga diametral no furo da dobradiça
diametro_pino      = 2.00;
diametro_furo_pino = diametro_pino + folga_pino;

folga_lateral      = 0.25;    // por lado, tampa/base
diametro_haste     = 4.40;
comprimento_haste  = 83;

// ---------------- POSIÇÕES DERIVADAS ----------------
y_traseira = -comprimento_camara/2; // -34
y_frente   =  comprimento_camara/2; // +34
y_inicio_bico = y_frente - 2.0;     // sobreposição real com a base
y_eixo_dobradica = y_traseira - 6.0;
z_eixo_dobradica = altura_eixo + 3.0;

comprimento_corpo = comprimento_camara + 5.0; // y=-37 até +36
y_inicio_corpo = y_traseira - 3.0;

diametro_canal = 2*raio_camara;
largura_abertura = diametro_canal + 0.8;

// ---------------- VISUALIZAÇÃO ----------------
// "assembly", "exploded", "base", "tampa", "empurrador", "pino"
visualizacao = "exploded";

// ---------------- SELETOR ----------------
if (visualizacao == "assembly") {
    base_corpo();
    tampa_fechada();
    empurrador_montado();
    pino_dobradica();
}
else if (visualizacao == "exploded") {
    translate([-38, 0, 0]) base_corpo();
    translate([  0, 0, 0]) tampa_para_impressao();
    translate([ 38, 0, 0]) empurrador_para_impressao();
    translate([0, 48, 0]) pino_para_impressao();
}
else if (visualizacao == "base") {
    base_corpo();
}
else if (visualizacao == "tampa") {
    tampa_para_impressao();
}
else if (visualizacao == "empurrador") {
    empurrador_para_impressao();
}
else if (visualizacao == "pino") {
    pino_para_impressao();
}

// ============================================================
// 1. BASE
// Canal inferior aberto por cima + funil + bico solidário
// ============================================================
module base_corpo() {
    difference() {
        union() {
            // Corpo principal: o bico começa 2 mm dentro do corpo,
            // garantindo sobreposição volumétrica em vez de contato coplanar.
            translate([-largura_corpo/2, y_inicio_corpo, 0])
                cube([largura_corpo, comprimento_corpo, altura_base]);

            // Bico tubular integrado ao corpo.
            // Eixo local Z é rotacionado para o eixo longitudinal Y.
            translate([0, y_inicio_bico, altura_eixo])
                rotate([-90, 0, 0])
                    bico_externo();

            // Orelhas da dobradiça, duas laterais intercaladas com a lingueta da tampa.
            for (x0 = [-largura_corpo/2, 4.0]) {
                translate([x0, y_eixo_dobradica-2.7, 0])
                    cube([6.0, 6.2, z_eixo_dobradica]);

                translate([x0, y_eixo_dobradica, z_eixo_dobradica])
                    rotate([0,90,0])
                        cylinder(h=6.0, d=5.4);
            }

            // Reforços laterais curtos na região traseira.
            for (lado = [-1,1]) {
                translate([lado*8.0-1.0, y_traseira-3.0, 0])
                    cube([2.0, 7.0, altura_base]);
            }
        }

        // Canal inferior semicircular: como o corpo termina no plano
        // do eixo da câmara, apenas a metade inferior é removida.
        translate([0, y_traseira-0.2, altura_eixo])
            rotate([-90,0,0])
                cylinder(h=comprimento_camara+0.4, d=diametro_canal);

        // Boca de carregamento levemente aliviada ao longo do topo.
        // Abre a entrada sem eliminar as paredes laterais de contenção.
        translate([-largura_abertura/2, y_traseira-0.2, altura_eixo-0.45])
            cube([largura_abertura, comprimento_camara+0.4, 0.6]);

        // Transição cônica entre canal 6,8 mm e furo do bico 4,85 mm.
        translate([0, y_frente-comprimento_funil, altura_eixo])
            rotate([-90,0,0])
                cylinder(h=comprimento_funil+0.15,
                         d1=diametro_canal, d2=diametro_bico_int);

        // Furo contínuo do bico.
        translate([0, y_inicio_bico-0.1, altura_eixo])
            rotate([-90,0,0])
                cylinder(h=comprimento_bico+0.3, d=diametro_bico_int);

        // Furos transversais da dobradiça (eixo X).
        for (x0 = [-largura_corpo/2, 4.0]) {
            translate([x0-0.1, y_eixo_dobradica, z_eixo_dobradica])
                rotate([0,90,0])
                    cylinder(h=6.2, d=diametro_furo_pino);
        }
    }
}

module bico_externo() {
    // Perfil externo contínuo com pequeno chanfro na ponta.
    difference() {
        union() {
            cylinder(h=comprimento_bico-1.2, d=diametro_bico_ext);
            translate([0,0,comprimento_bico-1.2])
                cylinder(h=1.2, d1=diametro_bico_ext, d2=diametro_bico_ext-0.8);
        }
        translate([0,0,-0.2])
            cylinder(h=comprimento_bico+0.5, d=diametro_bico_int);
    }
}

// ============================================================
// 2. TAMPA BASCULANTE
// Canal superior alinhado com o canal da base.
// Dobradiça central entre as duas orelhas da base.
// ============================================================
module tampa_fechada() {
    difference() {
        union() {
            // Placa da tampa: a face inferior encosta no plano do eixo.
            translate([-(largura_corpo-2*folga_lateral)/2, y_traseira, altura_eixo])
                cube([largura_corpo-2*folga_lateral,
                      (y_frente-2.5)-y_traseira, 6.5]);

            // Lingueta central da dobradiça.
            translate([-3.8, y_eixo_dobradica, z_eixo_dobradica])
                rotate([0,90,0])
                    cylinder(h=7.6, d=5.4);

            // Ponte estrutural entre a tampa e a lingueta.
            translate([-3.8, y_eixo_dobradica, altura_eixo])
                cube([7.6, y_traseira-y_eixo_dobradica+0.6, 3.0]);
        }

        // Canal superior semicircular. A tampa fecha o semicírculo superior.
        translate([0, y_traseira-0.2, altura_eixo])
            rotate([-90,0,0])
                cylinder(h=(y_frente-2.5)-y_traseira+0.4, d=diametro_canal);

        // Furo da lingueta central da dobradiça.
        translate([-3.9, y_eixo_dobradica, z_eixo_dobradica])
            rotate([0,90,0])
                cylinder(h=7.8, d=diametro_furo_pino);
    }
}

module tampa_para_impressao() {
    // A tampa é deslocada para Z=0 para facilitar o fatiamento.
    translate([0,0,-altura_eixo])
        tampa_fechada();
}

// ============================================================
// 3. EMPURRADOR LINEAR
// Haste de 4,4 mm, alinhada ao eixo da câmara e do bico.
// A ponta cônica reduz a chance de prender na transição.
// ============================================================
module empurrador_montado() {
    // Cabo traseiro compacto, conectado fisicamente à haste.
    translate([-7.0, y_traseira-17.0, altura_eixo-diametro_haste/2])
        cube([14.0, 9.0, 10.0]);

    // Pescoço de união entre cabo e haste.
    translate([-3.2, y_traseira-8.5, altura_eixo-diametro_haste/2])
        cube([6.4, 5.0, diametro_haste]);

    // Haste longitudinal.
    translate([0, y_traseira-4.0, altura_eixo])
        rotate([-90,0,0])
            cylinder(h=comprimento_haste, d=diametro_haste);

    // Ponta levemente cônica na extremidade dianteira.
    translate([0, y_traseira-4.0+comprimento_haste, altura_eixo])
        rotate([-90,0,0])
            cylinder(h=3.0, d1=diametro_haste, d2=3.8);
}

module empurrador_para_impressao() {
    // Mantém a haste horizontal e baixa a peça para a mesa.
    translate([0,0,-(altura_eixo-diametro_haste/2)])
        empurrador_montado();
}

// ============================================================
// 4. PINO DA DOBRADIÇA
// Recomenda-se pino metálico liso de 2 mm, não impresso.
// O modelo é apenas referência dimensional.
// ============================================================
module pino_dobradica() {
    translate([-11.0, y_eixo_dobradica, z_eixo_dobradica])
        rotate([0,90,0])
            cylinder(h=22.0, d=diametro_pino);
}

module pino_para_impressao() {
    // Colocado horizontalmente na mesa para visualização/exportação.
    translate([0,0,0])
        rotate([0,90,0])
            cylinder(h=22.0, d=diametro_pino);
}
