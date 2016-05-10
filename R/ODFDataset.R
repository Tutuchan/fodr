#' Main dataset class
#'
#' @export
ODFDataset <- R6::R6Class("ODFDataset",
                          public = list(
                            domain = NULL,
                            data = NULL,
                            facets = NULL,
                            fields = NULL,
                            id = NULL,
                            info = NULL,
                            sortables = NULL,
                            url = NULL,
                            initialize = function(domain, id){
                              raw_data <- get_dataset(domain, id)

                              self$domain <- domain
                              self$id <- id

                              self$url <- raw_data$url
                              dataset <- raw_data$data


                              self$info$features <- unlist(dataset$features)
                              dataset$metas$keywords <- unlist(dataset$metas$keyword)
                              dataset$metas$keyword <- NULL
                              self$info$meta <- dataset$metas
                              self$info$attachments <- dataset$attachments
                              self$info$alternative_exports <- dataset$alternative_exports
                              self$info$billing_plans <- dataset$billing_plans
                              self$fields <- dataset$fields
                              self$facets <- get_facets(self$fields)
                              self$sortables <- get_sortables(self$fields)
                            },
                            get = function(nrows = NULL, refine = NULL, exclude = NULL, sort = NULL, q = NULL, lang = NULL, geofilter.distance = NULL, geofilter.polygon = NULL) {
                              self$data <- get_records(domain = self$domain, id = self$id, nrows, refine, exclude, sort, q, lang, geofilter.distance, geofilter.polygon)
                              self$data
                            },

                            print = function() {
                              cat("ODFDataset object\n")
                              cat("--------------------------------------------------------------------\n")
                              cat(paste("Dataset id:", self$id, "\n"))
                              cat(paste("Theme:", self$info$meta$theme, "\n"))
                              cat(paste("Keywords:", paste(self$info$meta$keywords, collapse = ", "), "\n"))
                              cat(paste("Provider:", self$info$meta$publisher, "\n"))
                              cat("--------------------------------------------------------------------\n")
                              cat(paste("Number of records:", self$info$meta$records_count, "\n"))
                              cat(paste("Number of files:", length(self$info$attachments), "\n"))
                              cat(paste("Modified:", as.Date(self$info$meta$modified), "\n"))
                              if (!is.null(self$facets)) cat(paste("Facets:", paste(self$facets, collapse = ", "), "\n"))
                              if (!is.null(self$sortables)) cat(paste("Sortables:", paste(self$sortables, collapse = ", "), "\n"))
                              cat("--------------------------------------------------------------------\n")
                            }
                          ))
