#' Main domain class
#'
#' @export
ODFDomain <- R6::R6Class("ODFDomain",
                          public = list(
                            domain = NULL,
                            facets = NULL,
                            n_datasets = NULL,
                            slug = NULL,
                            sortables = NULL,
                            initialize = function(slug){
                              self$slug <- slug
                              self$domain <- domains()$domains[domains()$slugs == slug]
                              self$n_datasets <- get_datasets(domain = self$domain)$data$nhits
                              self$facets <- datasets_facets()
                              self$sortables <- datasets_sortables()
                            },
                            search = function(nrows = NULL, refine = NULL, exclude = NULL, sort = NULL, q = NULL, lang = NULL) {
                              listDatasets <- get_datasets(domain = self$domain, nrows, refine, exclude, sort, q, lang)$data$datasets
                              cat(paste(length(listDatasets), "datasets found ..."), "\n\n")
                              for (i in 1:length(listDatasets)){
                                dataset <- listDatasets[[i]]
                                odfd <- ODFDataset$new(self$domain, dataset$datasetid)
                                print(odfd)
                                if (i < length(listDatasets)) cat("\n\n")
                              }
                            },

                            print = function() {
                              cat("ODFDomain object\n")
                              cat("--------------------------------------------------------------------\n")
                              cat(paste("Domain:", self$domain, "\n"))
                              cat(paste("Number of datasets:", self$n_datasets, "\n"))
                              cat(paste("Facets:", paste(self$facets, collapse = ", "), "\n"))
                              cat(paste("Sortables:", paste(self$sortables, collapse = ", "), "\n"))
                              cat("--------------------------------------------------------------------\n")
                            }
                          ))
