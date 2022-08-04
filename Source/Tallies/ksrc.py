z_coords = [45.77842,30.42158,15.06474,-0.2921,-15.64894] # middle z pt of each fuel section
f = open('ksrc','r')
new_ksrc = ""
for line in f:
	entries = line.split()
	for z in z_coords:
		new_entries = ''
		for entry in entries+[z]:
			entry = '{:.4f}'.format(float(entry) + 0.05)
			new_entries += f'  {entry}'
		new_ksrc += '\n'+new_entries
print(new_ksrc)
