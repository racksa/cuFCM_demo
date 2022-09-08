## DESCRIPTION

A CUDA benchmark for Fast Force-Coupling method

## USAGE
For Imperial College Maths Departmnet users, on Nvidia4, in command line, run

```bash
nvidia-smi
```
to check available nodes, and type

```bash
export CUDA_VISIBLE_DEVICES= $available node
```

to select the available node. Compile and run with

```bash
make clean CUFCM
./CUFCM
```