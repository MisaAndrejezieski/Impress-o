// ============================================================
// INJETOR BASCULANTE - REVISAO 8
// Haste guiada + cabeça de pistão + empunhadura anatômica
// Unidades: mm | Protótipo CAD: conferir medidas e folgas em teste.
// A dobradiça utiliza pino metálico separado (não modelado).
// ============================================================

$fn = 96;

// ---------------- PARÂMETROS PRINCIPAIS ----------------
comprimento_camara = 68;
raio_camara        = 3.40;       // canal interno: Ø 6,8
largura_corpo      = 22;
altura_eixo        = 10.50;
altura_base        = altura_eixo;
comprimento_bico   = 17;
diametro_bico_ext  = 7.35;
diametro_bico_int  = 4.85;
comprimento_funil  = 5.0;

// Dobradiça metálica
folga_pino         = 0.25;
diametro_pino      = 2.00;
diametro_furo_pino = diametro_pino + folga_pino;

// Ajustes de movimento (valores iniciais para FDM)
folga_lateral      = 0.25;
diametro_haste     = 4.40;
diametro_guia      = 4.90;       // folga diametral de 0,50 mm
comprimento_cabeca = 2.4;
diametro_cabeca    = 6.20;       // 0,30 mm de folga radial no canal Ø6,8

// ---------------- POSIÇÕES DERIVADAS ----------------
y_traseira = -comprimento_camara/2; // -34
 y_frente  =  comprimento_camara/2; // +34
y_inicio_bico = y_frente - 2.0;
y_eixo_dobradica = y_traseira - 6.0;
z_eixo_dobradica = altura_eixo + 3.0;
comprimento_corpo = comprimento_camara + 5.0;
y_inicio_corpo = y_traseira - 3.0;
diametro_canal = 2*raio_camara;
largura_abertura = diametro_canal + 0.8;

// Posição do pistão no limite dianteiro do curso.
// A cabeça para antes do funil estreitar até o diâmetro do bico.
y_cabeca = 28.0;
y_inicio_haste = y_traseira;
comprimento_haste = y_cabeca - y_inicio_haste;

// ---------------- VISUALIZAÇÃO ----------------
// "assembly", "exploded", "base", "tampa", "empurrador"
visualizacao = "exploded";

if (visualizacao == "assembly") {
    base_corpo();
    tampa_fechada();
    empurrador_montado();
} else if (visualizacao == "exploded") {
    translate([-38,0,0]) base_corpo();
    translate([0,0,0]) tampa_para_impressao();
    translate([38,0,0]) empurrador_para_impressao();
} else if (visualizacao == "base") {
    base_corpo();
} else if (visualizacao == "tampa") {
    tampa_para_impressao();
} else if (visualizacao == "empurrador") {
    empurrador_para_impressao();
}

// ============================================================
// BASE: canal, bico integrado, guia traseira e dobradiça
// ============================================================
module base_corpo() {
    difference() {
        union() {
            // Corpo externo com cantos arredondados.
            rounded_box(largura_corpo, comprimento_corpo, altura_base, 2.2,
                        0, y_inicio_corpo + comprimento_corpo/2, altura_base/2);

            // Bico solidário à base.
            translate([0,y_inicio_bico,altura_eixo])
                rotate([-90,0,0]) bico_externo();

            // Orelhas da dobradiça.
            for (x0=[-largura_corpo/2,4.0]) {
                translate([x0,y_eixo_dobradica-2.7,0])
                    cube([6.0,6.2,z_eixo_dobradica]);
                translate([x0,y_eixo_dobradica,z_eixo_dobradica])
                    rotate([0,90,0]) cylinder(h=6.0,d=5.4);
            }

            // Reforços discretos nas laterais traseiras.
            for (lado=[-1,1])
                translate([lado*8.0-1.0,y_traseira-3.0,0])
                    cube([2.0,7.0,altura_base]);

            // Pequenos ressaltos laterais de acabamento/pegada.
            for (lado=[-1,1])
                translate([lado*(largura_corpo/2-0.35),-2,altura_base/2])
                    rounded_box(1.0,34,4.0,0.45,0,0,0);
        }

        // Canal inferior semicircular.
        translate([0,y_traseira-0.2,altura_eixo])
            rotate([-90,0,0]) cylinder(h=comprimento_camara+0.4,d=diametro_canal);

        // Abertura superior para carregamento.
        translate([-largura_abertura/2,y_traseira-0.2,altura_eixo-0.45])
            cube([largura_abertura,comprimento_camara+0.4,0.6]);

        // Guia traseira: permite que a haste entre alinhada no canal.
        translate([0,y_inicio_corpo-0.1,altura_eixo])
            rotate([-90,0,0]) cylinder(h=(y_traseira-y_inicio_corpo)+0.4,d=diametro_guia);

        // Transição para o bico e furo longitudinal.
        translate([0,y_frente-comprimento_funil,altura_eixo])
            rotate([-90,0,0])
                cylinder(h=comprimento_funil+0.15,d1=diametro_canal,d2=diametro_bico_int);
        translate([0,y_inicio_bico-0.1,altura_eixo])
            rotate([-90,0,0]) cylinder(h=comprimento_bico+0.3,d=diametro_bico_int);

        // Furos para pino metálico da dobradiça.
        for (x0=[-largura_corpo/2,4.0])
            translate([x0-0.1,y_eixo_dobradica,z_eixo_dobradica])
                rotate([0,90,0]) cylinder(h=6.2,d=diametro_furo_pino);
    }
}

