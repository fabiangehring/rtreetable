# rtreetable

rtreetable is a package to easily create treetables in R. It builds on the 
package DT and the tables can used wherever DT-Tables can be used as well, 
including shiny-Apps. In short, the packages adds treetable-typical behaviour 
like 
* collapsing, expanding parent/child-relationships 
* group-specific sorting
* text filtering 
* level filtering.


## Installation

The package is available on github. The latest development version can easily be
installed using the devtools package:

``` R
# install.packages("devtools") 
devtools::install_github("fabiangehring/rtreetable") 
```

## Quick start

Treetables are created by passing a ```data.frame``` and a vector indicating the
level for each row of the data to the packages main function ```treetable```.
Level 1 indicates the highest - the most parent - level. Rows with levels 
above the level of preceding rows will be subordinated.

``` R
data <- data.frame(a = 1:9, b = c(5, 2, 3, 9, 4, 3, 1, 5, 3))
levels <- c(1, 2, 2, 1, 2, 3, 3, 2, 1)
rtreetable::treetable(data, levels)
```
