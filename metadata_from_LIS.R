library(tidyverse)


path_metadata_from_LIS<- getwd()
file_metadata<-"metadata.RDS"

read_metadata<- . %>% read_fwf(.,
                          locale = readr::locale(encoding = "latin1"),
                          fwf_cols(Type = c(16,17), PC = c(20,25),
                                   Name = c(27,42), ANR = c(43,50),
                                   Station = c(52,62)),
                          progress = show_progress(),
                          skip_empty_rows = TRUE,
                          skip = 8) %>%
  filter(Type == "PC") %>% 
  mutate(Name = str_replace_all(Name, "/", " "),
         ANR = as.character(ANR))

if(!is_empty(list.files(path = path_metadata_from_LIS, pattern = ".txt", full.names = T))){

files_LIS_input<-list.files(path = path_metadata_from_LIS, pattern = "metadata.txt", full.names = T)
LIS_input<-sapply(files_LIS_input, read_metadata, simplify =  F) %>% bind_rows() %>%
  as_tibble() %>% distinct() %>% mutate(ANR=as.character(ANR))
print(LIS_input)
# #possibility to store imported data
saveRDS(LIS_input, file_metadata)

# #removes files after processing
# file.remove(files_LIS_input)
}

