cwlVersion: v1.0
class: Workflow
label: "somatic pipeline"
requirements:
    - class: SubworkflowFeatureRequirement
inputs:
    normal_bam:
        type: File
        secondaryFiles: [.flagstat, .bai]
    tumor_bam:
        type: File
        secondaryFiles: [.flagstat, .bai]
    reference:
        type: File
        secondaryFiles: [.fai]
    final_output_name:
        type: string?
        default: "varscan.output.copynumber.called.recentered.segments.tsv.clean.merged"
    data_ratio:
       type: string?
       default: None        
    varscan_params:
       type: string?
       default: "--min-coverage 20 --min-segment-size 25 --max-segment-size 100"
    min_depth:
       type: string?
       default: "8"
    min_points:
       type: string?
       default: "100"
    undo_sd:
       type: string?
       default: "4"
    min_width:
       type: string?
       default: "2"
    plot_y_min:
       type: string?
       default: "-5"
    plot_y_max:
       type: string?
       default: "5"   
outputs:
    cn:
        type: File
        outputSource: clean_and_merge/segments_merged
    segments:
        type: File
        outputSource: segment/segments_tsv  
steps:
    copy_num_parallel:
        run: copy_num/copy_num_parallel.cwl
        in:
            normal_bam: normal_bam
            tumor_bam: tumor_bam
            reference: reference
            data_ratio: data_ratio
            varscan_params: varscan_params
        out:
            [copy_number]
    copy_num_caller: 
         run: copy_caller/copy_caller.cwl
         in:
             copy_num: copy_num_parallel/copy_number
         out:
             [cn_called_file]
    recenter:
         run: recenter/recenter.cwl
         in:
             cn_called: copy_num_caller/cn_called_file
         out:
             [cn_called_recentered]
    segment:
        run: segment/copynum_segments.cwl
        in:
            regions_file: recenter/cn_called_recentered
            min_depth: min_depth
            min_points: min_points
            undo_sd: undo_sd
            min_width: min_width
            plot_y_min: plot_y_min
            plot_y_max: plot_y_max
        out:
            [segments_tsv]
    clean_and_merge:
        run: clean/clean_and_merge.cwl
        in:
            segments: segment/segments_tsv
            final_output_name: final_output_name
        out:
            [segments_merged]