import math

resistors = [50.0,100.0,200.0,400.0,800.0]

from io import open

wavetable_length = 128 # half of 256 bytes, output code doubles it

rds_on = 5.0

currents = [1.0/(r + 5.0) for r in resistors]

current_table = []

for i in range(2**len(resistors)):
  current = 0.0
  for j in range(len(resistors)):    
    equiv_bit = 2**j
    if 0 != (i & equiv_bit):
      # Use reverse index since resistors are listed from smallest to largest
      current += currents[len(resistors)-1-j]

  current_table.append((i,current))

current_table = sorted(current_table, key = lambda x:x[0] )

_, max_current = current_table[len(current_table)-1]

with open('currents.txt','w') as fout:
  for c in current_table:
    _, current = c
    fout.write(u'%.10f' % current)
    fout.write(u"\n")

wavetable = []

for i in range(wavetable_length):
  wave_index = float(i)/wavetable_length
  wave_value = math.sin(wave_index * math.pi)
  bitpattern = wave_value * (2**len(resistors) - 1)
  bitpattern = int(round(bitpattern))
  
  wavetable.append((i,bitpattern))

def emit_wavetable_data(dst, txtdst, data):  
  for x in range(wavetable_length/8):
    initial = x*8
    end = (x+1)*8
    dst.write(u"\t.byte ")
    dst.write(u','.join(data[initial:end]))

    dst.write(u"\n")    

  for d in data:
    txtdst.write(d)
    txtdst.write(u"\n")

with open('wavetable.S','w') as fout:
  with open('wavetable.txt', 'w') as txtout:
    # Create a special section called '.wave' that is flagged 'xa'
    # so the linker thinks it is code. It gets put in the ELF and ultimately
    # into the final image sent to the chip
    fout.write(u".section .wave, \"xa\"\n")
    fout.write(u"\n")
    fout.write(u".global sine\n")
    fout.write(u"sine:\n")  
    data = []
    
    for wave in wavetable:
      _, bitpattern = wave    
      bitpattern = (2**6) | bitpattern
      data.append((u"0x%2x" % bitpattern).replace(' ', '0'))
  
    emit_wavetable_data(fout, txtout, data)
    data = []
    for wave in wavetable:
      _, bitpattern = wave    
      bitpattern = (2**5) | bitpattern
      data.append((u"0x%2x" % bitpattern).replace(' ', '0'))
    emit_wavetable_data(fout, txtout, data)
  



  
