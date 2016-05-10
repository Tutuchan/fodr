# Get dataset meta data
get_dataset <- function(content_provider, id) {
  url <- paste0("http://data.", content_provider, ".fr/api/datasets/1.0/", id, "/")
  list(data = jsonlite::fromJSON(url, simplifyVector = FALSE, flatten = FALSE), url = url)
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

get_sortables <- function(fields){
  lapply(fields, function(field) {
    if (field$type == "int") field$name else NULL
  }) %>% unlist()
}

# Get dataset records
get_records <- function(content_provider, id, nrows, refine, exclude, sort, q, lang, geofilter.distance, geofilter.polygon) {
  url <- paste0("http://data.", content_provider, ".fr/api/records/1.0/search?dataset=", id, "")

  if (!is.null(nrows)) url <- paste0(url, "&rows=", nrows)

  # Handle refine
  if (!is.null(refine)) for (i in 1:length(refine)) {
    facet = names(refine)[i]
    url <- paste0(url, "&facet=", facet, "&refine.", facet, "=", refine[[i]])
  }

  # Handle exclude
  if (!is.null(exclude)) for (i in 1:length(exclude)) {
    facet = names(exclude)[i]
    url <- paste0(url, "&facet=", facet, "&exclude.", facet, "=", exclude[[i]])
  }

  # Handle sort
  if (!is.null(sort)) url <- paste0(url, "&sort=", sort)

  # Handle q
  if (!is.null(q)) url <- paste0(url, "&q=", q)

  # Handle geofilter.distance
  if (!is.null(geofilter.distance)) url <- paste0(url, "&geofilter.distance=", paste(geofilter.distance, collapse = ","))

  # Handle geofilter.polygon
  if (!is.null(geofilter.polygon)) {
    geofilter.polygon <- geofilter.polygon %>%
      unite(polygon, lat, lon, sep = ",") %>%
      mutate(polygon = paste0("(", polygon, ")")) %$%
      polygon %>%
      paste(collapse = ",")
    url <- paste0(url, "&geofilter.polygon=", geofilter.polygon)
  }

  res <- jsonlite::fromJSON(url, simplifyVector = FALSE, flatten = FALSE) %$%
    records

  res <- if (length(res) > 0) res %>%
    purrr::transpose() %$%
    fields %>%
    purrr::transpose() %>%
    lapply(unlist) %>%
    dplyr::tbl_df() else data_frame()

  list(data = res, url = url)
}

