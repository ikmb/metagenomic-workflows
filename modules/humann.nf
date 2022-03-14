process HUMANN_SE {

    label 'humann'
    tag "$sampleID"
    //scratch true
    //publishDir "${params.outdir}/${sampleID}/humann", mode: 'copy'

     input:
     tuple val(meta),path(reads)

     output:
	 path(genefamilies), emit: genefamilies
     path(pathabundance), emit: pathabundance
     path(pathcoverage), emit: pathcoverage
     path('*'), emit: humannouts

     script:
     sampleID = meta.id
     genefamilies = sampleID + '_genefamilies.tsv'
     pathabundance = sampleID + '_pathabundance.tsv'
     pathcoverage = sampleID + '_pathcoverage.tsv'
	 singleread = sampleID + '.fq'
     """
		zcat $reads > $singleread

    	humann --input $singleread --output . --remove-temp-output --threads ${task.cpus} --nucleotide-database ${params.humann_db}/chocophlan --protein-database ${params.humann_db}/uniref --metaphlan-options "--bowtie2db ${params.metaphlan_db} -x mpa_v30_CHOCOPhlAn_201901 --stat_q 0.2 --force -t rel_ab_w_read_stats --nproc ${task.cpus}"
        rm *.fq 
     """
	}

    process HUMANN_PE {

    label 'humann'
    tag "$sampleID"
    //scratch true
    //publishDir "${params.outdir}/${sampleID}/humann", mode: 'copy'

     input:
     tuple val(meta),path(reads),path(unpaired_clean)

     output:
	 path(genefamilies), emit: genefamilies
     path(pathabundance), emit: pathabundance
     path(pathcoverage), emit: pathcoverage
     path('*'), emit: humannouts

     script:
     sampleID = meta.id
     genefamilies = sampleID + '_genefamilies.tsv'
     pathabundance = sampleID + '_pathabundance.tsv'
     pathcoverage = sampleID + '_pathcoverage.tsv'
	 merged = sampleID + '.fq'
     """
		zcat ${reads[0]} > left.fq
    	zcat ${reads[1]} > right.fq
        zcat $unpaired_clean > single.fq
    	cat left.fq right.fq single.fq > $merged
    	humann --input $merged --output . --remove-temp-output --threads ${task.cpus} --nucleotide-database ${params.humann_db}/chocophlan --protein-database ${params.humann_db}/uniref --metaphlan-options "--bowtie2db ${params.metaphlan_db} -x mpa_v30_CHOCOPhlAn_201901 --stat_q 0.2 --force -t rel_ab_w_read_stats --nproc ${task.cpus}"
        rm *.fq 
     """
	}
    //tuple path(genefamilies),path(pathabundance),path(pathcoverage)
    //tuple val(sampleID),file("${sampleID}_genefamilies.tsv"),file("${sampleID}_pathabundance.tsv"),file("${sampleID}_pathcoverage.tsv")
	process JOINgenefamilies {
    
    label 'humann'
    publishDir "${params.outdir}/humann", mode: 'copy'
    scratch true
    
    input:
	path('*')

    output:
        file(mergedtable)

    script:
        mergedtable = "humann_merged_genefamilies.tsv"

        """
            humann_join_tables --input . --output $mergedtable
        """
  	}

	process JOINpathabundance {

    label 'humann'
    publishDir "${params.outdir}/humann", mode: 'copy'
    scratch true
    

    input:
	path('*')

    output:
        file(mergedtable)

    script:
        mergedtable = "humann_merged_pathabundance.tsv"

        """
            humann_join_tables --input . --output $mergedtable
        """
  	}

	process JOINpathcoverage {

    label 'humann'
    publishDir "${params.outdir}/humann", mode: 'copy'
    scratch true
    

    input:
	path('*')

    output:
        file(mergedtable)

    script:
        mergedtable = "humann_merged_pathcoverage.tsv"

        """
            humann_join_tables --input . --output $mergedtable
        """
  	}       