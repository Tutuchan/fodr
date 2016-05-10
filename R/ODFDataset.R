#' Main dataset class
#'
#' @export
ODFDataset <- R6::R6Class("ODFDataset",
                          public = list(
                            content_provider = NULL,
                            id = NULL,
                            info = NULL,
                            fields = NULL,
                            facets = NULL,
                            sortables = NULL,
                            url = NULL,
                            initialize = function(content_provider, id){
                              raw_data <- get_dataset(content_provider, id)

                              self$content_provider <- content_provider
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
                              get_records(content_provider = self$content_provider, id = self$id, nrows, refine, exclude, sort, q, lang, geofilter.distance, geofilter.polygon)
                            },

                            print = function() {
                              cat("----------------------------------\n")
                              cat(paste("Dataset id:", self$id, "\n"))
                              cat(paste("Theme:", self$info$meta$theme, "\n"))
                              cat(paste("Keywords:", paste(self$info$meta$keywords, collapse = ", "), "\n"))
                              cat(paste("Provider:", self$info$meta$publisher, "\n"))
                              cat("----------------------------------\n")
                              cat(paste("Number of records:", self$info$meta$records_count, "\n"))
                              cat(paste("Modified:", as.Date(self$info$meta$modified), "\n"))
                            }
                          ))
