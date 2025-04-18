import sys
from Bio.SeqUtils import GC
from Bio import SeqIO

fastafile = sys.argv[1]
user_id = sys.argv[2]

# Read the first sequence from the FASTA file
first_seq = next(SeqIO.parse(fastafile, 'fasta'))

# Rename with the provided ID
first_seq.id = user_id
first_seq.name = ''
first_seq.description = ''

# Calculate GC content and sequence length
gc_percent = GC(first_seq.seq)
sequence_length = len(first_seq.seq)

# Print results
print(f'Sequence Length: {sequence_length} bp')
print(f'GC Percent: {gc_percent:.2f}%')

# Write the new sequence to a file
SeqIO.write(first_seq, f'{user_id}.reordered.fasta', 'fasta')

print('Draft genome sequence extracted and saved.')