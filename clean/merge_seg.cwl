cwlVersion: v1.0
class: CommandLineTool
label: "merge cbs segments"
baseCommand: ['/usr/bin/perl', '/gscuser/cmiller/oneoffs/mergeCbsSegsFuzzyLog2.pl']
stdout: $(inputs.output_f)
inputs:
    segments_f:
        type: File
        inputBinding:
            position: 1
    output_f:
        type: string?
        default: "varscan.output.copynumber.called.recentered.segments.tsv.clean.merged"

outputs:
     merged_f:
         type: stdout