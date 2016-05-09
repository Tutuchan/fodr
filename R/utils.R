get_dataset <- function(content_provider, id) {
  url <- paste0("http://data.", content_provider, ".fr/api/datasets/1.0/", id, "/")
  list(data = jsonlite::fromJSON(url, simplifyVector = FALSE, flatten = FALSE), url = url)
}

get_records <- function(content_provider, id, nrows, refine, exclude) {
  url <- paste0("http://data.", content_provider, ".fr/api/records/1.0/search?dataset=", id, "")

  if (!is.null(nrows)) url <- paste0(url, "&rows=", nrows)

  # Handle refine
  if (length(refine) > 0) for (i in 1:length(refine)) {
    facet = names(refine)[i]
    url <- paste0(url, "&facet=", facet, "&refine.", facet, "=", refine[[i]])
  }

  # Handle excluse
  if (length(exclude) > 0) for (i in 1:length(exclude)) {
    facet = names(exclude)[i]
    url <- paste0(url, "&facet=", facet, "&exclude.", facet, "=", exclude[[i]])
  }

  res <- jsonlite::fromJSON(url, simplifyVector = FALSE, flatten = FALSE) %$%
    records %>%
    purrr::transpose() %$%
    fields %>%
    purrr::transpose() %>%
    lapply(unlist) %>%
    dplyr::tbl_df()

  list(data = res, url = url)
}

get_facets <- function(fields){
  lapply(fields, function(field) {
    if (!"annotations" %in% names(field)) return(NULL) else {
      annotations <- field$annotations
      res <- lapply(annotations, function(annotation) {
        annotation$name == "facet"
      }) %>% unlist() %>% any()
      if (res) field$name else NULL
    }
  }) %>% unlist()
}
