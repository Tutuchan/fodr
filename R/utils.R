# Get content domain url
get_domain_url <- function(domain, endpoint){
  stopifnot(domain %in% domains()$domains)
  paste0("http://", get_base_url(domain), ".fr/api/", endpoint, "/1.0/")
}

# Get datasets data
get_datasets <- function(domain, nrows = NULL, refine = NULL, exclude = NULL, sort = NULL, q = NULL, lang = NULL) {
  url <- get_domain_url(domain, "datasets") %>%
    paste0("search/") %>%
    add_parameters_to_url(nrows, refine, exclude, sort, q, lang)
  list(data = jsonlite::fromJSON(url, simplifyVector = FALSE, flatten = FALSE), url = url)
}

# Get dataset meta data
get_dataset <- function(domain, id) {
  url <- get_domain_url(domain, "datasets") %>%
    paste0(id, "/")
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
get_records <- function(domain, id, nrows, refine, exclude, sort, q, lang, geofilter.distance, geofilter.polygon) {
  url <- get_domain_url(domain, "records") %>%
    paste0("search?dataset=", id) %>%
    add_parameters_to_url(nrows, refine, exclude, sort, q, lang, geofilter.distance, geofilter.polygon)


  res <- jsonlite::fromJSON(url, simplifyVector = FALSE, flatten = FALSE) %$%
    records

  res <- if (length(res) > 0) res %>%
    purrr::transpose() %$%
    fields %>%
    purrr::transpose() %>%
    lapply(unlist) %>%
    dplyr::tbl_df() else dplyr::data_frame()

  list(data = res, url = url)
}

add_parameters_to_url <- function(url, nrows = NULL, refine = NULL, exclude = NULL, sort = NULL, q = NULL,
                                  lang = NULL, geofilter.distance = NULL, geofilter.polygon = NULL) {
  if (all(is.null(nrows),
          is.null(refine),
          is.null(exclude),
          is.null(sort),
          is.null(q),
          is.null(lang),
          is.null(geofilter.distance),
          is.null(geofilter.polygon))) return(url) else additional_url <- c()

  # Handle nrows
  if (!is.null(nrows)) additional_url <- c(additional_url, rows = nrows)

  # Handle refine
  if (!is.null(refine)) for (i in 1:length(refine)) {
    facet = names(refine)[i]
    val <- refine[[i]]
    names(val) = paste0("refine.", facet)
    additional_url <- c(additional_url, facet = facet, val)
  }

  # Handle exclude
  if (!is.null(exclude)) for (i in 1:length(exclude)) {
    facet = names(exclude)[i]
    val <- exclude[[i]]
    names(val) = paste0("exclude.", facet)
    additional_url <- c(additional_url, facet = facet, val)
  }

  # Handle sort
  if (!is.null(sort)) additional_url <- c(additional_url, sort = sort)

  # Handle q
  if (!is.null(q)) additional_url <- c(additional_url, q = q)

  # Handle geofilter.distance
  if (!is.null(geofilter.distance)) additional_url <- c(additional_url, geofilter.distance = paste(geofilter.distance, collapse = ","))

  # Handle geofilter.polygon
  if (!is.null(geofilter.polygon)) {
    geofilter.polygon <- geofilter.polygon %>%
      unite(polygon, lat, lon, sep = ",") %>%
      mutate(polygon = paste0("(", polygon, ")")) %$%
      polygon %>%
      paste(collapse = ",")
    additional_url <- c(additional_url, geofilter.polygon = geofilter.polygon)
  }
  url <- paste0(url, "?", paste(names(additional_url), additional_url, sep = "=", collapse = "&"))
  print(url)
  url

}


# Constants
domains <- function(){
  dplyr::data_frame(domains = c("iledefrance", "paris", "ratp", "hauts-de-seine"),
                    slugs = c("idf", "paris", "ratp", "92"),
                    base_urls = c("data", "opendata", "data", "opendata"))
}

get_base_url <- function(domain){
  domains() %>%
    dplyr::filter(domains == domain) %>%
    tidyr::unite(url, base_urls, domains, sep = ".") %$%
    url
}

datasets_facets <- function(){
  c("modified",
    "published",
    "issued",
    "accrualperiodicity",
    "language",
    "license",
    "granularity",
    "dataquality",
    "theme",
    "keyword",
    "created",
    "creator",
    "contributor")
}

datasets_sortables <- function(){
  c("modified",
    "issued",
    "created")
}
