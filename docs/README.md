# Build Docs

## Build Online Read the Docs

1. Commit the codes into github

    .readthedocs.yaml file is required.

2. Check whether an updated version is generated. (remember to refresh the page, F)

https://readthedocs.org/projects/datastorageanalysisarchitecture/

## Build Docs Locally

### Install Sphinx

`$ conda create -n sphinxNWB python=3.7 sphinx=4.4.0`

`$ conda activate sphinxNWB`

`pip install sphinxcontrib-matlabdomain==0.13.0`


or

`$ conda env create -f sphinxNWB.yaml`

`$ conda activate sphinxNWB`

`$ pip install sphinxcontrib-matlabdomain==0.13.0`

### Run Build

`$ make html`

Or 

`$ sphinx-build -b html docs docs/build/html`


# Useful Resouces

#. rst table generate

https://www.tablesgenerator.com/text_tables

