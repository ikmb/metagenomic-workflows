process TRIMREADS_SE {

	label 'bbmap'
	//errorStrategy 'ignore'
	scratch params.scratch

	input:
		tuple val(meta), path(reads)
		
	output:
		tuple val(meta), path('*_unpaired_trimmed.fastq.gz'), emit: filterSEReads
		//path bbduk_adapter_stats
			
	script:
		sampleID = meta.id

		bbduk_adapter_stats = sampleID + ".bbduk.adapter.stats"

		leftnewname = sampleID + "_1_raw.fastq.gz"
    	rightnewname = sampleID + "_2_raw.fastq.gz"

		left_trimmed = sampleID + "_1_trimmed.fastq.gz"
		right_trimmed = sampleID + "_2_trimmed.fastq.gz"

		unpaired = sampleID + "_unpaired_trimmed.fastq.gz"
		if (meta.single_end) {
		"""
		[ ! -f  $leftnewname ] && ln -s ${reads} $leftnewname

		bbduk.sh stats=$bbduk_adapter_stats \
				threads=${task.cpus} \
				in=${leftnewname} \
				out=${left_trimmed} \
				outs=$unpaired \
				ref=${params.adapters} \
				ktrim=r \
				k=23 \
				mink=11 \
				hdist=1 \
				minlength=${params.min_read_length} \
				tpe \
				tbo
		rm ${left_trimmed}
		"""
		} else {
		"""
		[ ! -f  $leftnewname ] && ln -s ${reads[0]} $leftnewname
    	[ ! -f  $rightnewname ] && ln -s ${reads[1]} $rightnewname

		bbduk.sh stats=$bbduk_adapter_stats \
				threads=${task.cpus} \
				in=${leftnewname} \
				in2=${rightnewname} \
				out1=${left_trimmed} \
				out2=${right_trimmed} \
				outs=$unpaired \
				ref=${params.adapters} \
				ktrim=r \
				k=23 \
				mink=11 \
				hdist=1 \
				minlength=${params.min_read_length} \
				tpe \
				tbo
		"""
		}
}

process TRIMREADS_PE {

	label 'bbmap'
	//errorStrategy 'ignore'
	scratch params.scratch

	input:
		tuple val(meta), path(reads)
		
	output:
		
		tuple val(meta), path('*_{1,2}_trimmed.fastq.gz'), emit: filterPEReads
		tuple val(meta), path('*_unpaired_trimmed.fastq.gz'), emit: filterSEReads
		
			
	script:
		sampleID = meta.id

		bbduk_adapter_stats = sampleID + ".bbduk.adapter.stats"

		leftnewname = sampleID + "_1_raw.fastq.gz"
    	rightnewname = sampleID + "_2_raw.fastq.gz"

		left_trimmed = sampleID + "_1_trimmed.fastq.gz"
		right_trimmed = sampleID + "_2_trimmed.fastq.gz"

		unpaired = sampleID + "_unpaired_trimmed.fastq.gz"
		if (meta.single_end) {
		"""
		[ ! -f  $leftnewname ] && ln -s ${reads} $leftnewname

		bbduk.sh stats=$bbduk_adapter_stats \
				threads=${task.cpus} \
				in=${leftnewname} \
				out=${left_trimmed} \
				outs=$unpaired \
				ref=${params.adapters} \
				ktrim=r \
				k=23 \
				mink=11 \
				hdist=1 \
				minlength=${params.min_read_length} \
				tpe \
				tbo
		rm ${left_trimmed}
		"""
		} else {
		"""
		[ ! -f  $leftnewname ] && ln -s ${reads[0]} $leftnewname
    	[ ! -f  $rightnewname ] && ln -s ${reads[1]} $rightnewname

		bbduk.sh stats=$bbduk_adapter_stats \
				threads=${task.cpus} \
				in=${leftnewname} \
				in2=${rightnewname} \
				out1=${left_trimmed} \
				out2=${right_trimmed} \
				outs=$unpaired \
				ref=${params.adapters} \
				ktrim=r \
				k=23 \
				mink=11 \
				hdist=1 \
				minlength=${params.min_read_length} \
				tpe \
				tbo
		"""
		}
}

process CLEANREADS_PE {

	label 'bbmap'

	scratch params.scratch

	input:
		tuple val(meta), path(reads)

	output:
		tuple val(meta), path('*_cleanwithhost.fastq.gz')

	script:
		sampleID = meta.id
		leftnewname = sampleID + "_1_raw.fastq.gz"
    	rightnewname = sampleID + "_2_raw.fastq.gz"

		left_clean = sampleID + "_R1_cleanwithhost.fastq.gz"
		right_clean = sampleID + "_R2_cleanwithhost.fastq.gz"
		artifact_stats = sampleID + ".bbduk.artifacts.stats"
		
		"""
		[ ! -f  $leftnewname ] && ln -s ${reads[0]} $leftnewname
    	[ ! -f  $rightnewname ] && ln -s ${reads[1]} $rightnewname

		bbduk.sh stats=$artifact_stats threads=${task.cpus} in=${leftnewname} in2=${rightnewname} k=31 ref=artifacts,phix ordered cardinality out1=${left_clean} out2=${right_clean} minlength=${params.min_read_length}
		"""
}

process CLEANREADS_SE {

	label 'bbmap'

	scratch params.scratch

	input:
		tuple val(meta), path(reads)

	output:
		tuple val(meta),path(unpaired_clean), emit: cleanseouts

	script:
		sampleID = meta.id

		unpaired_clean = sampleID + "_single_cleanwithhost.fastq.gz"

		"""
		bbduk.sh threads=${task.cpus} in=${reads[0]}  k=31 ref=artifacts,phix ordered cardinality out1=${unpaired_clean} minlength=${params.min_read_length}

		"""
}