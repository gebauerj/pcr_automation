#required packages
library(shiny)
library(shinymanager)
library(rhandsontable)
library(tidyverse)
library(readxl)
library(openxlsx)


#define Userinterface
ui <-
  fluidPage(
    
    titlePanel("Integra -> CFX/96well"),
    
    sidebarLayout(
      sidebarPanel(width = 1,
        actionButton("load", "Load Metadata"),
        br(),br(),
        actionButton("export", "Export")
      ),
      
      mainPanel(
        rHandsontableOutput("table"),
      )
    )
  )

# define server function
server <- function(input, output) {
  # renders the interactive table
  # The data, in this case sample barcodes, can then be read in using a barcode scanner
  output$res_auth <- renderPrint({
    reactiveValuesToList(result_auth)
  })
  # load template
  df1<-readRDS("template_96well.rds")
  output$table <- renderRHandsontable({
    df1 %>% rhandsontable()})
  # load metadata (from LIS-Export) and attach them to the scanned samples
  # processing of pooled samples is possible
  observeEvent(input$load,{
    metadata<-readRDS("metadata.RDS")
    df2<-hot_to_r(input$table) %>%
      mutate(sample1 = as.character(if_else(nchar(sample1)==10,str_sub(as.numeric(sample1), 1, nchar(as.numeric(sample1))-2), sample1)),
             sample2 = as.character(if_else(nchar(sample2)==10,str_sub(as.numeric(sample2), 1, nchar(as.numeric(sample2))-2), sample2))) %>%
      left_join(metadata, by = c("sample1"="ANR")) %>% left_join(metadata, by=c("sample2"="ANR")) %>%
      mutate(name1 = Name.x, name2 = Name.y, PC1 = PC.x, PC2= PC.y) %>%
      select(Row:sample2, name1, name2, PC1, PC2)

      output$table <- renderRHandsontable({
        df2 %>% rhandsontable()})

  })
  # modal dialog to specify the name of the output file
  popupModal <- function(failed = FALSE) {
    modalDialog(
      textInput("txt", "Input runfile name:",
                placeholder = "e.g. test1"),
      if (failed)
        div(tags$b("no name entered!", style = "color: red;")),
      
      footer = tagList(
        modalButton("Cancel"),
        actionButton("ok", "OK")
      )
    )
  }
  
  observeEvent(input$export,{    
    
    showModal(popupModal())
  })
  
  # writes the output file
  observeEvent(input$ok, {
    
    if (!is.null(input$txt) && nzchar(input$txt)) {
      
      y<-hot_to_r(input$table)
      runfile<- y %>%
        mutate(Target_Name = NA,
               Sample_Name = str_remove_all(paste(PC1, PC2, name1, name2, sample1, sample2, sep="/", recycle0 = T), "NA"),
               Sample_Name = str_remove_all(Sample_Name, ",")) %>%
        select(Row, Column, Target_Name, Sample_Name)

       export_name<-paste0(input$txt, ".csv")

      runfile %>%
        write.table(export_name, row.names = F, quote = F, na = "", sep = ",",
                    col.names = c("Row", "Column", '*Target Name', '*Sample Name'),
                    fileEncoding = "UTF-8")
      
      removeModal()
    } else {
      showModal(popupModal(failed = TRUE))
    }
  })  
  
}
# Run the application 
shinyApp(ui = ui, server = server)
