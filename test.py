new_file = ''
for line in open('./Source/reed.template'):
    if '{{h2o_density}}' in line:
        entries = line.split(' ')
        if '$' in entries:
            entries.insert(entries.index('$'), 'tmp={{h2o_temp_MeV}}')
        else:
            entries.append('tmp={{h2o_temp_MeV}}')
        new_line = ' '.join(entries)
    else:
        new_line = line
    new_file += new_line

text_file = open("./Source/reedtest.template", "w")
n = text_file.write(new_file)