module bico_externo() {
    difference() {
        union() {
            cylinder(h=comprimento_bico-1.2,d=diametro_bico_ext);
            translate([0,0,comprimento_bico-1.2])
                cylinder(h=1.2,d1=diametro_bico_ext,d2=diametro_bico_ext-0.8);
        }
        translate([0,0,-0.2]) cylinder(h=comprimento_bico+0.5,d=diametro_bico_int);
    }
}

// ============================================================
// TAMPA: cobertura superior com lingueta de dobradiça
// ============================================================
module tampa_fechada() {
    difference() {
        union() {
            translate([0,(y_traseira+(y_frente-2.5))/2,altura_eixo])
                rounded_box(largura_corpo-2*folga_lateral,
                            (y_frente-2.5)-y_traseira,6.5,2.0,
                            0,0,6.5/2);

            // Frisos baixos e arredondados na face superior.
            for (lado=[-1,1])
                translate([lado*7.5,(y_traseira+y_frente-2.5)/2,altura_eixo+6.5])
                    rounded_box(0.8,43,0.45,0.35,0,0,0.225);

            // Lingueta central da dobradiça e ponte de ligação.
            translate([-3.8,y_eixo_dobradica,z_eixo_dobradica])
                rotate([0,90,0]) cylinder(h=7.6,d=5.4);
            translate([-3.8,y_eixo_dobradica,altura_eixo])
                cube([7.6,y_traseira-y_eixo_dobradica+0.6,3.0]);
        }
        translate([0,y_traseira-0.2,altura_eixo])
            rotate([-90,0,0])
                cylinder(h=(y_frente-2.5)-y_traseira+0.4,d=diametro_canal);
        translate([-3.9,y_eixo_dobradica,z_eixo_dobradica])
            rotate([0,90,0]) cylinder(h=7.8,d=diametro_furo_pino);
    }
}

module tampa_para_impressao() {
    translate([0,0,-altura_eixo]) tampa_fechada();
}

// ============================================================
// EMPURRADOR: haste guiada, cabeça de pistão e puxador anatômico
// ============================================================
module empurrador_montado() {
    // Empunhadura oval: volume anatômico, sem quinas agressivas.
    ergonomic_handle();

    // Pescoço reforçado entre empunhadura e haste.
    translate([0,-39.5,altura_eixo])
        rotate([-90,0,0]) cylinder(h=5.8,d1=8.0,d2=diametro_haste);

    // Haste que desliza dentro do furo-guia traseiro.
    translate([0,y_inicio_haste,altura_eixo])
        rotate([-90,0,0]) cylinder(h=comprimento_haste,d=diametro_haste);

    // Cabeça do pistão: Ø6,2 para canal Ø6,8; não deve atravessar o funil.
    translate([0,y_cabeca,altura_eixo])
        rotate([-90,0,0]) cylinder(h=comprimento_cabeca,d=diametro_cabeca,center=true);

    // Pequeno chanfro frontal da cabeça para reduzir arestas.
    translate([0,y_cabeca+comprimento_cabeca/2-0.15,altura_eixo])
        rotate([-90,0,0]) cylinder(h=0.3,d1=diametro_cabeca,d2=diametro_cabeca-0.35);
}

module ergonomic_handle() {
    // Cabo tipo cápsula, mais largo na palma e com extremidades suaves.
    hull() {
        translate([0,-51.5,altura_eixo]) sphere(d=13.5);
        translate([0,-43.5,altura_eixo]) sphere(d=16.0);
    }
    // Pequena lombada de apoio para o polegar.
    hull() {
        translate([0,-48.5,altura_eixo+6.0]) sphere(d=7.0);
        translate([0,-44.5,altura_eixo+5.0]) sphere(d=6.0);
    }
    // Sulcos laterais suaves para melhorar a pega visual/tátil.
    for (lado=[-1,1])
        translate([lado*7.1,-47.5,altura_eixo])
            rotate([90,0,0]) cylinder(h=5.0,d=1.0,center=true);
}

module empurrador_para_impressao() {
    // Apoia a empunhadura e a haste sem alterar as dimensões funcionais.
    translate([0,0,-(altura_eixo-6.75)]) empurrador_montado();
}

// ============================================================
// CAIXA ARREDONDADA AUXILIAR
// ============================================================
module rounded_box(sx,sy,sz,r,cx=0,cy=0,cz=0) {
    hull() {
        for (x=[-sx/2+r,sx/2-r])
            for (y=[-sy/2+r,sy/2-r])
                translate([cx+x,cy+y,cz-sz/2])
                    cylinder(h=sz,r=r,$fn=28);
    }
}
