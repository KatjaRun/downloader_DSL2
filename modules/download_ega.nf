process GET_IDS {
    executor 'local'
    maxForks params.parallel_downloads

    conda "$baseDir/envs/default.yml"
    publishDir "${params.out_dir}", mode: params.publish_dir_mode

    input:
    val egad_identifier 

    output:
    file "egaf_list.txt" 

    script:
    // Added command to download publicly available datasets without egaCredFile
    if (params.egaCredFile)
        """
        pyega3 -cf ${params.egaCredFile} files $egad_identifier 2>&1 | grep -o \"EGAF[0-9]\\+\" > egaf_list.txt
        """
    else
        """
        pyega3 -t files $egad_identifier 2>&1 | grep -o \"EGAF[0-9]\\+\" > egaf_list.txt
        """
    /*
    def command = params.egaCredFile ? 
        "pyega3 -cf ${params.egaCredFile} files $egad_identifier 2>&1 | grep -o \"EGAF[0-9]\\+\" > egaf_list.txt" :
        "pyega3 -t files $egad_identifier 2>&1 | grep -o \"EGAF[0-9]\\+\" > egaf_list.txt"
    """
    ${command}
    """
    */
}

process DOWNLOAD_FASTQ {
    tag "$egaf_identifier"
    executor 'local'
    maxForks params.parallel_downloads
    conda "$baseDir/envs/default.yml"
    errorStrategy { task.attempt <= 2 ? 'retry' : 'ignore' }
    publishDir "${params.out_dir}", mode: params.publish_dir_mode

    input:
    val egaf_identifier 

    output:
    file "**/*.{f*q.gz,bam}"

    script:
    // Added command to download publicly available datasets without egaCredFile
    if (params.egaCredFile)
        """
        pyega3 -cf ${params.egaCredFile} -c ${params.downloadConnections} fetch $egaf_identifier
        """
    else
        """
        pyega3 -d -t fetch $egaf_identifier
        """
}