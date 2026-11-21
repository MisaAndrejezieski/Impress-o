// =========================================================
// PEÇA 1: CARCAÇA PRINCIPAL (FINAL VALIDADA - 4 TORRES INTACTAS)
// =========================================================

fan_tamanho = 120.0;
fan_espessura = 26.0;      // 25mm + 1mm pads de borracha
furo_distancia = 105.0;
furo_diametro = 4.4;       // Passante M4
furo_rosca = 3.7;          // Rosca direta M4 em PLA/PETG
folga_encaixe = 0.8;       // Cavidade interna 120.8mm

// USB no topo (USB-A: 14.8 x 7.2 | USB-C oval: 9.6 x 3.8)
usb_formato = "retangular"; // ["retangular", "oval"]
usb_largura = 14.8;
usb_altura = 7.2;

parede = 3.2;
parede_fundo = 3.5;
espaco_traseiro = 14.0;   // Câmara traseira p/ conector USB e fios
recuo_acustico = 10.0;     // Espaço frontal anti-zumbido
raio_externo = 12.0;
raio_interno = 3.5;        // Cantos retos internos p/ cooler quadrado
espessura_orelha = 5.0;
altura_pivo = 22.0;        // Unificado com pedestal.scad

$fn = 64;

interno = fan_tamanho + folga_encaixe; // 120.8mm
externo = interno + parede * 2;        // 127.2mm
z_costas_cooler = parede_fundo + espaco_traseiro; // 17.5mm
profundidade_carcaca = z_costas_cooler + fan_espessura + recuo_acustico; // 53.5mm

module caixa_arredondada(larg, alt, prof, r) {
    hull() {
        for (x = [-larg/2 + r, larg/2 - r])
            for (y = [-alt/2 + r, alt/2 - r])
                translate([x, y, 0])
                    cylinder(h = prof, r = r);
    }
}

module perfil_usb(larg, alt, prof) {
    if (usb_formato == "retangular") {
        rotate([90, 0, 0])
            caixa_arredondada(larg, alt, prof, 0.8);
    } else {
        hull() {
            for (x = [-larg/2 + alt/2, larg/2 - alt/2])
                translate([x, 0, 0])
                    rotate([90, 0, 0])
                        cylinder(h = prof, d = alt, center = true);
        }
    }
}

union() {
    // 1. Casca externa, janela USB e abas inferiores
    difference() {
        union() {
            caixa_arredondada(externo, externo, profundidade_carcaca, raio_externo);

            // Moldura externa reforçada no topo para o USB
            translate([0, externo/2 + 1.0, parede_fundo + usb_altura/2])
                perfil_usb(usb_largura + 4.0, usb_altura + 3.6, 2.5);

            // Abas inferiores alinhadas com altura_pivo = 22.0
            for (lado = [-1, 1]) {
                translate([lado * (externo/2 - 22), -externo/2 - 6, altura_pivo])
                rotate([0, 90, 0])
                hull() {
                    cylinder(h = espessura_orelha, d = 18, center = true);
                    translate([0, 12, 0])
                        cylinder(h = espessura_orelha, d = 18, center = true);
                }
            }
        }

        // Cavidade interna completa
        translate([0, 0, parede_fundo])
            caixa_arredondada(interno, interno, profundidade_carcaca + 2, raio_interno);

        // Entrada de ar traseira (d = 96mm preserva parede grossa nas torres)
        translate([0, 0, -1])
            cylinder(h = parede_fundo + 4, d = 96);

        // Janela superior (Y+) na câmara traseira
        translate([0, externo/2 + 4, parede_fundo + usb_altura/2])
            perfil_usb(usb_largura, usb_altura, 16);

        // Furos M4 nas abas inferiores
        for (lado = [-1, 1]) {
            translate([lado * (externo/2 - 22), -externo/2 - 6, altura_pivo])
            rotate([0, 90, 0])
                cylinder(h = espessura_orelha + 6, d = furo_diametro, center = true);
        }
    }

    // 2. As 4 Torres cilíndricas robustas (r = 6.2mm, altura exata = z_costas_cooler)
    difference() {
        for (x = [-1, 1]) for (y = [-1, 1]) {
            translate([x * (furo_distancia/2), y * (furo_distancia/2), parede_fundo - 0.5])
                cylinder(h = espaco_traseiro + 0.5, r = 6.2);
        }

        // Furos de rosca M4 abertos NO TOPO da torre (descendo 12mm, sem varar o fundo)
        for (x = [-1, 1]) for (y = [-1, 1]) {
            translate([x * (furo_distancia/2), y * (furo_distancia/2), z_costas_cooler - 12.0])
                cylinder(h = 12.5, d = furo_rosca);
        }

        // Alívio do cabo AO LADO da torre inferior direita (sem cortar a torre!)
        translate([furo_distancia/2 - 11.5, -furo_distancia/2 - 3.0, z_costas_cooler - 3.0])
            cube([10, 12, 8], center = true);
    }
}