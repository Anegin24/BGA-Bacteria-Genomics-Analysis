#Download data
mkdir -p data
wget -P data ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR333/004/ERR3335404/ERR3335404_1.fastq.gz
wget -P data ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR333/004/ERR3335404/ERR3335404_2.fastq.gz

#QC
mkdir -p QC
fastqc data/*fastq.gz -o QC

#trimming
mkdir -p fastp
fastp \
  --in1 data/ERR3335404_1.fastq.gz \
  --in2 data/ERR3335404_2.fastq.gz \
  --out1 fastp/ERR3335404_1.fastp.fastq.gz \
  --out2 fastp/ERR3335404_2.fastp.fastq.gz \
  --json fastp/ERR3335404_fastp.fastp.json \
  --html fastp/ERR3335404_fastp.fastp.html \
  --thread 20 \
  --detect_adapter_for_pe \
  --trim_front1 15 --trim_front2 15 \
  --trim_tail1 15 --trim_tail2 15 \
  -q 15 --cut_mean_quality 15 --length_required 15 \
  2> fastp/ERR3335404_fastp.fastp.log

#QC
fastqc fastp/*fastq.gz -o fastp

#Assembly
mkdir -p assembly
spades.py --careful -o assembly -1 fastp/ERR3335404_1.fastp.fastq.gz -2 fastp/ERR3335404_2.fastp.fastq.gz

#QC assembly
mkdir -p QC_ASSEMBLY
quast.py -o QC_ASSEMBLY assembly/contigs.fasta

#mlst
mlst --csv assembly/contigs.fasta >mlst.csv

#Collect reference genome

#reorder-draft-genome
ref=genomes/.fasta
ragtag.py scaffold $ref assembly/contig.fasta -o reorder-draft-genome
python extract_reordered.py reorder-draft-genome/ragtag.scaffold.fasta ERR3335404

#annotation
prokka --cpus 8 --kingdom Bacteria --locustag ERR3335404 --outdir ERR3335404_annotation --prefix ERR3335404 --addgenes ERR3335404.reordered.fasta
./get_pseudo.pl ERR3335404_annotation/P7741.faa | tee ERR3335404_annotation/ERR3335404.pseudo.txt
python annotation_stat.py ERR3335404_annotation ERR3335404

#amr
abricate ERR3335404.reordered.fasta > amr.summary.tab
cat amr.summary.tab

#plasmid
abricate --db plasmidfinder assembly/contigs.fasta

#Collect genome

#pan-genome
##Collect genome annotation
mkdir -p pangenome
genomes=(genomes/*.fasta)  
mkdir -p gffs               
for genome in "${genomes[@]}"
do
    name=$(basename "$genome" .fasta) 
    prokka --cpus 8 \
        --kingdom Bacteria \
        --locustag "$name" \
        --addgenes \
        --prefix "$name" \
        "$genome"
    cp "${name}/${name}.gff" gffs/
    rm -rf "$name"
done

##pan-genome analyis
roary -f pangenome -p 8 -e -n -v --mafft gffs/*.gff
FastTree -nt -gtr pangenome/core_gene_alignment.aln > pangenome/mytree.newick
#Plot phylogenetic tree and generate svg format
python roary_plots.py --labels --format svg pangenome/mytree.newick pangenome/gene_presence_absence.csv

#Plot phylogenetic tree and generate image in png format
python roary_plots.py --labels pangenome/mytree.newick pangenome/gene_presence_absence.csv

#mv all plots to pangenome folder
mv pangenome_*.{svg,png} pangenome







