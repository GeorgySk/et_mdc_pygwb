# How to run a parallel pygwb pipeline on Reana cluster with ET MDC data

## Setup
For setting up the certificates and the accounts, see [How to run a serial pygwb pipeline on Reana cluster with ET MDC data](https://gist.github.com/GeorgySk/5cd862712d5e4d3d3cdb24275b02c877).

### Environment variables
Open the attached .env file and fill in the required data:
- `ESCAPE_USERNAME` -- the username which was used to create the account at https://iam-escape.cloud.cnaf.infn.it/.
- `CERTIFICATES_PATH` -- absolute path to the directory containing the _usercert.pem_ and _userkey.pem_ files.
- `REANA_CONFIG_PATH` -- absolute path to the _reana.yaml_ file (attached).
- `PYGWB_PARAMETERS_PATH` -- absolute path to the _parameters.ini_ file used by `pygwb_pipe` and `pygwb_combine` (attached).
- `SNAKEFILE_PATH` -- absolute path to the Snakefile (attached).
- `SNAKEMAKE_CONFIG_PATH` -- absolute path to the _config.yaml_ file used by snakemake (attached).
- `REANA_ACCESS_TOKEN` -- Reana access token which can be found in your Reana profile: https://reana-vre.cern.ch/signin. 
- `WORKFLOW_NAME` -- any name for a workflow; will be displayed on the Reana dashboard: https://reana-vre.cern.ch/.

## Execution
1. `cd` to the directory with the _compose.yaml_ and _.env_ files (both files are attached).
2. Run `docker compose up`.  
Docker will now:
- pull the image with the Rucio client (only the first time);
- launch a container from this image;
- use the provided certificates and the token to authenticate with Rucio and Reana;
- create the workflow with the provided name the status of which can be monitored via the Reana dashboard -- https://reana-vre.cern.ch/;
- upload _reana.yaml_ that specifies the steps of the workflow;
- upload _Snakefile_ that specifies the workflow, its jobs, and the corresponding scripts;
- upload _config.yaml_ that specifies the workflow parameters used by snakemake such as the channels and the time limits;
- upload _parameters.ini_ that specifies the parameters of the data analysis run by pygwb;
- start the workflow;
- print the status of the workflow in the terminal every 2 seconds.  

Right now, the status will get printed forever so you would have to forcefully shut down the container by pressing <kbd>Ctrl</kbd>+<kbd>C</kbd> several times. I might change this behaviour later.  
If everything was done correctly, the workflow should finish correctly in some time, and you would see something like this in the Reana dashboard:  
![image](https://user-images.githubusercontent.com/20144534/285870654-acb1c313-9741-46ff-8a74-88e1b4c83015.png)

### Selecting MDC data
To select data use the _config.yaml_ file. The fields `first_timestamp`, `last_timestamp`, and `channels` define the labels of the files downloaded from Rucio. For example, for the values such as
```
first_timestamp: 1002641920
last_timestamp: 1002643968
channels: ['E1', 'E2']
```
the following files will be selected:
- _ET_OSB_MDC1:E-E1_STRAIN_DATA-1002641920-2048.gwf_
- _ET_OSB_MDC1:E-E2_STRAIN_DATA-1002641920-2048.gwf_
- _ET_OSB_MDC1:E-E1_STRAIN_DATA-1002643968-2048.gwf_
- _ET_OSB_MDC1:E-E2_STRAIN_DATA-1002643968-2048.gwf_

You might want to see which data is present on Rucio. For this, the easiest way is to use the JupyterHub interface -- https://jhub-vre.cern.ch/. After signing in with the ESCAPE credentials and starting the default environment, run  
```bash
rucio list-dids --filter 'type=file' ET_OSB_MDC1:*_STRAIN_DATA-*
```
to get the list of the files. Note that these files are not in sync with the ones found on the HTTP web server -- http://et-origin.cism.ucl.ac.be/.  

---

#### Links
- MDC page on ET wiki: https://wiki.et-gw.eu/OSB/DataAnalysisPlatform/MDC
- Access to ET MDC data using HTTP web server: http://et-origin.cism.ucl.ac.be/
- Pygwb documentation: https://pygwb.docs.ligo.org/pygwb/index.html
- Snakemake documentation: https://snakemake.readthedocs.io/
- VRE page: https://vre-hub.github.io/
