#!/usr/bin/env python3
"""Genera el .md gemelo de cada HTML del proyecto. Sin llamadas a Claude.

Regla del proyecto: el contexto se lee del .md (más corto y barato en tokens); el HTML solo
cuando haga falta. Cada vez que se actualice un HTML, se corre este script para regenerar su .md.

Uso (desde la raíz del proyecto):
    python scripts/sincronizar-md.py               # regenera todos los .md
    python scripts/sincronizar-md.py --silencioso  # igual, pero solo informa lo que cambió
    python scripts/sincronizar-md.py --revisar     # solo avisa cuáles están desactualizados (no escribe)
    python scripts/sincronizar-md.py --gemelos     # imprime la ruta de cada .md gemelo (para git)

Se ejecuta solo en dos momentos: el gancho de Claude Code (scripts/hook-sincronizar-md.py) tras editar
un .html, y el gancho de git (scripts/git-hooks/pre-commit) antes de cada commit.

Requiere: pip install beautifulsoup4 markdownify, y node para leer los checklists.
"""
import json
import re
import subprocess
import sys
import tempfile
from pathlib import Path

from bs4 import BeautifulSoup
from markdownify import markdownify

RAIZ = Path(__file__).resolve().parent.parent
CHECKLISTS = RAIZ / 'checklist Desarrollo De procesos'
ESTADO = {'hecho': 'hecho', 'curso': 'en curso', 'pend': 'pendiente'}


def leer(p):
    return Path(p).read_text(encoding='utf-8')


def html_a_md(ruta):
    """Documento HTML corriente -> Markdown. Quita scripts, estilos y navegación."""
    soup = BeautifulSoup(leer(ruta), 'html.parser')
    titulo = soup.title.get_text(strip=True) if soup.title else Path(ruta).stem
    for t in soup(['script', 'style', 'nav', 'button', 'noscript']):
        t.decompose()
    for t in soup.select('.copy, .sim-actions, .sim-log, .chips'):
        t.decompose()
    cuerpo = soup.body or soup
    md = markdownify(str(cuerpo), heading_style='ATX', bullets='-', code_language='')
    md = re.sub(r'\n{3,}', '\n\n', md).strip()
    cab = (f'# {titulo}\n\n> Versión en Markdown de `{Path(ruta).name}`, generada con `scripts/sincronizar-md.py`. '
           f'No editar a mano: se regenera desde el HTML. El HTML tiene las partes interactivas.\n\n')
    # si el cuerpo ya empieza con el mismo h1, no lo repitas
    md = re.sub(r'^#\s+.*\n+', '', md, count=1) if md.startswith('# ') else md
    return cab + md + '\n'


def fases_de(ruta):
    """Extrae KEY y FASES del primer <script> de un checklist ejecutándolo con node."""
    s = leer(ruta)
    bloque = re.search(r'<script>(.*?)</script>', s, re.S).group(1)
    with tempfile.NamedTemporaryFile('w', suffix='.js', delete=False, encoding='utf-8') as f:
        f.write(bloque + '\nconsole.log(JSON.stringify({FASES}));')
        tmp = f.name
    out = subprocess.run(['node', tmp], capture_output=True, text=True, encoding='utf-8')
    Path(tmp).unlink(missing_ok=True)
    if out.returncode != 0:
        raise RuntimeError(out.stderr)
    return json.loads(out.stdout)['FASES']


