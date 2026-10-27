import io
import re
import urllib.parse

h = io.open('_source/toyota-philippines.html', encoding='utf-8-sig').read()
names = set()
for m in re.finditer(r'Special:FilePath/([^"\'\s>]+)', h):
    names.add(urllib.parse.unquote(m.group(1)).replace('_', ' '))
for m in re.finditer(r"img:'([^']+)'", h):
    names.add(m.group(1))
names = sorted(n for n in names if not n.startswith('${') and not n.startswith('http'))
io.open('_source/commons-files.txt', 'w', encoding='utf-8', newline='\n').write('\n'.join(names) + '\n')
print(len(names), 'files')
