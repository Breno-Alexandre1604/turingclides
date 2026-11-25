"""Gera o ícone do Turingclides: triângulo de Euclides sobre a fita de Turing.

Uma geometria só, na grade de 108 unidades do ícone adaptativo do Android:
- vetor (foreground e monochrome) para Android 8+;
- PNG legado nas 5 densidades;
- ícones web (any e maskable) e favicon;
- prévia em docs/img para a documentação.
"""
import os
import sys

from PIL import Image, ImageDraw

raiz = sys.argv[1]

FUNDO = (0x42, 0x55, 0xD4)
BRANCO = (255, 255, 255)
CELULAS = [
    (32.0, (0xFF, 0x70, 0x43)),
    (47.5, (0xAA, 0xB6, 0xFF)),
    (63.0, (0x26, 0xC6, 0xB0)),
]
TRIANGULO = [(54, 30.4), (70.5, 59), (37.5, 59)]
TRACO = 4.5
CELULA_Y, CELULA_LADO, CELULA_RAIO = 64.5, 13, 3


def escrever(caminho, texto):
    caminho = os.path.join(raiz, caminho)
    os.makedirs(os.path.dirname(caminho), exist_ok=True)
    with open(caminho, "w", encoding="utf8", newline="\n") as f:
        f.write(texto)


def celula_path(x):
    lado = CELULA_LADO - 2 * CELULA_RAIO
    r = CELULA_RAIO
    return (
        f"M{x + r:g},{CELULA_Y:g} h{lado:g} a{r},{r} 0 0 1 {r},{r} v{lado:g} "
        f"a{r},{r} 0 0 1 -{r},{r} h-{lado:g} a{r},{r} 0 0 1 -{r},-{r} "
        f"v-{lado:g} a{r},{r} 0 0 1 {r},-{r} z"
    )


def vetor(monocromatico):
    (ax, ay), (bx, by), (cx, cy) = TRIANGULO
    partes = [
        '<?xml version="1.0" encoding="utf-8"?>',
        "<!-- Gerado por tool/gerar_icone.py: triângulo de Euclides sobre a",
        "     fita de Turing, uma célula para cada jogo. -->",
        '<vector xmlns:android="http://schemas.android.com/apk/res/android"',
        '    android:width="108dp"',
        '    android:height="108dp"',
        '    android:viewportWidth="108"',
        '    android:viewportHeight="108">',
        "    <path",
        '        android:fillColor="#00000000"',
        '        android:strokeColor="#FFFFFF"',
        f'        android:strokeWidth="{TRACO:g}"',
        '        android:strokeLineJoin="round"',
        f'        android:pathData="M{ax:g},{ay:g} L{bx:g},{by:g} L{cx:g},{cy:g} Z" />',
    ]
    for x, cor in CELULAS:
        hexa = "#FFFFFF" if monocromatico else "#%02X%02X%02X" % cor
        partes += [
            "    <path",
            f'        android:fillColor="{hexa}"',
            f'        android:pathData="{celula_path(x)}" />',
        ]
    partes.append("</vector>")
    return "\n".join(partes) + "\n"


def desenhar(lado_px, janela, fundo, cantos):
    """Desenha a marca. `janela` = (início, tamanho) na grade de 108."""
    k = 8  # supersampling
    s = lado_px * k
    img = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    inicio, tamanho = janela
    esc = s / tamanho

    def p(x, y):
        return ((x - inicio) * esc, (y - inicio) * esc)

    if fundo == "cheio":
        d.rectangle([0, 0, s, s], fill=FUNDO)
    elif fundo == "arredondado":
        margem = s * cantos[0]
        d.rounded_rectangle(
            [margem, margem, s - margem, s - margem],
            radius=(s - 2 * margem) * cantos[1],
            fill=FUNDO,
        )

    w = TRACO * esc
    pontos = [p(*v) for v in TRIANGULO]
    d.line(pontos + pontos[:2], fill=BRANCO, width=round(w), joint="curve")
    for x, y in pontos:
        d.ellipse([x - w / 2, y - w / 2, x + w / 2, y + w / 2], fill=BRANCO)

    for x, cor in CELULAS:
        x0, y0 = p(x, CELULA_Y)
        x1, y1 = p(x + CELULA_LADO, CELULA_Y + CELULA_LADO)
        d.rounded_rectangle([x0, y0, x1, y1], radius=CELULA_RAIO * esc, fill=cor)

    return img.resize((lado_px, lado_px), Image.LANCZOS)


def salvar(img, caminho):
    caminho = os.path.join(raiz, caminho)
    os.makedirs(os.path.dirname(caminho), exist_ok=True)
    img.save(caminho, optimize=True)


res = "android/app/src/main/res"
escrever(f"{res}/drawable/ic_launcher_foreground.xml", vetor(False))
escrever(f"{res}/drawable/ic_launcher_monochrome.xml", vetor(True))
escrever(
    f"{res}/mipmap-anydpi-v26/ic_launcher.xml",
    """<?xml version="1.0" encoding="utf-8"?>
<!-- Ícone adaptativo (Android 8+). O monochrome atende os ícones temáticos
     do Android 13+. Os PNG das pastas mipmap-* servem aos Androids antigos. -->
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background" />
    <foreground android:drawable="@drawable/ic_launcher_foreground" />
    <monochrome android:drawable="@drawable/ic_launcher_monochrome" />
</adaptive-icon>
""",
)
escrever(
    f"{res}/values/ic_launcher_background.xml",
    """<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- Índigo da marca, o mesmo de corDaMarca em lib/app/app_theme.dart. -->
    <color name="ic_launcher_background">#4255D4</color>
</resources>
""",
)

# Legado: quadrado arredondado com a área central (18 a 90) da grade.
centro = (18, 72)
for pasta, lado in [("mdpi", 48), ("hdpi", 72), ("xhdpi", 96), ("xxhdpi", 144), ("xxxhdpi", 192)]:
    salvar(desenhar(lado, centro, "arredondado", (1 / 24, 0.26)), f"{res}/mipmap-{pasta}/ic_launcher.png")

# Web: "any" arredondado e "maskable" com fundo até a borda (zona segura).
for lado in (192, 512):
    salvar(desenhar(lado, centro, "arredondado", (0, 0.26)), f"web/icons/Icon-{lado}.png")
    salvar(desenhar(lado, (0, 108), "cheio", None), f"web/icons/Icon-maskable-{lado}.png")
salvar(desenhar(32, centro, "arredondado", (0, 0.22)), "web/favicon.png")

# Prévia para a documentação: ícone legado, máscara circular do Android e
# o tamanho real de 48 px.
previa = Image.new("RGBA", (3 * 220 + 40, 260), (245, 246, 250, 255))
previa.alpha_composite(desenhar(200, centro, "arredondado", (0, 0.26)), (20, 30))
mascara = Image.new("L", (200, 200), 0)
ImageDraw.Draw(mascara).ellipse([0, 0, 199, 199], fill=255)
previa.paste(desenhar(200, (0, 108), "cheio", None), (240, 30), mascara)
previa.alpha_composite(desenhar(48, centro, "arredondado", (1 / 24, 0.26)), (536, 106))
salvar(previa.convert("RGB"), "docs/img/icone.png")
print("ok")
