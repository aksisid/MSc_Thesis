#!/bin/bash

####################################
# Base paths
####################################
BASE_PATH=/scratch/gsentis/isidoros
INPUT_BASE=$BASE_PATH
OUTPUT_BASE=$BASE_PATH/aligned

####################################
# Tools
####################################
HISAT2_COMMAND=hisat2
SAMTOOLS_COMMAND=samtools

####################################
# Reference
####################################
#human
HISAT2_INDEX_HG=$BASE_PATH/human_index/grch38
#mouse
HISAT2_INDEX_MM=$BASE_PATH/mouse_index

####################################
# Resources
####################################
CORES=8

####################################
# Create output base dir
####################################
mkdir -p $OUTPUT_BASE

####################################
# Loop over human & mouse directories
####################################
for GROUP_DIR in $INPUT_BASE/*_group
do
    GROUP_NAME=$(basename $GROUP_DIR | sed 's/_group//')
    OUT_DIR=$OUTPUT_BASE/${GROUP_NAME}_aligned

    echo "========================================"
    echo "Processing $GROUP_NAME"
    echo "Output -> $OUT_DIR"
    echo "========================================"

    mkdir -p $OUT_DIR

    ####################################
    # Loop over FASTQ files in group
    ####################################
    if [[ "$GROUP_DIR" == *"/human"* ]]; then
        HISAT2_INDEX=$HISAT2_INDEX_HG
       
        for FASTQ in $GROUP_DIR/*.fastq
        do
        
        SAMPLE=$(basename $FASTQ | sed 's/.fastq//')

        echo "----- Aligning $SAMPLE in $OUT_DIR using $HISAT2_INDEX"

        ####################################
        # HISAT2 alignment → BAM
        ####################################
        $HISAT2_COMMAND \
            -p $CORES \
            -x $HISAT2_INDEX \
            -U $FASTQ \
            --add-chrname | \
        $SAMTOOLS_COMMAND view -@ $CORES -bhS - | \
        $SAMTOOLS_COMMAND sort -@ $CORES -o $OUT_DIR/${SAMPLE}.bam -

        ####################################
        # Index BAM
        ####################################
        $SAMTOOLS_COMMAND index -@ $CORES $OUT_DIR/${SAMPLE}.bam

        echo "✔ Finished $SAMPLE"
        echo

        done
    
    elif [[ "$GROUP_DIR" == *"/mouse"* ]]; then
        HISAT2_INDEX=$HISAT2_INDEX_MM

        for FASTQ in $GROUP_DIR/*.fastq
        do
        
        SAMPLE=$(basename $FASTQ | sed 's/.fastq//')

        echo "----- Aligning $SAMPLE in $OUT_DIR using $HISAT2_INDEX"

        ####################################
        # HISAT2 alignment → BAM
        ####################################
        $HISAT2_COMMAND \
            -p $CORES \
            -x $HISAT2_INDEX \
            -U $FASTQ \
            --add-chrname | \
        $SAMTOOLS_COMMAND view -@ $CORES -bhS - | \
        $SAMTOOLS_COMMAND sort -@ $CORES -o $OUT_DIR/${SAMPLE}.bam -

        ####################################
        # Index BAM
        ####################################
        $SAMTOOLS_COMMAND index -@ $CORES $OUT_DIR/${SAMPLE}.bam

        echo "✔ Finished $SAMPLE"
        echo
        done
    else 
        echo "No directory detected :( "
    
    fi
    
done

echo "🎉 All alignments completed successfully!"
