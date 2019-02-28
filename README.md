# Random Mixed Field Model
Demo code of our AAAI 2016 paper "Random Mixed Field Model for Mixed-Attribute Data Restoration".

%% Code authors: Qiang Li

%% Release time: Jun. 3rd, 2018

%% Current version: RMF_code_v1

0. Add path.

First of all, run 'AddPath.m' to add paths of required packages.

1. Run the Main code.

There are three demos, i.e.,

'DemoClassifyMissNoisyData.m' gives classification comparison.

'DemoInferMixedNet.m' presents variational inference for data denoising.
In this case, the RMF model parameters are user-defined and fixed.

It also gives the MSE plots and graph visualization.
Note there maybe cases when denoising cont/disc nodes is ineffective.
This is possibly due to a compromise between continuous and discrete nodes.

'DemoLearnStruct.m' presents structure and parameter learning.
In this demo, the RMF model is learned using Jason Lee's code.

2. Datasets and Corrupted data preparation.

The experiment is conducted on several UCI datasets.

https://archive.ics.uci.edu/ml/datasets.html

Run 'GenMissNoisyData.m' to get the corrupted data.

3. Dependencies.

UGM at http://www.di.ens.fr/~mschmidt/Software/UGM_2009.zip

TFOCS at http://tfocs.stanford.edu

MGM at http://www-bcf.usc.edu/~lee715/syntheticExp/syntheticExp.zip

%% Reference noticement:

If you have used the code, please cite the following paper:

[1] Random Mixed Field Model for Mixed-Attribute Data Restoration

Qiang Li, Wei Bian, Richard Yi Da Xu, Jane You and Dacheng Tao

AAAI Conference on Artificial Intelligence (AAAI), Feb. 2016, pp. 1244--1250.

%% Supporting information:

If any questions and comments, feel free to send your email to

Qiang Li (leetsiang.cloud@gmail.com)
