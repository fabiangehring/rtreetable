#' Translates hierarchy levels into unique group names which represent the
#' elements hierarchy position. An '_exp' is added at the end of the groups name
#' if it has child elements.
#'
#' @param levels Vector of hierarchy levels.
#'
#' @return Vector of group names.
#'
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

cssToString <- function(config) {
  properties <- NULL
  for(name in names(config)) {
    elemProperties <- list()
    for(property in config[name]) {
      elemPropertyString <- paste0("'", names(property), "':'", property, "'")
      elemProperties <- c(elemProperties, elemPropertyString)
    }
    elemProperties <- paste0(elemProperties, collapse = ",")
    properties <- c(properties,
                    paste0("$('", name, "').css({", elemProperties, "});"))
  }
  return(paste0(properties, collapse = "\\n"))
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
#' data <- data.frame(a = 1:9, x = c(9,8,7,6,5,4,3,2,1), b = c(5, 2, 3, 9, 4, 3, 1, 5, 3))
#' levels <- c(1, 2, 2, 1, 2, 3, 3, 2, 1)
#' css <- list(
#'   "thead" = list(
#'     "background-color" = "rgba(255,0,0,0.5)",
#'     color = "white"
#'   ),
#'   ".tree-level-1" = list(
#'     "background-color" = "rgba(255,0,0,0.5)"
#'   )
#' )
#' treetable(data, levels, css)

treetable <- function(data, levels, css = NULL) {

  data[[ncol(data) + 1]] <- levels
  groups <- levelsToGroups(levels)
  data[[ncol(data) + 1]] <- groups

  toggleState <- character(nrow(data))
  toggleState[gsub("[0-9]+(_exp)", "\\1", groups) == "_exp"] <- "tree-toggle-expanded"
  toggleState[gsub("[0-9]+(_col)", "\\1", groups) == "_col"] <- "tree-toggle-collapsed"
  toggleState[toggleState != ""] <- paste0("<img class = '", toggleState[toggleState != ""], "' onclick = 'toggleTree(this);' />")

  data$a <- paste0("<div class = toggle-container>", toggleState ,"</div><span>", data$a, "</span>")

  dt <- DT::datatable(data,
                      class = "row-border hover",
                      escape = F,
                      rownames = F,
                      options = list(
                        pageLength = -1,
                        dom = "<'tree-level-dropdown-container'>ft",
                        rowCallback = DT::JS(
                          "function(row, data, index) {
                            addTreeGroup(row, data);
                            addTreeLevel(row, data);
                          }"
                        ),
                        initComplete = DT::JS(
                          paste0(
                            "function(settings, json) {
                            addLevelDropdown(settings);
                            addCustomSearch(settings);
                            applyCss(settings,\"", cssToString(css), "\");
                            }"
                          )
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
                          info = "_START_ bis _END_ von _TOTAL_ Eintr\u00E4gen",
                          infoEmpty = "0 bis 0 von 0 Eintr\u00E4gen",
                          infoFiltered = "(gefiltert von _MAX_ Eintr\u00E4gen)",
                          infoPostFix = "",
                          infoThousands = ".",
                          lengthMenu = "_MENU_ Eintr\u00E4ge anzeigen",
                          loadingRecords = "Wird geladen...",
                          processing = "Bitte warten...",
                          search = "Suchen",
                          zeroRecords = "Keine Eintr\u00E4ge vorhanden.",
                          paginate = list(
                            first = "Erste",
                            previous = "Zur\u00FCck",
                            'next' = "N\u00E4chste",
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



