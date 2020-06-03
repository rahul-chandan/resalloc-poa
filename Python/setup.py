from setuptools import setup, find_packages

with open('README.md') as f:
    readme = f.read()

with open('LICENSE') as f:
    license = f.read()

setup(
    name='resallocPoA',
    version='0.1.0',
    description='Package to compute and optimize the price of anarchy (PoA) in atomic congestion games and their maximization version.',
    long_description=readme,
    author='Rahul Chandan',
    author_email='rchandan@ucsb.edu',
    url='https://github.com/rahul-chandan/resalloc-poa',
    license=license,
    packages=find_packages(exclude=('tests', 'docs')),
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
    python_requires='>=3.6',
)