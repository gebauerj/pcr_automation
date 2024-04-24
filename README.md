This repo shows the exemplary application of a ShinyApp for the automation of processes in laboratory medicine as part of our publication:

Gebauer, J., Adler, J. & On behalf of the DGKL working group “Digital Competence” (2023). Using Shiny apps for statistical analyses and laboratory workflows. Journal of Laboratory Medicine, 47(4), 149-153. https://doi.org/10.1515/labmed-2023-0020

The example app is additionally hosted on Shinyapps.io:
https://gebauerj.shinyapps.io/pcr_automation/

## Background to this application example
Nowadays, a large proportion of laboratory medical analysis devices are highly automated and able to process barcoded sample tubes independently. In some areas, however, such as PCR diagnostics, the methodology used requires batch processing of the samples. Here, the classic approach consists of generating a worklist according to which the samples are processed manually in the appropriate sequence. This is a very labor-intensive and error-prone step. We have therefore written a Shiny app that makes it possible to generate a worklist from a random sequence of samples, which can then be used in the following steps.

## Explanation of the individual files

### integra_to_cfx_96well.R 
This is the R code for ShinyApp. It can be executed in the laboratory either centralized on an R-Shiny server or at the corresponding workstation on a local R installation. After entering the sample barcodes at their corresponding position in the current batch, the metadata is loaded from an LIS export (in this case file-based). A file is then created for the PCR device (in this case Bio-Rad CFX96).

### LIS_metadata.txt
Example file of a possible metadata export from the LIS. 
In our case, this is technically a worklist exported as a text file. More sophisticated approaches, such as an SQL/ODBC-based query from the LIS database or a specially programmed interface in LIS would also be possible.

### metadata_from_LIS.R
This R script is adapted to the format of the LIS export file (LIS_metadata.txt). It reads the export files from the LIS in batches and makes them available to the Shiny app in a defined format.

### metadata.RDS
This file makes the imported metadata available for the Shiny app. It can also be used as temporary storage for the metadata.

### template_96well.rds
Template file for the interactive table of the Shiny app.

### test.csv
Example file as it would be created by the Shiny app. This is adapted to the requirements of the CFX96 cycler.
