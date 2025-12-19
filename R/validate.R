# internal: load python bridge
.linkmlr_bridge <- function() {
  linkmlr_use_python()
  reticulate::import_from_path(
    module = "linkmlr_bridge",
    path = system.file("python", package = "linkmlR"),
    convert = TRUE
  )
}

#' Validate an R object against a LinkML schema
#'
#' @param schema Path to LinkML schema YAML.
#' @param instance R list/data.frame representing the instance data.
#' @param target_class Optional LinkML class name to validate against.
#' @param config Optional path to LinkML validation config YAML.
#' @return A list with `ok` and `issues`.
#' @export
linkml_validate <- function(schema, instance, target_class = NULL, config = NULL) {
  if (!file.exists(schema)) abort("Schema file does not exist: {schema}")
  bridge <- .linkmlr_bridge()

  instance_json <- jsonlite::toJSON(instance, auto_unbox = TRUE, null = "null")
  res <- bridge$validate_json_instance(
    schema_path   = normalizePath(schema),
    instance_json = instance_json,
    target_class  = target_class %||% NULL
  )

  res
}

#' Validate an instance file (YAML/JSON) by loading into R first
#'
#' @param schema Path to LinkML schema YAML.
#' @param data_file Path to YAML or JSON instance file.
#' @param target_class Optional LinkML class name.
#' @param config Optional validation config path.
#' @export
linkml_validate_file <- function(schema, data_file, target_class = NULL, config = NULL) {
  if (!file.exists(data_file)) rlang::abort(paste0("Data file does not exist: ", data_file))

  ext <- tolower(tools::file_ext(data_file))
  instance <- switch(
    ext,
    "json" = jsonlite::read_json(data_file, simplifyVector = FALSE),
    "yaml" = yaml::read_yaml(data_file),
    "yml"  = yaml::read_yaml(data_file),
    abort("Unsupported data file extension: {ext} (use .json/.yml/.yaml)")
  )

  linkml_validate(schema = schema, instance = instance, target_class = target_class, config = config)
}
