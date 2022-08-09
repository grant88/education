import sys

previous_keyword = None
keyword_count = 0

for line in sys.stdin:
    keyword, value = line.strip().split(',')
    value = int(value)
    
    if previous_keyword:
        if previous_keyword == keyword:
            keyword_count += value
        else:
            print(previous_keyword, keyword_count)
            previous_keyword = keyword
            keyword_count = value
    else:
        previous_keyword = keyword
        keyword_count = value

print(previous_keyword, keyword_count)