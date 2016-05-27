#' Main portal class
#'
#' This is the entry point to retrieve datasets from a portal. Initialize a \code{FODRPortal}
#' with a \code{portal}.
#'
#' @docType class
#' @param portal a character, must be one of the available portals
#' @field portal a character, the portal name
#' @field data a list of \code{\link{FODRDataset}} objects
#' @field facets a character vector of variables that can be used to filter results. For a 
#' \code{\link{FODRPortal}, these are constant.
#' @field sortables a character vector, indicates on which fields sorting is allowed. For a 
#' \code{\link{FODRPortal}, these are constant.
#' @field themes a character vector, the unique themes datasets on the portals can be associated with
#' @return An object of class \code{\link{FODRPortal}} with methods designed to retrieve datasets from an open data portal.
#' #' @section Methods:
#' \describe{
#'   \item{\code{\link[=portal_search]{search}}}{This method retrieves datasets from the portal.}}
#' @export
FODRPortal <- R6::R6Class("FODRPortal",
                          public = list(
                            data = NULL,
                            portal = NULL,
                            facets = NULL,
                            n_datasets = NULL,
                            sortables = NULL,
                            themes = NULL,
                            initialize = function(portal){
                              self$portal <- portal
                              self$n_datasets <- search_datasets(portal = self$portal)$data$nhits
                              self$facets <- datasets_facets()
                              self$sortables <- datasets_sortables()
                              self$themes <- private$get_themes()
                            },
                            search = function(nrows = NULL, refine = NULL, exclude = NULL, sort = NULL, q = NULL, lang = NULL, theme = NULL) {
                              if (is.null(nrows)) nrows <- self$n_datasets
                              listDatasets <- search_datasets(portal = self$portal, nrows, refine, exclude, sort, q, lang)$data$datasets
                              cat(paste(length(listDatasets), "datasets found ..."), "\n")
                              self$data <- lapply(listDatasets, function(dataset){
                                if (!is.null(theme)) if (dataset$metas$theme != theme) return(NULL)
                                FODRDataset$new(self$portal, dataset$datasetid)
                              }) %>% clean_list()
                              self$data
                            },
                            
                            print = function() {
                              cat("FODRPortal object\n")
                              cat("--------------------------------------------------------------------\n")
                              cat(paste("Portal:", self$portal, "\n"))
                              cat(paste("Number of datasets:", self$n_datasets, "\n"))
                              cat(paste("Themes:\n  -", paste(self$themes, collapse = "\n  - "), "\n"))
                              cat("--------------------------------------------------------------------\n")
                            }
                          ),
                          private = list(
                            get_themes = function(){
                              lapply(search_datasets(portal = self$portal, nrows = self$n_datasets)$data$datasets, function(dataset) {
                                dataset$metas$theme
                              }) %>%
                                unlist %>%
                                unique %>%
                                sort
                            }))
