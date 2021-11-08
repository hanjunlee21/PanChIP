#!/bin/python3

from matlab_wrapper.matlab_session import MatlabSession
import warnings
from os import path
from setuptools import setup, find_packages

try:
    import matlab.engine
    print('matlab engine already installed.\n')
except:
    print('Installing the matlab engine...', end='')
    try:
        matlab = MatlabSession()

        matlab.eval("cd (fullfile(matlabroot,'extern','engines','python'))")
        matlab.eval("system('python setup.py install')")

        try:
            import matlab.engine
            print('done.\n')
        except:
            warnings.warn(
                "\nFailed to install matlab engine. In any case you can use pynare with engine='octave'.\n")

    except:
        warnings.warn(
            "\nFailed to access matlab installation. Is it installed? In any case you can use pynare with engine='octave'.\n")
        
# read the contents of the README file
this_directory = path.abspath(path.dirname(__file__))
with open(path.join(this_directory, 'README.rst'), encoding='utf-8') as f:
    long_description = f.read()
    
setup(
  name = 'PanChIP',
  packages = ['PanChIP'],
  version = '1.0',
  license='MIT',
  description = 'Pan-ChIP-seq Analysis of Peak Sets',
  author = 'Hanjun Lee',
  author_email = 'hanjun@mit.edu',
  url = 'https://github.com/hanjunlee21/PanChIP',
  download_url = 'https://github.com/hanjunlee21/PanChIP/archive/refs/tags/v.1.0.tar.gz',
  keywords = ['chip-seq', 'bedfile'],   
  install_requires=[            
          'matlab_wrapper',
          'setuptools',
          'gdown',
          'argparse',
      ],
  classifiers=[
    'Development Status :: 3 - Alpha',      # Chose either "3 - Alpha", "4 - Beta" or "5 - Production/Stable"
    'Intended Audience :: Science/Research',      
    'Topic :: Scientific/Engineering :: Bio-Informatics',
    'License :: OSI Approved :: MIT License',   
    'Programming Language :: Python :: 3',
    'Programming Language :: Python :: 3.0',
    'Programming Language :: Python :: 3.1',
    'Programming Language :: Python :: 3.2',
    'Programming Language :: Python :: 3.3',
    'Programming Language :: Python :: 3.4',
    'Programming Language :: Python :: 3.5',
    'Programming Language :: Python :: 3.6',
    'Programming Language :: Awk',
    'Programming Language :: Unix Shell',
  ],
)
