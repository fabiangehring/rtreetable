
library(shiny)
library(DT)
library(dplyr)


# Define UI for application that draws a histogram
ui <- fluidPage(
  DT::dataTableOutput("distPlot"),
  verbatimTextOutput("console")
)


# Define server logic required to draw a histogram
# input <- NULL
# input$clickedGroup <- "2_exp"

# n <- 2
# data <- data.frame(a = rep(1:9, n), b = rep(c(5, 2, 3, 9, 4, 3, 1, 5, 3), n))
# data$levels <- rep(c(1, 2, 2, 1, 2, 3, 3, 2, 1), n)
# data$group <- levelsToGroups(data$levels)
# tableValues <- NULL
# tableValues$table <- select(data, -levels, -group)
# tableValues$levels <- data$levels

server <- function(input, output) {

  # Sample Data
  n <- 2
  data <- data.frame(a = rep(1:9, n), b = rep(c(5, 2, 3, 9, 4, 3, 1, 5, 3), n))
  data$levels <- rep(c(1, 2, 2, 1, 2, 3, 3, 2, 1), n)
  data$group <- levelsToGroups(data$levels)

  # Init reactiveValues
  tableValues <- reactiveValues(table = select(data, -levels),
                                levels = data$levels)

  # Register Toggle Observer
  observeEvent(input$clickedGroup, {

    currentGroups <- levelsToGroups(tableValues$levels)
    affectedExtGroup <- gsub("_exp$", "", input$clickedGroup)
    allSubGroups <- grepl(paste0("^", affectedExtGroup, "[0-9]+(_exp)?$"), currentGroups)

    if (sum(allSubGroups) > 0) {
      # remove all subgroups TODO: could be made on base of existing values
      groups <- setdiff(currentGroups, currentGroups[allSubGroups])
    } else {
      # add next level
      nextSubGroups <- grepl(paste0("^", affectedExtGroup, "[0-9]{1}(_exp)?$"), currentGroups)
      groups <- c(currentGroups, nextSubGroups)
    }
    showData <- filter(data, group %in% groups)
    tableValues$table <- select(showData, -levels)
    tableValues$levels <- showData$levels
  })

  output$distPlot <- DT::renderDataTable({
    rtreetable::treetable(tableValues$table, tableValues$levels, server = TRUE)
  })
}

# Run the application
shinyApp(ui = ui, server = server)
