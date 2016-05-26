#' Main provider class
#'
#' @export
FODRProvider <- R6::R6Class("FODRProvider",
                            public = list(
                              provider = NULL,
                              facets = NULL,
                              n_datasets = NULL,
                              sortables = NULL,
                              themes = NULL,
                              initialize = function(provider){
                                self$provider <- provider
                                self$n_datasets <- get_datasets(provider = self$provider)$data$nhits
                                self$facets <- datasets_facets()
                                self$sortables <- datasets_sortables()
                                self$themes <- private$get_themes()
                              },
                              search = function(nrows = NULL, refine = NULL, exclude = NULL, sort = NULL, q = NULL, lang = NULL) {
                                listDatasets <- get_datasets(provider = self$provider, nrows, refine, exclude, sort, q, lang)$data$datasets
                                cat(paste(length(listDatasets), "datasets found ..."), "\n\n")
                                listDatasets <- lapply(listDatasets, function(dataset){
                                  FODRDataset$new(self$provider, dataset$datasetid)
                                })
                                listDatasets
                              },

                              print = function() {
                                cat("FODRProvider object\n")
                                cat("--------------------------------------------------------------------\n")
                                cat(paste("Provider:", self$provider, "\n"))
                                cat(paste("Number of datasets:", self$n_datasets, "\n"))
                                cat(paste("Themes:\n  -", paste(self$themes, collapse = "\n  - "), "\n"))
                                cat("--------------------------------------------------------------------\n")
                              }
                            ),
                            private = list(
                              get_themes = function(){
                                lapply(get_datasets(provider = self$provider, nrows = self$n_datasets)$data$datasets, function(dataset) {
                                  dataset$metas$theme
                                }) %>%
                                  unlist %>%
                                  unique %>%
                                  sort
                              }))
