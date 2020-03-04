![](https://raw.githubusercontent.com/HeisenbugLtd/heisenbugltd.github.io/master/assets/img/spat/cover.png)

# SPARK Proof Analysis Tool

## Introduction

The SPARK tools (i.e. GNATprove) leave behind a trove of information after a proof run.
This tool is intended to take these and extract some useful information out of it (like
for example, where the provers spent their time, which provers solved the problem first
etc. pp.).

## Motivation

The idea is that making use of that information will help identify and fix bottlenecks
during proof. As the format of these files is virtually undocumented, a little bit of
reverse engineering may be required, but on the other hand, maybe the result is actual
[documentation](https://github.com/HeisenbugLtd/spat/blob/master/doc/spark_file_format.md).