def checklist_a_md(ruta):
    """Checklist HTML -> Markdown con casillas, estado, responsable y análisis de resultados."""
    s = leer(ruta)
    soup = BeautifulSoup(s, 'html.parser')
    titulo = soup.h1.get_text(strip=True)
    lede = soup.select_one('p.lede').get_text(' ', strip=True)
    meta = soup.select_one('p.meta').get_text(' ', strip=True)
    fases = fases_de(ruta)

    total = sum(len(f['items']) for f in fases)
    hechos = sum(1 for f in fases for i in f['items'] if i[3] == 'hecho')
    en_curso = sum(1 for f in fases for i in f['items'] if i[3] == 'curso')

    out = [f'# {titulo}', '',
           f'> Versión en Markdown de `{Path(ruta).name}`, generada con `scripts/sincronizar-md.py`. '
           'No editar a mano: se regenera desde el HTML. La guía de cada paso (sitio y pasos) y la '
           'marcación interactiva están solo en el HTML.', '',
           lede, '', meta, '',
           f'**Avance registrado:** {hechos} hechos y {en_curso} en curso, de {total} pasos.', '',
           'Leyenda: `[x]` hecho · `[~]` en curso · `[ ]` pendiente. Cada paso trae su responsable.', '']

    for f in fases:
        n_h = sum(1 for i in f['items'] if i[3] == 'hecho')
        out += [f'## {f["titulo"]} ({n_h}/{len(f["items"])})', '']
        if f.get('nota'):
            out += [f'_{f["nota"]}_', '']
        for code, texto, quien, estado in f['items']:
            caja = {'hecho': '[x]', 'curso': '[~]', 'pend': '[ ]'}[estado]
            out.append(f'- {caja} **{code}** {texto} — _{quien}_')
        out.append('')

    out += ['## Análisis de resultados', '']
    sec = soup.select_one('section.analisis')
    intro = sec.find('p')
    out += [intro.get_text(' ', strip=True), '']
    ej = sec.select_one('.example')
    if ej:
        out += ['### Ejemplo de cómo leer un resultado', '']
        for dt, dd in zip(ej.select('dt'), ej.select('dd')):
            out.append(f'- **{dt.get_text(strip=True)}:** {dd.get_text(" ", strip=True)}')
        out.append('')
    for n, li in enumerate(sec.select('ol.results > li'), 1):
        out += [f'### Resultado {n}. {li.h3.get_text(strip=True)}', '']
        for dt, dd in zip(li.select('dt'), li.select('dd')):
            if dt.get_text(strip=True) == 'Pasos del checklist' and li.get('data-pasos'):
                texto = ', '.join(li['data-pasos'].split())
            else:
                texto = dd.get_text(' ', strip=True)
            out.append(f'- **{dt.get_text(strip=True)}:** {texto}')
        out.append('')
    return '\n'.join(out).rstrip() + '\n'


def objetivos():
    """Lista de (html, md, función)."""
    lista = []
    for h in sorted(RAIZ.rglob('*.html')):
        rel = h.relative_to(RAIZ)
        if any(p in ('node_modules', '.git') for p in rel.parts):
            continue
        fn = checklist_a_md if h.parent == CHECKLISTS else html_a_md
        lista.append((h, h.with_suffix('.md'), fn))
    return lista


def main():
    solo_revisar = '--revisar' in sys.argv
    silencioso = '--silencioso' in sys.argv
    if '--gemelos' in sys.argv:
        for _, m, _ in objetivos():
            print(m.relative_to(RAIZ).as_posix())
        return
    desactualizados = 0
    for h, m, fn in objetivos():
        nuevo = fn(h)
        actual = m.read_text(encoding='utf-8') if m.exists() else None
        igual = actual is not None and actual.replace('\r\n', '\n') == nuevo
        rel = m.relative_to(RAIZ)
        if solo_revisar:
            if not igual:
                desactualizados += 1
            print(('ok            ' if igual else 'DESACTUALIZADO ') + str(rel))
        else:
            if not igual:
                m.write_text(nuevo, encoding='utf-8', newline='\n')
            if not (igual and silencioso):
                print(('sin cambios   ' if igual else 'escrito       ') + f'{rel}  ({len(nuevo):,} caracteres, HTML {h.stat().st_size:,} bytes)')
    if solo_revisar and desactualizados:
        sys.exit(1)


if __name__ == '__main__':
    main()
