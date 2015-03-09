[![Build Status](https://travis-ci.org/wgmg/msy.svg?branch=master)](https://travis-ci.org/wgmg/msy)

msy
===

The `msy` R package is a collection of methods to estimate equilibrium reference points for fish stocks

Install
-------

To install the latest version of wqbc:

    # install.packages("devtools")
    library(devtools)
    install_github("flr/FLCore")
    install_github("wgmg/msy")
    library(msy)


Useage
------

    # load your data as an FLStock - here we use Plaice in ICES area 4 as an example
    data(ple4)
    FIT <- eqsr_fit(ple4, nsamp = 1000, models = c('smooth_hockey', 'segreg'))
    eqsr_plot(FIT, n=2e4)

Contact
-------

You are welcome to:

* submit suggestions and bug-reports at: https://github.com/wgmg/msy/issues
* send a pull request on: https://github.com/wgmg/msy
