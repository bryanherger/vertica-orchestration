import fileinput
temp_list = []
for line in fileinput.input():
    temp_list.append(line.replace('\n',''))
print ",".join(temp_list)

