#' Translates hierarchy levels into unique group names which represent the
#' elements hierarchy position. A '_exp' is added at the end of the groups name
#' if it has child elements.
#'
#' @param levels Vector of hierarchy levels.
#'
#' @return Vector of group names.
#'
#' @examples
#' levels <- c(1, 2, 2, 1, 2, 3, 3, 2, 1)
#' levelsToGroups(levels)
#' # c("1+", "11", "12", "2+", "21+", "211", "212", "22", "3")
levelsToGroups <- function(levels) {
  groups <- character(length(levels))
  for (i in 1:length(levels)) {
    lowerLvlIdx <- which(head(levels, i) < levels[i])
    maxLowerLvlIdx <- ifelse(length(lowerLvlIdx) == 0, 0, max(lowerLvlIdx))
    sameLvlIdx <- maxLowerLvlIdx +
      which(levels[(maxLowerLvlIdx + 1):i] == levels[i])
    groups[i] <- paste0(groups[maxLowerLvlIdx], length(sameLvlIdx))
  }
  expanded <- c(head(levels, -1) < tail(levels, -1), F)
  groups[expanded] <- paste0(groups[expanded], "_exp")
  return(groups)
}


#' Title
#'
#' @param data data.frame containing data to be shown
#' @param levels hierarchy levels
#'
#' @return html widget to display treetable data. See datatable function of
#' package DT
#' @export
#'
#' @examples
#' data <- data.frame(a = 1:9, b = c(5, 2, 3, 9, 4, 3, 1, 5, 3))
#' levels <- c(1, 2, 2, 1, 2, 3, 3, 2, 1)
#' treetable(data, levels)
treetable <- function(data, levels) {

  data[[ncol(data) + 1]] <- levels
  groups <- levelsToGroups(levels)
  data[[ncol(data) + 1]] <- groups

  toggleState <- character(nrow(data))
  toggleState[gsub("[0-9]+(_exp)", "\\1", groups) == "_exp"] <- "tree-toggle-expanded"
  toggleState[gsub("[0-9]+(_col)", "\\1", groups) == "_col"] <- "tree-toggle-collapsed"
  toggleState[toggleState != ""] <- paste0("<img class = '", toggleState[toggleState != ""], "' onclick = 'toggleTree(this);' />")

  data$a <- paste0("<div class = toggle-container>", toggleState ,"</div><span>", data$a, "</span>")

  dt <- DT::datatable(data,
                      escape = F,
                      rownames = F,
                      options = list(
                        pageLength = -1,
                        dom = "<'tree-level-dropdown-container'>ft",
                        rowCallback = DT::JS(
                          "function(row, data, index) {
                            addTreeGroup(row, data);
                            addTreeLevel(row, data);
                          }"),
                        initComplete = DT::JS(
                          "function(settings, json) {
                            addLevelDropdown(settings);
                            addCustomSearch(settings);
                          }"
                        ),
                        columnDefs = list(
                          list(targets = c(-2, -1),
                               searchable = F,
                               visible = F),
                          list(targets = "_all",
                               orderDataType = "group",
                               type = "num")
                        ),
                        language = list(
                          emptyTable = "Keine Daten in der Tabelle vorhanden",
                          info = "_START_ bis _END_ von _TOTAL_ Einträgen",
                          infoEmpty = "0 bis 0 von 0 Einträgen",
                          infoFiltered = "(gefiltert von _MAX_ Einträgen)",
                          infoPostFix = "",
                          infoThousands = ".",
                          lengthMenu = "_MENU_ Einträge anzeigen",
                          loadingRecords = "Wird geladen...",
                          processing = "Bitte warten...",
                          search = "Suchen",
                          zeroRecords = "Keine Einträge vorhanden.",
                          paginate = list(
                            first = "Erste",
                            previous = "Zurück",
                            'next' = "Nächste",
                            last = "Letzte"
                          ),
                          aria = list(
                            sortAscending = ": aktivieren, um Spalte aufsteigend zu sortieren",
                            sortDescending = ": aktivieren, um Spalte absteigend zu sortieren"
                          )
                        )
                      )
  )

  # Include javascript
  dt$dependencies[[length(dt$dependencies) + 1]] <-
    htmltools::htmlDependency(name = "treetable.js",
                              version = "0.0.1",
                              src = list(file = paste0(getwd(), "/R")),
                              script = "treetable.js")

  # Include css
  dt$dependencies[[length(dt$dependencies) + 1]] <-
    htmltools::htmlDependency(name = "treetable.css",
                              version = "0.0.1",
                              src = list(file = paste0(getwd(), "/R")),
                              stylesheet = "treetable.css")

  data[[(ncol(data) - 1)]] <- NULL
  data[[(ncol(data))]] <- NULL

  return(dt)
}



