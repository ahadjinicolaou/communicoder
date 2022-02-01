
:construction: This README is currently under construction!

# Overview
The `communicoder` toolbox is used to train and evaluate neural decoders of communicative behavior, using spectral power estimates of brain activity as the neural input and spoken words as the behavioral input. The objective of this project is to use performant decoders to identify the brain structures that are recruited during conversation, with an view towards clinical application (e.g., the treatment of brain disorders that impair communication).

In this project, the machine learning model of choice is the generalized linear model ([GLM](https://en.wikipedia.org/wiki/Generalized_linear_model)), owing to its ease of interpretation and reasonable underlying assumptions. The GLM coefficients are fitted using lasso regularization, which is helpful in identifying the specific predictors (or brain regions) that are informative for the behavioral signal.

The target behavioral signal is created using the onsets of words spoken during a conversation. By default, this signal is simply the word rate (i.e., word count in each 1-second time step). Additional options allow the creation of signals that are differentiated by lexical class, such that (say) only nouns and verbs are used to create the signal. It is also possible to model *intent state* as a [latent variable](https://en.wikipedia.org/wiki/Latent_variable) that cannot be directly observed, but whose dynamics can be inferred using the (word onset) observations.

> Note that while this latent variable approach has been tested in preliminary versions of this package, it is currently unsupported.

# Requirements
This package has been tested on Windows 10 with MATLAB 2018b, though versions 2017b and later should be sufficient. You will also need to have the following libraries accessible in the path:

*  [natsort](https://www.mathworks.com/matlabcentral/fileexchange/47434-natural-order-filename-sort)
*  [progressbarText](https://www.mathworks.com/matlabcentral/fileexchange/66270-text-progress-bar-cli-gui)
*  [brewermap](https://www.mathworks.com/matlabcentral/fileexchange/45208-colorbrewer-attractive-and-distinctive-colormaps)

You will also need to have the *datasets* folder, containing neural and conversational data for study participants -- these are supplied to my collaborators.
