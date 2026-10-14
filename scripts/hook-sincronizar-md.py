#!/usr/bin/env python3
"""Gancho de Claude Code (PostToolUse de Write y Edit). Sin llamadas a Claude.

Cuando se edita un .html del proyecto, regenera los .md gemelos con scripts/sincronizar-md.py.
Lee por la entrada estándar el JSON que envía Claude Code; si el archivo editado no es un .html
de este proyecto, no hace nada. Nunca falla: un error aquí no debe detener el trabajo.
"""
import json
import os
import subprocess
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent


def main():
    try:
        datos = json.load(sys.stdin)
    except Exception:
        return
    ruta = (datos.get('tool_input') or {}).get('file_path') or ''
    if not ruta.lower().endswith('.html'):
        return
    try:
        Path(ruta).resolve().relative_to(RAIZ)
    except Exception:
        return  # un HTML de otro lugar
    env = dict(os.environ, PYTHONIOENCODING='utf-8')
    r = subprocess.run([sys.executable, str(RAIZ / 'scripts' / 'sincronizar-md.py'), '--silencioso'],
                       capture_output=True, text=True, encoding='utf-8', env=env)
    if r.returncode != 0:
        print('No se pudo sincronizar los .md: ' + (r.stderr or '').strip()[-300:], file=sys.stderr)
        return
    if r.stdout.strip():
        print('.md sincronizados tras editar el HTML:\n' + r.stdout.strip())


if __name__ == '__main__':
    main()
