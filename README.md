## DESCRIPTION

A CUDA benchmark for the Fast force-coupling method

## DOWNLOAD
Install `git-lfs` so that the data files in this repo can be downloaded correctly, then download with
```
git lfs clone https://github.com/racksa/cuFCM_demo.git
```
> :warning: **I have a very limited git-lfs bandwith and if it runs out, you may not be able to download the datafiles.**
Alternatively you may still `git clone` the rest of repo, and download the datafiles I uploaded to Google Drive (completed):
> https://drive.google.com/drive/folders/15OTZDhHe5HApjDzOtImjMpz4cQP1B43p?usp=sharing
and replace the ones in the repo by the files on Google Drive.

## COMPILE
Modify the `/src/config.hpp` file to select available options. To compile, under the home directory of this project, run
```bash
make clean x
```
where x is one of the given options in the makefile. The default path of the generated executables are under the repository `/bin/` .

## USE
For Imperial College Maths Department users, on the nvidia4 machine, run

```bash
nvidia-smi
```
to check node status, and then type

```bash
export CUDA_VISIBLE_DEVICES=x
```

to select the available node. 

Run with

```bash
./bin/x
```
where x is the name of the executable binary.

Modify `simulation_info` and run again to see the effects of changing parameters.


## PYTHON SCRIPT
> :warning: **Do not go to this part if you do not want to perform massive data analysis**
> :warning: **The Python scripts here are very custom-written and do not run out of the box**

Python scripts are provided an example to automatically run sequential simulations using a single binary file. This is achieved by replacing the text in a config file which is then read by the binary file.

To use that, first change the path in 'settings.py' to match your fast fcm directory path. Create the required directory for data saving. 

You will need to use the random generator by compiling
''' make RANDOM_GENERATOR
'''

To use the script, modify the parameters in file `script.py`. The member function `start_loop` can be modified to sweep the simulation parameters. Data generation and data reading/processing are separate process, and can be controled by system arguments passed in the terminal.
h
Run simulations with
```bash
python3 script.py run
```
