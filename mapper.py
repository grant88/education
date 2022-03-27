import sys

for i, line in sys.stdin:
    keywords = line.strip().split(',')[0].split(' ')
    for keyword in keywords:
        print(f"{keyword},1")