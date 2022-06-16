#!/usr/bin/env bash

function MakeCandidateList {
  ls Data/Candidates/*fa | cut -d '/' -f3 > Data/Candidate_list.txt
}

function RunMash {
  #bsub -q production -M 50 -n 2 -o mash_dist.log \
  #"/hps/software/users/rdf/metagenomics/service-team/software/mash/mash-2.3/mash dist -p 2 -d 0.5 catalog.msh \
  #Candidates/*fa > mash_results.tab"
  docker run -v $(pwd)/Data:/data staphb/mash mash dist -p 2 -d 0.5 /data/catalog.msh /data/Candidates/MGYG000000000.fa \
  /data/Candidates/MGYG000000006.fa /data/Candidates/MGYG000000008.fa /data/Candidates/MGYG000114054.fa \
  /data/Candidates/MGYG000175173.fa > Data/mash_results.tab
  }

function ParseMashResults {
  python3 Scripts/parse_mash.py -m Data/mash_results.tab -e Data/Candidate_list.txt -o Results/Parsed_mash_results \
  -f Data/Candidates
  }

function ReplaceSpeciesRepresentatives {
  python3 Scripts/replace_species_representative.py -d Results/Parsed_mash_results/New_strains/ \
  -c Data/Representatives/ -m Data/mash_results.tab -o Results/replace_results_table.txt \
  --checkm-result Data/checkm.csv --isolates Data/extra_weight_table.tab --replace
  }


MakeCandidateList
RunMash  # mash against existing catalog
ParseMashResults # separate new genomes into strains/species/discard
ReplaceSpeciesRepresentatives # for genomes that classified as new strains, decide if they should become the new rep
