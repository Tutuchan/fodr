#' Wrappers
#'
#' These functions wrap the class initializers.
#'
#' @name wrappers
NULL

#' @param provider a character
#' @rdname wrappers
#' @export
fodr_provider <- function(provider){
  FODRProvider$new(provider)
}

#' @param id a character
#' @rdname wrappers
#' @export
fodr_dataset <- function(provider, id){
  FODRDataset$new(provider, id)
}
