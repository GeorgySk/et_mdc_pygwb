from pathlib import Path

configfile: "config.yaml"

all_start_times = range(config['first_timestamp'],
                        config['last_timestamp'] + 1,
                        config['duration'])
all_end_times = range(all_start_times.start + all_start_times.step,
                      all_start_times.stop + all_start_times.step,
                      all_start_times.step)

output_path = Path(config['output_path'])
final_estimate_filename = config['final_estimate_template'].format(**config)
final_estimate_filepath = output_path / final_estimate_filename
gwf_template = config['gwf_template'].format(duration=config['duration'])
# gwf_path_template = Path(config['scope']) / gwf_template
gwf_path_template = gwf_template
rucio_gwf_path_template = f"{config['scope']}:{gwf_template}"
# rucio_get_template = f"rucio get {rucio_gwf_path_template}"
rucio_get_template = f"wget http://et-origin.cism.ucl.ac.be/MDC1/v2/data/{{channel}}/{gwf_template}"

rule all:
    input: final_estimate_filepath

rule pygwb_combine:
    input:
        expand(config['estimate_file_template'],
               zip,
               t0=all_start_times,
               tf=all_end_times)
    output: final_estimate_filepath
    container: config['pygwb_container']
    shell: config['pygwb_combine_template'].format(**config)

rule run_pygwb:
    input:
        expand(gwf_path_template,
               channel=config['channels'],
               allow_missing=True)
    output: temp(config['estimate_file_template'])
    container: config['pygwb_container']
    threads: workflow.cores
    shell:
        config['pygwb_pipe_template'].format(**config).format(
            t0='{wildcards.t0}',
            tf='{wildcards.tf}',
            gwf_paths=['{input[0]}', '{input[1]}'])

rule download_data:
    output: temp(gwf_path_template)
    container: config['rucio_client_container']
    resources:
        voms_proxy=True,
        rucio=True
    threads: workflow.cores
    shell:
        rucio_get_template.format(channel_folder='{wildcards.channel}',
                                  channel='{wildcards.channel}',
                                  t0='{wildcards.t0}')
