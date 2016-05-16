#' Main domain class
#'
#' @export
ODFDomain <- R6::R6Class("ODFDomain",
                          public = list(
                            domain = NULL,
                            facets = NULL,
                            n_datasets = NULL,
                            sortables = NULL,
                            themes = NULL,
                            initialize = function(domain){
                              self$domain <- domain
                              self$n_datasets <- get_datasets(domain = self$domain)$data$nhits
                              self$facets <- datasets_facets()
                              self$sortables <- datasets_sortables()
                              self$themes <- private$get_themes()
                            },
                            search = function(nrows = NULL, refine = NULL, exclude = NULL, sort = NULL, q = NULL, lang = NULL) {
                              listDatasets <- get_datasets(domain = self$domain, nrows, refine, exclude, sort, q, lang)$data$datasets
                              cat(paste(length(listDatasets), "datasets found ..."), "\n\n")
                              listDatasets <- lapply(listDatasets, function(dataset){
                                ODFDataset$new(self$domain, dataset$datasetid)
                              })
                              listDatasets
                            },

                            print = function() {
                              cat("ODFDomain object\n")
                              cat("--------------------------------------------------------------------\n")
                              cat(paste("Domain:", self$domain, "\n"))
                              cat(paste("Number of datasets:", self$n_datasets, "\n"))
                              cat(paste("Themes:\n  -", paste(self$themes, collapse = "\n  - "), "\n"))
                              cat("--------------------------------------------------------------------\n")
                            }
                          ),
                         private = list(
                           get_themes = function(){
                             lapply(get_datasets(domain = self$domain, nrows = self$n_datasets)$data$datasets, function(dataset) {
                               dataset$metas$theme
                             }) %>%
                               unlist %>%
                               unique %>%
                               sort
                           }))
